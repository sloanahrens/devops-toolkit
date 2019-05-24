FROM baseimage

EXPOSE 8001

WORKDIR /src

COPY ./django/stockpicker /src
COPY ./django/stockpicker/stockpicker/settings/container_settings.py /src/stockpicker/settings/local_settings.py

COPY ./docker/wait-for-it.sh /usr/bin/wait-for-it.sh
RUN chmod 755 /usr/bin/wait-for-it.sh

COPY ./docker/webapp/entrypoint.sh /src/entrypoint.sh
RUN chmod 755 /src/entrypoint.sh

ENTRYPOINT ["/src/entrypoint.sh"]