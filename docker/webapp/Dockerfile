FROM baseimage

EXPOSE 8001

WORKDIR /src

COPY ./django/stockpicker/stockpicker /src/stockpicker
COPY ./django/stockpicker/tickers /src/tickers
COPY ./django/stockpicker/manage.py /src/manage.py

COPY ./docker/scripts/initialize-webapp.sh /src/entrypoint.sh
RUN chmod 755 /src/entrypoint.sh
ENTRYPOINT ["/src/entrypoint.sh"]