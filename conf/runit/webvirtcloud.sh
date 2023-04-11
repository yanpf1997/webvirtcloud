#!/bin/sh
# `/sbin/setuser www-data` runs the given command as the user `www-data`.
cd /srv/webvirtcloud || exit

[ ! -f webvirtcloud/settings.py ] && {
    # 初始化
    . venv/bin/activate && \
    cp webvirtcloud/settings.py.template webvirtcloud/settings.py
    secret_key=$(python3 conf/runit/secret_generator.py)
    sed -i "s/^.*SECRET_KEY.*$/SECRET_KEY=\"${secret_key}\"/" webvirtcloud/settings.py && \
    python3 manage.py makemigrations && \
    python3 manage.py migrate && \
    python3 manage.py collectstatic --noinput && \
    chown -R www-data:www-data /srv/webvirtcloud
}

exec /sbin/setuser www-data /srv/webvirtcloud/venv/bin/gunicorn webvirtcloud.wsgi:application -c /srv/webvirtcloud/gunicorn.conf.py >> /var/log/webvirtcloud.log 2>&1
