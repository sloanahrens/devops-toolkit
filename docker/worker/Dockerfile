FROM baseimage

ENV C_FORCE_ROOT true

WORKDIR /src

COPY ./django/stockpicker /src
COPY ./django/stockpicker/stockpicker/settings/container_settings.py /src/stockpicker/settings/local_settings.py

#COPY ./docker/worker/entrypoint.sh /src/entrypoint.sh
#RUN chmod 755 /src/entrypoint.sh
#
#ENTRYPOINT ["/src/entrypoint.sh"]

CMD celery worker --app=stockpicker.celery --loglevel=info