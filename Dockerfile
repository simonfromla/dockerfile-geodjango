FROM python:3

# debian packages: GeoDjango dependencies
RUN apt-get update && \
    apt-get install -y binutils libproj-dev gdal-bin && \
    rm -rf /var/lib/apt/lists/*

# python packages
COPY ./requirements /usr/src/app/requirements
RUN pip install --no-cache-dir -r /usr/src/app/requirements/production.txt

# django apps & manage
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY ./config /usr/src/app/config
COPY ./djangoapp1 /usr/src/app/djangoapp1
COPY ./djangoapp2 /usr/src/app/djangoapp2
COPY ./manage.py /usr/src/app/manage.py

ENV DJANGO_SETTINGS_MODULE=config.settings.production
ENV DATABASE_URL postgis://$DBUSER:$DBPASSWORD@$DBHOST:$DBPORT/$DBNAME
ENV DJANGO_SECRET_KEY=0
ENV DJANGO_AWS_ACCESS_KEY_ID=0
ENV DJANGO_AWS_SECRET_ACCESS_KEY=0
ENV DJANGO_AWS_STORAGE_BUCKET_NAME=0
ENV DJANGO_ADMIN_URL=
ENV MAILGUN_API_KEY=
ENV MAILGUN_DOMAIN=
ENV DJANGO_DEBUG True
ENV DJANGO_SENTRY_DSN=

RUN ./manage.py collectstatic --no-input
# If heroku, no expose
# EXPOSE 8000
RUN adduser --disabled-password myuser
USER myuser

CMD daphne config.asgi:application --port $PORT --bind 0.0.0.0 -v2
# CMD gunicorn config.wsgi:application --port $PORT -b 0.0.0.0