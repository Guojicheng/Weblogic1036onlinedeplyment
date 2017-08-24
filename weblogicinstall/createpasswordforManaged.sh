#!/bin/bash
  mkdir -p /tpsys/weblogic/user_projects/domains/base_domain/servers/$hostname$/security/
  echo "username=weblogic" >> /tpsys/weblogic/user_projects/domains/base_domain/servers/$hostname$/security/boot.properties
  echo "password=${base_domain_default_password}" >> /tpsys/weblogic/user_projects/domains/base_domain/servers/$hostname$/security/boot.properties
  touch /tpsys/weblogic/weblogicinstall/.passwordseted
