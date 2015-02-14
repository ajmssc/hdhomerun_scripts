#!/usr/bin/env python
import argparse
import urllib2
import urllib
import time
import json
import sys

url_prefix = set(('http', 'rtp', 'udp'))

tvh_url = "http://192.168.1.140:9981"



import re

ICON_URL_PREFIX = "http://192.168.1.140/tv/logos/"
PROGNUM = re.compile(r"\((\d+) (.*)\)")  # #EXTINF:0,1 - SLO 1 -> #1 - num, 2 - ime
URLPART = re.compile(r"^((?P<scheme>.+?)://@?)?(?P<host>.*?)(:(?P<port>\d+?))?$")
PARAM = re.compile(r"((?P<id>[a-zA-Z0-9\-]+)\=\"(?P<val>[^\"]+)\")")

channels = dict()

INTERFACE="eth0"
MAX_TIMEOUT = 5
MAX_STREAMS = 3
CREATE_SCAN_STATE=1
CREATE_SCAN_RESULT=0


def uuid():
    import uuid
    return uuid.uuid4().hex


def readm3u(infile):
    instream = open(infile)
    
    chancnt = 0
    chname = ''
    chnumber = None
    chxmltv = None
    chicon = None
    for line in instream.readlines():
        line = line.strip()
        if line.startswith("#EXTINF:"):
            buff = line[8:].split(',')
            m = PROGNUM.search(buff[1])
            chname = buff[1]
            if m != None:
                chnumber = m.group(1)
            else:
                chnumber = 0
            #print "chan num " + str(chnumber) + " "
            params = re.finditer(PARAM, buff[0])
            params_list = [m.groupdict() for m in params]
            for param in params_list:
                if param['id'] == "tvg-id":
                    chxmltv = param['val']
                if param['id'] == "tvg-logo":
                    chicon = ICON_URL_PREFIX + param['val']
        else:
            churl = line
            chancnt += 1
            if not chname == '' and not chname in channels:
                channels[chname] = {'id': chancnt, 'number': chnumber, 'name': chname,
                                'url': churl, 'xmltv': chxmltv, 'icon': chicon}
            chname = ''
            churl = ''
            chnumber = None
            chxmltv = None
            chicon = None
    return channels






def get_uuid_info(uuid):
    request = urllib2.Request(tvh_url + "/api/idnode/load", urllib.urlencode({ 'uuid': uuid, 'meta':1}))
    response = urllib2.urlopen(request)
    data = json.load(response)['entries']
    return data

def get_networks():
    request = urllib2.Request(tvh_url + "/api/idnode/load", urllib.urlencode({ 'class': 'mpegts_network', 'enum':1 }))
    response = urllib2.urlopen(request)
    data = json.load(response)['entries']
    return data

def get_muxes():
    request = urllib2.Request(tvh_url + "/api/mpegts/mux/grid", urllib.urlencode({ 'sort': 'name', 'dir':'ASC' }))
    response = urllib2.urlopen(request)
    data = json.load(response)['entries']
    return data

def get_service(name):
    for service in get_services():
        if service['svcname'] == name:
            return service
    return { 'uuid' : '' }

def get_services():
    request = urllib2.Request(tvh_url + "/api/mpegts/service/grid", urllib.urlencode({ 'sort': 'svcname', 'dir':'ASC' }))
    response = urllib2.urlopen(request)
    data = json.load(response)['entries']
    return data

def get_channels():
    request = urllib2.Request(tvh_url + "/api/channel/grid", urllib.urlencode({ 'sort': 'name', 'dir':'ASC' }))
    response = urllib2.urlopen(request)
    data = json.load(response)['entries']
    return data

def get_network_uuid(name):
    networks = get_networks()
    for network in networks:
        if network['val'] == name:
            return network['key']
    return ''
def get_networks():
    request = urllib2.Request(tvh_url + "/api/idnode/load", urllib.urlencode({ 'class': 'mpegts_network', 'enum':1 }))
    response = urllib2.urlopen(request)
    data = json.load(response)['entries']
    return data


def delete_uuid(uuid):
    data = post_data("/api/idnode/delete", { 'uuid': [str(uuid)] })
    return data

def save_uuid(uuid, node):
    query = {
        'node' : json.dumps(node)
    }
    return post_data("/api/idnode/save", query)


