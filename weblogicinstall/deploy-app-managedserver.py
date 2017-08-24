# since   : 2016/06/17
# updated : peng@rancher.com
# ============================
import os
import random
import string
import socket

execfile('/tpsys/weblogic/scripts/commonfuncs.py')

# ManagedServer details
# ======================
msinternal = os.environ.get('RANCHER_IP')
msname = os.environ.get('MS_NAME', 'MS-' + hostname)
mshost = os.environ.get('MS_HOST', msinternal)
msport = os.environ.get('MS_PORT', '8001')
memargs = os.environ.get('USER_MEM_ARGS', '')
enablecluster = os.environ.get('ENABLE_CLUSTER', 'FALSE')

# Application Information
# =======================
appname1 = os.environ.get('APP_NAME_1')
apppath1 = os.environ.get('APP_PATH_1')
appname2 = os.environ.get('APP_NAME_2')
apppath2 = os.environ.get('APP_PATH_2')

# Connect to the AdminServer
# ==========================
connectToAdmin()
print 'Connected to Admin Server' + '\n'

# Change to Edit Mode
# ======================
edit()
startEdit()


# Get the Server Target
# ======================
cd('/')
cd('/Servers/' + msname)
self=cmo

# AppDeployments
# =====================
cd('/')
cd('JDBCSystemResources')
jdbclist=ls(returnMap='true')
print 'Currently deployed JDBC sources are : ' + '\n'
print jdbclist

# Create or modify JDNI datasource 
# ====================================
print 'Start JDNI datasource modifcation ...' + '\n'

if len(jdbclist) >= 1:

# No need to add self to jdbc target list if cluster joined
  if enablecluster == 'TRUE':
    print 'Cluster joined, skip JDBC modifcation' + '\n'

  else:
    print 'try to update jdbc target list ...' + '\n'
    for jdbc in jdbclist:
      print 'Processing jdbc ' + jdbc + '......' + '\n'
      cd(jdbc)
      oldtargets=cmo.getTargets()
      print 'Old jdbc targets are : ' + '\n'
      print oldtargets
      cmo.addTarget(self)
      newtargets=cmo.getTargets()
      print 'New jdbc targets are : ' + '\n'
      print newtargets
      cd('..')

else:
  print 'No JNDI data source configured, skip JNDI modifcation' + '\n'

# AppDeployments
# =====================
cd('/')
cd('AppDeployments')
applist=ls(returnMap='true')
print 'Currently deployed applications are : ' + '\n'
print applist


# Application deployed if applist is not empty
# =============================================
if len(applist) >= 1:

# No need to add self to target list if cluster joined
  if enablecluster == 'TRUE':
    try:
      print 'Application already deployed, try to start ...' + '\n'
      startApplication(appname1)
      startApplication(appname2)
    except:
      print 'Failed to start application' + '\n'
      exit()  

# add self to target list if not cluster joined
  else:
    for app in applist:
      print 'Processing application ' + app + '......' + '\n'
      cd(app)
      oldtargets=cmo.getTargets()
      print 'Old targets are : ' + '\n'
      print oldtargets
      cmo.addTarget(self)
      newtargets=cmo.getTargets()
      print 'New targets are : ' + '\n'
      print newtargets
      cd('..')

else:
  if enablecluster == 'TRUE':
    if (appname1 is not None) and (apppath1 is not None) and os.path.exists(str(apppath1)):
      print 'Start deploying the first application ' + appname1 + ' to cluster' +  '\n' 
      deploy(appname1, apppath1, targets='DockerCluster', stageMode='nostage')
      startApplication(appname1)
    if (appname2 is not None) and (apppath2 is not None) and os.path.exists(str(apppath2)):
      print 'Start deploying the first application ' + appname1 + ' to cluster' +  '\n'
      deploy(appname2, apppath2, targets='DockerCluster', stageMode='nostage')
      startApplication(appname2)
  else:
    if (appname1 is not None) and (apppath1 is not None) and os.path.exists(str(apppath1)):
      print 'Start deploying the first application ' + appname1 + ' to server' +  '\n'
      deploy(appname1, apppath1, targets=msname, stageMode='nostage')
      startApplication(appname1)
    if (appname2 is not None) and (apppath2 is not None) and os.path.exists(str(apppath2)):
      print 'Start deploying the first application ' + appname1 + ' to server' +  '\n'
      deploy(appname2, apppath2, targets=msname, stageMode='nostage')
      startApplication(appname2)

save()
activate()

print 'Completed JNDI and Application modification.' + '\n'

exit() 
