#!/opt/bin/bash

/bin/touch /data/bin/tvhh_restart.cron
/var/packages/tvheadend-testing/scripts/start-stop-status stop
/bin/sleep 5
/var/packages/tvheadend-testing/scripts/start-stop-status start