def create_network(name, max_streams=MAX_STREAMS):
    query = {
        'class' : 'iptv_network',
        'conf' : json.dumps({ "networkname": name,
            "autodiscovery":False,
            "skipinitscan":True,
            "idlescan":False,
            "max_streams": max_streams,
            "max_bandwidth":0,
            "max_timeout":MAX_TIMEOUT,
            "nid":0,
            "charset":"",
            "priority":1,
            "spriority":1
        })
    }
    return post_data("/api/mpegts/network/create", query)

def create_channel(name, number, logo, epg, service):
    node = { 
            "enabled":True,
            "name":name,
            "number":number,
            "icon": logo,
            "epggrab":[str(epg)],
            "epgauto":True,
            "services":[str(service)],
            "tags":"",
            "dvr_pre_time":0,
            "dvr_pst_time":0
    }
    query = {
        'conf': json.dumps(node)
    }
    post_data("/api/channel/create", query)
    for cur_channel in get_channels():
        if cur_channel['name'] == name:
            uuid = cur_channel['uuid']
    node['uuid'] = uuid
    return save_uuid(uuid, node)


def create_mux(network_uuid, mux_name, service_name, url, interface=INTERFACE):
    query = {
        'uuid': network_uuid,
        'conf': json.dumps({
            "enabled":True,
            "epg":1,
            "scan_state":CREATE_SCAN_STATE,
            "scan_result":CREATE_SCAN_RESULT,
            "iptv_url": url,
            "iptv_interface": interface,
            "iptv_atsc":False,
            "iptv_muxname":mux_name,
            "iptv_sname":service_name,
            "charset":"AUTO",
            "pmt_06_ac3":False,
            "priority":0,
            "spriority":0,
        })
    }
    return post_data("/api/mpegts/network/mux_create", query)

def post_data(url, query):
    encquery = urllib.urlencode(query).replace('+', '%20').replace('%27', '%22')
    request = urllib2.Request(tvh_url + url, encquery)
    response = urllib2.urlopen(request)
    data = json.load(response)
    return data

def printbuf(line):
    print line,
    sys.stdout.flush()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Read a playlist and feed it to TVHeadend')
    parser.add_argument('--m3u_file', '-m')
    parser.add_argument('--tvheadend', '-tvh')
    parser.add_argument('--user', '-u')
    parser.add_argument('--password', '-p')
    args = parser.parse_args()

    tvh_url = args.tvheadend
    tvh_user = args.user
    tvh_password = args.password
    m3u_file = args.m3u_file
    
    auth_handler = urllib2.HTTPBasicAuthHandler()
    auth_handler.add_password(realm='tvheadend',
                      uri=args.tvheadend,#'http://192.168.175.9:9981/',
                      user=args.user,
                      passwd=args.password)
    opener = urllib2.build_opener(auth_handler)
    # ...and install it globally so it can be used with urlopen.
    urllib2.install_opener(opener)
    #print create_network()
    channels = readm3u(m3u_file)
    if len(channels) > 0:
        network_name = "Comcast IPTV"
        network_uuid = get_network_uuid(network_name)
        ###cleanup
        if network_uuid != '':
            delete_uuid(str(network_uuid))
            for cur_channel in get_channels():
                delete_uuid(str(cur_channel['uuid']))
            create_network(network_name)
            network_uuid = get_network_uuid(network_name)
        else:
            create_network(network_name)
            network_uuid = get_network_uuid(network_name)
        print network_name, network_uuid
        i = 0
        ###create muxes
        for chan in channels:
            printbuf("Creating and scanning mux " + chan)
            create_mux(network_uuid, chan, chan, channels[chan]['url'])
            channels[chan]['status'] = 'created_mux'
            channels_scanning = 1
            while channels_scanning > 0:
                printbuf('.')
                channels_scanning = 0
                for mux in get_muxes():
                    if mux['scan_state'] > 0:
                        channels_scanning += 1
                    # if mux['iptv_muxname'] == chan:
                    #     channels[chan]['service'] = mux[]
                time.sleep(1)
            print " [DONE]"
            printbuf("Linking channel <-> service . . . .")
            channels[chan]['service'] = get_service(chan)['uuid']
            create_channel(chan, channels[chan]['number'], channels[chan]['icon'], "xmltv|" + channels[chan]['xmltv'], channels[chan]['service'])
            print " [DONE]"
            # i += 1
            # if i > 0:
            #     break
        channels_scanning = 1
