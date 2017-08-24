#!/bin/bash -x
# Replace the IP 172.17.x.x with 10.42.x.x in the hosts file
SELF_IP=`curl -s http://rancher-metadata/latest/self/container/ips/0`
sudo rm -f /etc/hosts.old
sudo cp /etc/hosts /etc/hosts.old
sudo /bin/sed -i "s/.*`hostname`/${SELF_IP} `hostname`/g" /etc/hosts.old
sudo cp -f /etc/hosts.old /etc/hosts

# Update the create-wls-domain.py file
/bin/sed -i "s/^.*cmo.setPassword.*$/cmo.setPassword('${base_domain_default_password}')/" /tpsys/weblogic/weblogicinstall/create-wls-domain.py
/bin/sed -i "s/^.*ListenAddress.*$/set('ListenAddress','${SELF_IP}')/" /tpsys/weblogic/weblogicinstall/create-wls-domain.py
/bin/sed -i "s/^.*ListenPort.*$/set('ListenPort',${AdminPort})/" /tpsys/weblogic/weblogicinstall/create-wls-domain.py

# Init the base domain
startfile="/tpsys/weblogic/user_projects/domains/base_domain/startWebLogic.sh"
if [ ! -f "$startfile" ] 
then
    /tpsys/weblogic/wlserver_10.3/common/bin/wlst.sh -skipWLSModuleScanning /tpsys/weblogic/weblogicinstall/create-wls-domain.py
fi
##################################################################################################################
# Start Weblogic Server or Managed Server

if [ "$Server_Role" = 'Admin1' ] &&  [ ! -f /tpsys/weblogic/weblogicinstall/.passwordseted ]; then
  mkdir -p /tpsys/weblogic/user_projects/domains/base_domain/servers/AdminServer/security/
  echo "username=weblogic" >> /tpsys/weblogic/user_projects/domains/base_domain/servers/AdminServer/security/boot.properties
  echo "password=${base_domain_default_password}" >> /tpsys/weblogic/user_projects/domains/base_domain/servers/AdminServer/security/boot.properties
  touch /tpsys/weblogic/weblogicinstall/.passwordseted
fi
if [ "$Server_Role" = 'Admin1' ]; then
  /tpsys/weblogic/weblogicinstall/createapp.sh &
  /tpsys/weblogic/user_projects/domains/base_domain/startWebLogic.sh
fi

##############################################################################################################
## start Managerd weblogic node

if [ "$Server_Role" = 'Managed1' ] &&  [ ! -f /tpsys/weblogic/weblogicinstall/.passwordseted ]; then
   mkdir -p /tpsys/weblogic/user_projects/domains/base_domain/servers/`hostname`/security/
   echo "username=weblogic" >> /tpsys/weblogic/user_projects/domains/base_domain/servers/`hostname`/security/boot.properties
   echo "password=${base_domain_default_password}" >>/tpsys/weblogic/user_projects/domains/base_domain/servers/`hostname`/security/boot.properties
   touch /tpsys/weblogic/weblogicinstall/.passwordseted
fi
if [ "$Server_Role" = 'Managed1' ]; then
    
    /bin/sed -i "s/^.*admin.password=.*$/admin.password=${base_domain_default_password}/" /tpsys/weblogic/weblogicinstall/ManagedServer.properties
    /bin/sed -i "s/^.*admin.url=.*$/admin.url=t3:\/\/AdminServer1:${AdminPort}/" /tpsys/weblogic/weblogicinstall/ManagedServer.properties
    /bin/sed -i "s/^.*ms.address=.*$/ms.address=${SELF_IP}/g" /tpsys/weblogic/weblogicinstall/ManagedServer.properties
    /bin/sed -i "s/^.*ms.name=.*$/ms.name=${HOSTNAME}/g" /tpsys/weblogic/weblogicinstall/ManagedServer.properties

    /bin/sed -i "s/^.*WLS_USER=.*$/WLS_USER=\"weblogic\"/" /tpsys/weblogic/user_projects/domains/base_domain/bin/startManagedWebLogic.sh
    /bin/sed -i "s/^.*WLS_PW=.*$/WLS_PW=\"${base_domain_default_password}\"/" /tpsys/weblogic/user_projects/domains/base_domain/bin/startManagedWebLogic.sh

    /tpsys/weblogic/weblogicinstall/register_managed_server.sh
export USER_MEM_ARGS="-Xms1024m -Xmx1024m -Xmn768m -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC -XX:+HeapDumpOnOutOfMemoryError -verbose:gc -Xloggc:./logs/USSDappserver1_gc.out -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Dweblogic.threadpool.MinPoolSize=100 -Dweblogic.threadpool.MaxPoolSize=300"
    /tpsys/weblogic/user_projects/domains/base_domain/bin/startManagedWebLogic.sh $HOSTNAME http://AdminServer1:$AdminPort
fi
