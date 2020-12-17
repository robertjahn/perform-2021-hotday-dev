#!/bin/bash
## Commands for Ubuntu Server 18.04 LTS
## These script will install the following components:
# - Chromium for the Load generation of the EasyTravel Angular Shop 
# - Java default-jre
# - EasyTravel, Legacy 8080,8079 / Angular 9080 and 80 / WebLauncher 8094 / EasyTravel REST 8091 1697
# - nginx proxy Docker image that is setup & run to redirect to expose and map port 80 to 9080 

if ! [ $(id -u) = 0 ]; then
   echo "ERROR: script must be run as root or with sudo"
   exit 1
fi

START_TIME="$(date)"
LOGFILE='/tmp/installEZtravel.log' 
echolog()
(
    echo "$@"
    echo "$@" >> $log_file_name
)

echolog "Starting EZ Travel Install @ $START_TIME"
# this is a way to support overrides
if [ -z $UNIX_USER_HOME_PATH ]; then
  UNIX_USER_HOME_PATH=/home/dtu_training/perform-2021-hotday-dev/cloud-migration/ez
fi
if [ -z $UNIX_USER ]; then
  UNIX_USER=dtu_training
fi

echolog "Init Installation"
{ date ; apt update; whoami ; } >> $LOGFILE ; chmod 777 $LOGFILE

echolog "*** Add .bash_aliases file ***"
echo "
# Alias for ease of use of the CLI
alias hg='history | grep' 
alias h='history' 
alias k='kubectl'
alias vaml='vi -c \"set syntax:yaml\" -' 
alias vson='vi -c \"set syntax:json\" -' 
alias pg='ps -aux | grep' " > /home/$UNIX_USER/.bash_aliases

echolog "Install Chromium on the system"
apt install chromium-browser -y >> $LOGFILE 2>&1

echolog "Add Docker NGINX ReverseProxy files"
# mapping 9080 to 80 avoid problems on student browsers that 
# can hit non-standard ports
export PUBLIC_IP=`hostname -i | awk '{ print $1'}`
mkdir -p $UNIX_USER_HOME_PATH/nginx/classic
mkdir -p $UNIX_USER_HOME_PATH/nginx/angular

echo "upstream classic {
  server        $PUBLIC_IP:8079;
}
server {
  listen                0.0.0.0:80;
  server_name   localhost;
  location / {
    proxy_pass  http://classic;
    }
}" > $UNIX_USER_HOME_PATH/nginx/classic/classic.conf
echo "upstream angular {
  server        $PUBLIC_IP:9079;
}
server {
  listen                0.0.0.0:80;
  server_name   localhost;
  location / {
    proxy_pass  http://angular;
    }
}" > $UNIX_USER_HOME_PATH/nginx/angular/angular.conf

echolog "Install default-jre"
apt install -y openjdk-8-jre-headless >> $LOGFILE 2>&1

echolog "Download, install and configure EasyTravel"
{ cd $UNIX_USER_HOME_PATH ;\
 wget -nv -O dynatrace-easytravel-linux-x86_64.jar http://dexya6d9gs5s.cloudfront.net/latest/dynatrace-easytravel-linux-x86_64.jar ;\
 java -jar dynatrace-easytravel-linux-x86_64.jar -y ;\
 chmod 755 -R easytravel-2.0.0-x64 ; }  >> $LOGFILE 2>&1  

echolog "Adjust permissions for $UNIX_USER user"
usermod -a -G docker $UNIX_USER >> $LOGFILE 2>&1
usermod -a -G sudo $UNIX_USER >> $LOGFILE 2>&1
chown $UNIX_USER:$UNIX_USER -R easytravel-2.0.0-x64 >> $LOGFILE 2>&1 

echolog "Configuring EasyTravel Settings"
sed -i 's/apmServerDefault=Classic/apmServerDefault=APM/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
sed -i 's/config.frontendJavaopts=-Xmx160m/config.frontendJavaopts=-Xmx320m/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
sed -i 's/config.backendJavaopts=-Xmx64m/config.backendJavaopts=-Xmx320m/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
sed -i 's/config.autostart=/config.autostart=Standard with REST Service and Angular2 frontend/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
sed -i 's/config.autostartGroup=/config.autostartGroup=UEM/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties

sed -i 's/config.baseLoadDefault=20/config.baseLoadDefault=30/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
sed -i 's/config.baseLoadB2BRatio=0.1/config.baseLoadB2BRatio=0/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
#sed -i 's/config.baseLoadCustomerRatio=0.25/config.baseLoadCustomerRatio=0.15/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
#sed -i 's/config.baseLoadMobileNativeRatio=0.1/config.baseLoadMobileNativeRatio=0/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
#sed -i 's/config.baseLoadMobileBrowserRatio=0.25/config.baseLoadMobileBrowserRatio=0.15/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
sed -i 's/config.baseLoadHotDealServiceRatio=0.25/config.baseLoadHotDealServiceRatio=0/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
sed -i 's/config.baseLoadIotDevicesRatio=0.1/config.baseLoadIotDevicesRatio=0/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
sed -i 's/config.baseLoadHeadlessAngularRatio=0.0/config.baseLoadHeadlessAngularRatio=0.15/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
sed -i 's/config.baseLoadHeadlessMobileAngularRatio=0.0/config.baseLoadHeadlessMobileAngularRatio=0.15/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties

sed -i 's/config.maximumChromeDrivers=10/config.maximumChromeDrivers=3/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
sed -i 's/config.maximumChromeDriversMobile=10/config.maximumChromeDriversMobile=3/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
sed -i 's/config.reUseChromeDriverFrequency=4/config.reUseChromeDriverFrequency=3/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties
#sed -i 's/config.angularFrontendPortRangeStart=9080/config.angularFrontendPortRangeStart=80/g' /easytravel-2.0.0-x64/resources/easyTravelConfig.properties

MY_PUBLIC_IP=$(curl -s  http://checkip.amazonaws.com) && echo "MY PUBLIC IP = $MY_PUBLIC_IP"
sudo sed -i 's/config.thirdpartyUrl=http:\/\/${config.thirdpartyHost}:${config.thirdpartyPort}\//config.thirdpartyUrl=http:\/\/'"$MY_PUBLIC_IP"':${config.thirdpartyPort}\//g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties

echolog "Fix finding the Java package path"
sed -i "s/JAVA_BIN=..\\/jre\\/bin\\/java/JAVA_BIN=\\/usr\\/bin\\/java/g" $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/weblauncher/weblauncher.sh

END_TIME="$(date)"
echolog "*** EZ Travel Install Done *** "
echolog "START_TIME: $START_TIME     END_TIME: $END_TIME "

echo ""
echo "View log with: tail -f $LOGFILE"
echo ""
echo "calling startEZtravel"
sudo $UNIX_USER_HOME_PATH/startEZtravel.sh
