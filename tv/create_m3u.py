#!/usr/bin/env python

import HTMLParser
import sys
import BeautifulSoup as bs

exclude = open('exclude.cfg', 'r').read()

xml_f = open('xmltv.xml', 'r')
#xml_data = xml_f.read()
xml_data = ""

try:
    while True:
        line = next(xml_f)
        if line.find("<programme") > -1:
            raise Exception('stop parsing')
        xml_data += line
except Exception as e:
    #print "exception", e
    pass
xml_data += "</tv>"

m3u_output = open('tv.m3u', 'w')
m3u_output.write('#EXTM3U\n')

soup = bs.BeautifulSoup(xml_data)
channels = soup.findAll('channel')


for channel in channels:
    chan_options = channel.findAll('display-name')
    c_id = channel['id']
    c_numbername = chan_options[0].contents[0]
    c_number = chan_options[1].contents[0]
    c_shortname = chan_options[2].contents[0]
    if len(chan_options) == 4:
        c_type = chan_options[3].contents[0]
        c_prettyname = c_shortname + ' (' + c_numbername + ')'
    else:
        c_longname = chan_options[3].contents[0]
        c_longname = c_longname.replace('-', '')
        c_longname = c_longname.replace('(' + c_shortname + ')', '')
        c_longname = c_longname.strip()
        c_type = chan_options[4].contents[0]
        c_prettyname = HTMLParser.HTMLParser().unescape(c_longname) + ' (' + c_numbername + ')'
    if not c_numbername in exclude:
        m3u_output.write('#EXTINF:-1 tvg-id="' + c_id + '" tvg-logo="' + c_shortname.replace(' ','') + '.png" tvg-name="' + c_numbername + '" group-title="Comcast Cable",' + c_prettyname + '\n')
        m3u_output.write('http://192.168.1.100:5004/auto/v' + c_number + '\n')


static_m3u = open('static.m3u', 'r')
static_data = static_m3u.read()
for line in static_data:
    m3u_output.write(line)

print "Done"



