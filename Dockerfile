FROM alpine:latest

RUN apk update && apk add --no-cache python3 py3-pip apache2 apache2-proxy 
RUN python3 -m venv /venv

WORKDIR /app

COPY . /app

RUN /venv/bin/pip install --no-cache-dir -r requirements.txt
RUN /venv/bin/pip install gunicorn

RUN mkdir -p /etc/gunicorn
COPY gunicorn.conf.py /etc/gunicorn/

RUN sed -i 's/#LoadModule\ proxy_module/LoadModule\ proxy_module/' /etc/apache2/httpd.conf && \
    sed -i 's/#LoadModule\ proxy_http_module/LoadModule\ proxy_http_module/' /etc/apache2/httpd.conf && \
    echo "ProxyPass / http://localhost:8000/" >> /etc/apache2/httpd.conf && \
    echo "ProxyPassReverse / http://localhost:8000/" >> /etc/apache2/httpd.conf

EXPOSE 80

CMD ["sh", "-c", "/usr/sbin/httpd -D FOREGROUND & exec /venv/bin/gunicorn --config /etc/gunicorn/gunicorn.conf.py app:app"]
