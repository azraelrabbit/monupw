# This for mono-opt under ubuntu 14.04.2
FROM ubuntu:14.04.2

MAINTAINER azraelrabbit <azraelrabbit@gmail.com>

#add mono  official source
RUN  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN sh -c "echo 'deb http://download.mono-project.com/repo/debian wheezy main' | sudo tee /etc/apt/sources.list.d/mono-xamarin.list"
RUN  sudo apt-get update 

#Install mono
RUN apt-get update && \
        apt-get install -y --force-yes mono-devel mono-complete referenceassemblies-pcl && \
        apt-get install -y --force-yes openssh-server curl


RUN sudo sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
RUN mkdir -p /var/run/sshd && \
      echo "root:monups" |chpasswd  && \
      useradd admin  &&  echo "admin:monupw" | chpasswd  &&  echo "admin   ALL=(ALL)       ALL" >> /etc/sudoers 

# Fix PAM login issue with sshd
RUN sed -i 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd

#set the PATH for mono-opt
ENV PATH $PATH:/opt/mono/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/opt/mono/lib
ENV PKG_CONFIG_PATH $PKG_CONFIG_PATH:/opt/mono/lib/pkgconfig

# install mono web server Jexus
RUN cd /tmp && curl http://www.daqiao.io/5.6.4/install | sh

RUN mkdir /data && touch /data/x && mkdir /data/jwslog && mkdir /data/siteconf && mkdir /data/wwwroot
#RUN cp /usr/jexus/siteconf/default /data/siteconf/
#RUN cp /usr/jexus/jws.conf /usr/jexus/jws.conf.backup
#RUN sed -i 's/SiteLogDir=log/SiteLogDir=/data/jwslog/g' /usr/jesus/jws.conf && sed -i 's/SiteConfigDir=siteconf/SiteConfigDir=/data/siteconf/g' /usr/jexus/jws.conf
RUN sed -i 's/root=/ /var/www/default/root=/ /data/g' /usr/jexus/siteconf/default

VOLUME ["/data"]

# open port for ssh 
EXPOSE 22  8081  80

# open port for jexus web server
#EXPOSE 8081

# open port for default http 80
#EXPOSE 80


#&& /usr/jexus/jws start
#ENTRYPOINT /usr/sbin/sshd -D 
#CMD    ["/usr/sbin/sshd", "-D"]
CMD  /usr/jexus/jws start && /usr/sbin/sshd -D


