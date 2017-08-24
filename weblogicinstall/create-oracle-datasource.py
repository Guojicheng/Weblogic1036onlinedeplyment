# File: create-oracle-datasource.py
# Author: hongxi@rancher.com

# Set the variables
# ======================================================================
import os
dsname1 = os.environ.get('DATASOURCE_NAME')
jndiname1 = os.environ.get('JNDI_NAME')
#dbhost should be something like oracle.abc.com:1521:db
dbhost1 = os.environ.get('DATABASE_HOST')
if (dbhost1 is not None):
  dsurl1 = 'jdbc:oracle:thin:@' + dbhost1
dbuser1 = os.environ.get('DATABASE_USERNAME')
dbpass1 = os.environ.get('DATABASE_PASSWORD')


dsname2 = os.environ.get('DATASOURCE_NAME_2')
jndiname2 = os.environ.get('JNDI_NAME_2')
#dbhost should be something like oracle.abc.com:1521:db
dbhost2 = os.environ.get('DATABASE_HOST_2')
if (dbhost2 is not None):
  dsurl2 = 'jdbc:oracle:thin:@' + dbhost2
dbuser2 = os.environ.get('DATABASE_USERNAME_2')
dbpass2 = os.environ.get('DATABASE_PASSWORD_2')

def set_data_source(dsname, jndiname, dbhost, dsurl, dbuser, dbpass):
  # Read the domain
  # ======================================================================
  domain_path = '/tpsys/weblogic/user_projects/domains/base_domain'
  driver = 'oracle.jdbc.OracleDriver'
  readDomain(domain_path)

  # Create and configure a JDBC Data Source, and set the JDBC user
  # ======================================================================
  cd('/')
  print 'Start JNDI data source configuration' + '\n'
  create(dsname, 'JDBCSystemResource')
  cd('JDBCSystemResource/' + dsname + '/JdbcResource/' + dsname)
  create (dsname, 'JDBCDriverParams')
  cd('JDBCDriverParams/NO_NAME_0')
  set('DriverName', driver)
  set('URL', dsurl)
  set('PasswordEncrypted', dbpass)
  create(dsname, 'Properties')
  cd('Properties/NO_NAME_0')
  create('user', 'Property')
  cd('Property/user')
  cmo.setValue(dbuser)

  cd('/JDBCSystemResource/' + dsname + '/JdbcResource/' + dsname)
  create(dsname, 'JDBCDataSourceParams')
  cd('JDBCDataSourceParams/NO_NAME_0')
  set('JNDIName', java.lang.String(jndiname))

  cd('/JDBCSystemResource/' + dsname + '/JdbcResource/' + dsname)
  create(dsname, 'JDBCConnectionPoolParams')
  cd('JDBCConnectionPoolParams/NO_NAME_0')
  set('TestTableName', 'SQL SELECT 1 FROM DUAL')

  cd('/')
  assign('JDBCSystemResource', dsname, 'Target', 'WebLogicCluster')

  # Update and close the domain
  # ======================================================================
  updateDomain()
  closeDomain()

  print 'Data Source set successfully.' + '\n' 
  return

if (dsname1 is not None) and (jndiname1 is not None) and (dbhost1 is not None) and (dsurl1 is not None) and (dbuser1 is not None) and (dbpass1 is not None):
  print 'Processing the first data source ...' + '\n'
  set_data_source(dsname1, jndiname1, dbhost1, dsurl1, dbuser1, dbpass1);
else:
  print 'Missing parameter for the first data souce, skip configuration.' + '\n'


if (dsname2 is not None) and (jndiname2 is not None) and (dbhost2 is not None) and (dsurl2 is not None) and (dbuser2 is not None) and (dbpass2 is not None):
  print 'Processing the second data source ...' + '\n'
  set_data_source(dsname2, jndiname2, dbhost2, dsurl2, dbuser2, dbpass2);
else:
  print 'Missing parameter for the second data souce, skip configuration.' + '\n'

# Exit WLST
# ===========
exit()
