# Set environment.
export MW_HOME=/tpsys/weblogic
export WLS_HOME=$MW_HOME/wlserver_10.3
export WL_HOME=$WLS_HOME
export JAVA_HOME=/tpsys/weblogic/$JAVA16_HOME
export PATH=$JAVA_HOME/bin:$PATH
export DOMAIN_HOME=/tpsys/weblogic/user_projects/domains/base_domain

. $DOMAIN_HOME/bin/setDomainEnv.sh

# Create the managed servers.
java weblogic.WLST /tpsys/weblogic/weblogicinstall/create_managed_server.py -p /tpsys/weblogic/weblogicinstall/ManagedServer.properties
