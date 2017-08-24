#!/bin/bash -x
while [ $(netstat -anop | grep ESTABLISHED | grep $AdminPort | wc -l) -lt 2 ] 
do
  echo " managernode need time to runnning"
  sleep 5
done 
echo " now to add managernodes use wlst script online mode"

sleep 80
if [ "$Server_Role" = 'Admin1' ] && [ $DATASOURCE_NAME ] && [ ! -f /tpsys/weblogic/weblogicinstall/.datasourceset ]; then
 echo 'DATA SOURCE provided and not set. Start configuring Data Source ...'
 /tpsys/weblogic/wlserver_10.3/common/bin/wlst.sh -skipWLSModuleScanning /tpsys/weblogic/weblogicinstall/create-datasourceonline.py
 touch /tpsys/weblogic/weblogicinstall/.datasourceset
sleep 20
fi

if [ "$Server_Role" = 'Admin1' ] && [ $DATASOURCE_NAME_2 ] && [ ! -f /tpsys/weblogic/weblogicinstall/.datasourceset2 ]; then
 echo 'DATA SOURCE provided and not set. Start configuring Data Source ...'
 /tpsys/weblogic/wlserver_10.3/common/bin/wlst.sh -skipWLSModuleScanning /tpsys/weblogic/weblogicinstall/create-datasourceonline2.py
 touch /tpsys/weblogic/weblogicinstall/.datasourceset2
sleep 20
fi

if [ "$Server_Role" = 'Admin1' ] && [ ! -f /tpsys/weblogic/weblogicinstall/.deployed ]; then
/tpsys/weblogic/wlserver_10.3/common/bin/wlst.sh -skipWLSModuleScanning /tpsys/weblogic/weblogicinstall/deploy-application.py
touch /tpsys/weblogic/weblogicinstall/.deployed
sleep 20
fi

