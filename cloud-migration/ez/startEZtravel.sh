#!/bin/bash

START_TIME="$(date)"
# this is a way to support overrides
if [ -z $UNIX_USER_HOME_PATH ]; then
  UNIX_USER_HOME_PATH=/home/dtu_training/perform-2021-hotday-dev/cloud-migration/ez
fi
if [ -z $UNIX_USER ]; then
  UNIX_USER=dtu_training
fi

LOGFILE='/tmp/EZtravel.log'
echolog()
(
    echo "$@"
    echo "$@" >> $log_file_name
)

echolog "Init Log @ $START_TIME"
echolog "whoami = ${whoami}"
sudo chmod 777 $LOGFILE

echolog "Calling Stop EasyTravel"
sudo $UNIX_USER_HOME_PATH/stopEZtravel.sh

echolog "Deleting /tmp/weblauncher.log"1
sudo rm -f /tmp/weblauncher.log

echolog "sleeping 10 seconds to ensure easyTravel is fully down"
sleep 10

echolog "Starting reverse proxy Docker instances"
docker run -p 80:80 -v $UNIX_USER_HOME_PATH/nginx/classic:/etc/nginx/conf.d/:ro -d --name reverseproxy-classic nginx:1.15
docker run -p 81:80 -v $UNIX_USER_HOME_PATH/nginx/angular:/etc/nginx/conf.d/:ro -d --name reverseproxy-angular nginx:1.15

echolog "Calling eztravel weblauncher.sh"
# if not workshop user, then run as workshop user
# easyTravel requires that is not run a root user
if [ `whoami` == "$UNIX_USER" ]; then
    echolog "Starting EasyTravel as $UNIX_USER user"
    $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/weblauncher/weblauncher.sh > /tmp/weblauncher.log 2>&1 &
else
    echolog "Starting EasyTravel as changed user $UNIX_USER"
    su -c "sh $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/weblauncher/weblauncher.sh > /tmp/weblauncher.log 2>&1 &" $UNIX_USER
fi
# allow log to start, then check to see if started ok
sleep 10
{ [[ -f /tmp/weblauncher.log ]] && echolog "*** EasyTravel launched ***" || echolog "*** Problem launching EasyTravel no weblauncher.log ***" ; }

while IFS= read -r LOGLINE || [[ -n "$LOGLINE" ]]; do
    printf '%s\n' "$LOGLINE"
    [[ "${LOGLINE}" == *"easyTravel procedures started successfully"* ]] && echo "easyTravel READY" && break
done < <(timeout 100 tail -f /tmp/weblauncher.log)

END_TIME="$(date)"
echolog "START_TIME: $START_TIME     END_TIME: $END_TIME "

echo ""
echo "View weblauncher log again with: tail -f /tmp/weblauncher.log"
echo ""

sudo $UNIX_USER_HOME_PATH/showEZtravel.sh