FROM tianon/centos:6.5
MAINTAINER Intern Avenue Dev Team <dev@internavenue.com>

# Install EPEL
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN rpm -Uvh http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-10.noarch.rpm
RUN rpm -Uvh http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm

# Install base stuff.
RUN yum -y install \
	bash-completion \
  inotify-tools \
  pwgen \
  mc \
  Percona-Server-client-56 \
  Percona-Server-server-56 \
  Percona-Server-shared-56 \
  openssh-client \
  openssh-server \
  puppet \
	vim-enhanced \
	tmux \
  screen \
	unzip \
	yum-plugin-fastestmirror 

# Clean up YUM when done.
RUN yum clean all

# Percona does not come with default config file.
ADD etc/my.cnf /etc/my.cnf

# Start MySQL and SSHd by default.
RUN chkconfig --level 345 mysql on
RUN chkconfig --level 345 sshd on
#RUN /etc/init.d/mysql start

# Configure the database to use our data dir.
RUN sed -i -e 's/^datadir\s*=.*/datadir = \/data/' /etc/my.cnf

# Configure MariaDB to listen on any address.
RUN sed -i -e 's/^bind-address/#bind-address/' /etc/my.cnf

EXPOSE 3306 22

ADD scripts /scripts
RUN chmod +x /scripts/start.sh
RUN touch /firstrun

#RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && echo 'root:Ch4ng3M3' | chpasswd

#RUN echo "GRANT USAGE ON *.* TO iasales@localhost IDENTIFIED BY 'SalesTeamRulez'" | mysql
#RUN echo "GRANT USAGE ON *.* TO 'iasales'@'192.168.100.0/255.255.255.0' IDENTIFIED BY 'SalesTeamRulez'" | mysql
#RUN echo "GRANT USAGE ON *.* TO 'iasales'@'192.168.101.0/255.255.255.0' IDENTIFIED BY 'SalesTeamRulez'" | mysql
#RUN echo "GRANT ALL PRIVILEGES ON iasales.* TO 'iasales'@'localhost'" | mysql
#RUN echo "GRANT ALL PRIVILEGES ON iasales.* TO 'iasales'@'192.168.100.0/255.255.255.0'" | mysql
#RUN echo "GRANT ALL PRIVILEGES ON iasales.* TO 'iasales'@'192.168.101.0/255.255.255.0'" | mysql

# Expose our data, log, and configuration directories.
VOLUME ["/data", "/var/log/mysql"]

# Kicking in
CMD ["/scripts/start.sh"]
