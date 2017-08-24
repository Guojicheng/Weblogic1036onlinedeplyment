FROM centos:6.8
MAINTAINER jicheng <guojc@wise2c.com>
# 编码设置
ENV LANG=en_US.UTF-8  \
    LANGUAGE=en_US:en  \
    LC_ALL=en_US.UTF-8
#查看语言支持列表
RUN localedef --list-archive    #精简locale  \
   && cd /usr/lib/locale/  && mv locale-archive locale-archive.old  && localedef -i en_US -f UTF-8 en_US.UTF-8  # 添加中文支持（可选） \   
   && localedef -i zh_CN -f UTF-8 zh_CN.UTF-8  && localedef -i zh_CN -f GB2312 zh_CN  && localedef -i zh_CN -f GB2312 zh_CN.GB2312 && localedef -i zh_CN -f GBK zh_CN.GBK \#下面这些也是可选的，可以>丰富中文支持（香港/台湾/新加坡）\
   && localedef -f UTF-8 -i zh_HK zh_HK.UTF-8 && localedef -f UTF-8 -i zh_TW zh_TW.UTF-8  && localedef -f UTF-8 -i zh_SG zh_SG.UTF-8  && localedef -i zh_CN -f GB18030 zh_CN.GB18030 ##安装jdk \
   && mkdir -p /tpsys/weblogic

RUN groupadd weblogic && useradd -g weblogic weblogic && echo "weblogic:weblogic" | chpasswd \
  && curl -o sudo-1.8.6p3-27.el6.x86_64.rpm  http://10.1.117.145:807/weblogic/sudo-1.8.6p3-27.el6.x86_64.rpm  \
  && rpm -ivh sudo-1.8.6p3-27.el6.x86_64.rpm \
  && rm -rf sudo-1.8.6p3-27.el6.x86_64.rpm \
  && echo "weblogic ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers

COPY weblogicinstall/* /tpsys/weblogic/weblogicinstall/  
WORKDIR /home/weblogic/
RUN  mkdir -p /tpsys/weblogic/beainstall  \
 &&  chmod -R 755 /tpsys/weblogic/  \
 &&  curl -o jdk-6u45-linux-x64.bin http://10.1.117.145:807/weblogic/jdk-6u45-linux-x64.bin  \
 &&  chmod a+x  jdk-6u45-linux-x64.bin  \
 &&  /bin/bash ./jdk-6u45-linux-x64.bin  \
 &&  mv jdk1.6.0_45 /tpsys/weblogic/jdk1.6.0_45 \
 &&  rm -rf jdk-6u45-linux-x64.bin 
# &&  echo "export JAVA_HOME=/tpsys/weblogic/jdk1.6.0_45/" >>/home/weblogic/.bash_profile \
# &&  echo "export CLASSPATH=.:/tpsys/weblogic/jdk1.6.0_45/lib/dt.jar:/tpsys/weblogic/jdk1.6.0_45/lib/tools.jar"  >>/home/weblogic/.bash_profile \
# &&  echo "export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/tpsys/weblogic/jdk1.6.0_45/bin " >> /home/weblogic/.bash_profile  \
# &&  chmod 755 /tpsys/weblogic/jdk1.6.0_45/bin/* && source /home/weblogic/.bash_profile  

ENV JAVA_HOME /tpsys/weblogic/jdk1.6.0_45/  \
    CLASSPATH ".:/tpsys/weblogic/jdk1.6.0_45/lib/dt.jar:$JAVA_HOME/lib/tools.jar" \
    PATH   $PATH:/tpsys/weblogic/jdk1.6.0_45/bin  

#ENV PATH $PATH:/=/tpsys/weblogic/jdk1.6.0_45/bin:/tpsys/weblogic/oracle_common/common/bin:/tpsys/weblogic/user_projects/domains/base_domain/bin

#### install weblogic for slient mode , and create domain
RUN curl -o wls1036_generic.jar http://10.1.117.145:807/weblogic/wls1036_generic.jar  &&  chmod -R 755 /tpsys/weblogic && /tpsys/weblogic/jdk1.6.0_45/bin/java  -jar wls1036_generic.jar -mode=silent -silent_xml=/tpsys/weblogic/weblogicinstall/silent.xml -log=/tpsys/weblogic/weblogicinstall/silent.log   &&  rm wls1036_generic.jar /tpsys/weblogic/weblogicinstall/silent.xml && rm -rf wls1036_generic.jar && chown -R weblogic:weblogic /tpsys/  &&  chmod -R 0777 /tpsys/
#RUN  chmod +x /entrypoint.sh && chmod +x /tpsys/weblogic/weblogicinstall/*.sh
ENV CONFIG_JVM_ARGS '-Djava.security.egd=file:/dev/./urandom'
CMD ["/tpsys/weblogic/weblogicinstall/entrypoint.sh"]
#ADD applications  /tpsys/applications/
USER weblogic
