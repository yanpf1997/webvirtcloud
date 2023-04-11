FROM phusion/baseimage:jammy-1.0.1

EXPOSE 80
EXPOSE 6080

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]


RUN echo 'APT::Get::Clean=always;' >> /etc/apt/apt.conf.d/99AutomaticClean

RUN apt-get update -qqy \
    && DEBIAN_FRONTEND=noninteractive apt-get -qyy install \
	--no-install-recommends \
	git \
	python3-venv \
	python3-dev \
	python3-lxml \
	libvirt-dev \
	zlib1g-dev \
	nginx \
	pkg-config \
	gcc \
	libldap2-dev \
	libssl-dev \
	libsasl2-dev \
	libsasl2-modules \
	sudo \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /srv/webvirtcloud
RUN chown -R www-data:www-data /srv/webvirtcloud

# Setup webvirtcloud
WORKDIR /srv/webvirtcloud
RUN python3 -m venv venv && \
	. venv/bin/activate && \
	pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple -U pip && \
	pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple wheel && \
	pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple -r conf/requirements.txt && \
	pip3 cache purge && \
	chown -R www-data:www-data /srv/webvirtcloud

# RUN . venv/bin/activate && \
# 	python3 manage.py makemigrations && \
#     python3 manage.py migrate && \
# 	python3 manage.py collectstatic --noinput && \
# 	chown -R www-data:www-data /srv/webvirtcloud

# Setup Nginx
RUN printf "\n%s" "daemon off;" >> /etc/nginx/nginx.conf && \
	rm /etc/nginx/sites-enabled/default && \
	chown -R www-data:www-data /var/lib/nginx

COPY conf/nginx/webvirtcloud.conf /etc/nginx/conf.d/

# Register services to runit
RUN	mkdir /etc/service/nginx && \
	mkdir /etc/service/nginx-log-forwarder && \
	mkdir /etc/service/webvirtcloud && \
	mkdir /etc/service/novnc
COPY conf/runit/nginx				/etc/service/nginx/run
COPY conf/runit/nginx-log-forwarder	/etc/service/nginx-log-forwarder/run
COPY conf/runit/novncd.sh			/etc/service/novnc/run
COPY conf/runit/webvirtcloud.sh		/etc/service/webvirtcloud/run

# Define mountable directories.
#VOLUME []

WORKDIR /srv/webvirtcloud
