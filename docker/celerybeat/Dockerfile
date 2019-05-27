FROM codeimage

WORKDIR /src

COPY ./docker/celerybeat/entrypoint.sh /src/entrypoint.sh
RUN chmod 755 /src/entrypoint.sh
ENTRYPOINT ["/src/entrypoint.sh"]