# !/bin/bash
# Author : peng@rancher.com
#

# If .msprovisioned does not exists, container is starting for 1st time
if [ ! -f /tpsys/weblogic/scripts/.msprovisioned ]; then
    MS_PROVISION=1
fi

# export rancher ip
myip=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1 | sed -n 2p)
export RANCHER_IP=$myip

# Provision this managed server only in 1st run
if [ $MS_PROVISION -eq 1 ]; then
  echo '1st start, start provisioning weblogic managed server ...'
#  sleep 45

# Wait for AdminServer to become available for any subsequent operation
  /tpsys/weblogic/scripts/waitForAdminServer.sh
  wlst.sh -skipWLSModuleScanning /tpsys/weblogic/scripts/add-server.py
  wlst.sh -skipWLSModuleScanning /tpsys/weblogic/scripts/deploy-app-managedserver.py
  touch /tpsys/weblogic/scripts/.msprovisioned
fi

WLS_SERVERNAME='MS-'$HOSTNAME
if [ ! -d /tpsys/weblogic/user_projects/domains/base_domain/servers/$WLS_SERVERNAME/security ]; then
    mkdir -p /tpsys/weblogic/user_projects/domains/base_domain/servers/$WLS_SERVERNAME/security
    echo "username=weblogic" > /tpsys/weblogic/user_projects/domains/base_domain/servers/$WLS_SERVERNAME/security/boot.properties
    echo "password=tplife@123" >> /tpsys/weblogic/user_projects/domains/base_domain/servers/$WLS_SERVERNAME/security/boot.properties
fi

/tpsys/weblogic/wlserver_10.3/common/bin/startManagedWebLogic.sh $WLS_SERVERNAME http://wlsadmin:7001

