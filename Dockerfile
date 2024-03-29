FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive \
    OV_PASSWORD=admin

#Install Prerequisites
RUN apt-get update -y && \
    apt-get install locales -y && \
	export LANGUAGE=en_US.UTF-8 && \
	export LANG=en_US.UTF-8 && \
	export LC_ALL=en_US.UTF-8 && \
	locale-gen en_US.UTF-8 && \
	dpkg-reconfigure locales
	
RUN apt-get install git zip bzip2 net-tools vim \
			wget rsync curl cron \
			nmap \
                        texlive-latex-extra --no-install-recommends \
			gcc cmake gcc-mingw-w64 clang clang-format perl-base \
			pkg-config libssh-gcrypt-dev libgnutls28-dev libglib2.0-dev uuid-dev libldap2-dev \
			libpcap-dev libgpgme-dev bison flex libksba-dev libsnmp-dev libgcrypt20-dev \
			redis-server redis-tools libhiredis-dev libmicrohttpd-dev gettext \
			doxygen xmltoman libfreeradius-dev apt-transport-https haveged \
			heimdal-dev libpopt-dev libxml2-dev libical-dev gnutls-bin xsltproc python3-lxml \
			python-impacket python-polib python3-setuptools python-defusedxml python3-paramiko python3-redis python3-dev \
			texlive-latex-base xmlstarlet nsis gnupg snmp smbclient \
			sqlfairy libsqlite3-dev libpq-dev fakeroot sshpass socat \
			--no-install-recommends --fix-missing -yq && \
	curl --silent --show-error https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -  && \
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
	curl --silent --show-error https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -  && \
	echo "deb https://deb.nodesource.com/node_8.x stretch main" | tee /etc/apt/sources.list.d/nodesource.list && \
	apt update -y && \
	apt-get install nodejs yarn --no-install-recommends --fix-missing -yq && \
	apt autoremove -y && \
	rm -rf /var/lib/apt/lists/*
	
#Build gvm-libs
RUN cd /usr/src && \
	wget -nv https://github.com/greenbone/gvm-libs/archive/v10.0.0.tar.gz && \
	tar -zxf v10.0.0.tar.gz && \
	cd gvm-libs-10.0.0 && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make && \
	make install && \
	rm /usr/src/v10.0.0.tar.gz && \
	rm -rf /usr/src/gvm-libs-10.0.0	

#Build openvas-smb
RUN cd /usr/src && \
	wget -nv https://github.com/greenbone/openvas-smb/archive/v1.0.5.tar.gz && \
	tar -zxf v1.0.5.tar.gz && \
	cd openvas-smb-1.0.5 && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make && \
	make install && \
	rm /usr/src/v1.0.5.tar.gz && \
	rm -rf /usr/src/openvas-smb-1.0.5

#Build openvas
RUN cd /usr/src && \
	wget -nv https://github.com/greenbone/openvas/archive/v6.0.0.tar.gz && \
	tar -zxf v6.0.0.tar.gz && \
	cd openvas-6.0.0 && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make && \
	make install && \
	rm /usr/src/v6.0.0.tar.gz && \
	rm -rf /usr/src/openvas-6.0.0
COPY ./config/openvassd.conf /usr/local/etc/openvas/openvassd.conf
COPY ./config/redis.conf /etc/redis.conf

#Build gsa
RUN cd /usr/src && \
	git clone -b gsa-8.0 https://github.com/bjoernricks/gsa.git && \
	cd gsa && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make && \
	make install && \
	rm -rf /usr/src/gsa

#Build gvmd
RUN cd /usr/src && \
    wget -nv https://github.com/greenbone/gvmd/archive/v8.0.0.tar.gz && \
	tar -zxf v8.0.0.tar.gz && \
	cd gvmd-8.0.0 && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make && \
	make install && \
	rm /usr/src/v8.0.0.tar.gz && \
	rm -rf /usr/src/gvmd-8.0.0

#Build ospd
RUN cd /usr/src && \
    git clone https://github.com/greenbone/ospd.git && \
	cd ospd && \
	git checkout "36027d4c3a74c8bdec2cc49410b3fd0fa4b746c3" && \	
	python3 setup.py install && \
	rm -rf /usr/src/ospd

#Build ospd-openvas
RUN cd /usr/src && \
    git clone https://github.com/greenbone/ospd-openvas.git && \
	cd ospd-openvas && \
	git checkout "3f6d407b1b81c1b8b2d9482847270d74784a3928" && \
	python3 setup.py install && \
	rm -rf /usr/src/ospd-openvas

COPY ./scripts/greenbone-*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/greenbone-*.sh

#RUN /usr/local/bin/greenbone-sync.sh

COPY ./scripts/docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 80 443 9390 9391 9392
