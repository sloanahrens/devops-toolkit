FROM codeimage

WORKDIR /src

COPY ./docker/scripts/start-celery-beat.sh /src/entrypoint.sh
RUN chmod 755 /src/entrypoint.sh
ENTRYPOINT ["/src/entrypoint.sh"]