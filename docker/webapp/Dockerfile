FROM codeimage

EXPOSE 8001

WORKDIR /src

COPY ./docker/scripts/initialize-webapp-prod.sh /src/entrypoint.sh
RUN chmod 755 /src/entrypoint.sh
ENTRYPOINT ["/src/entrypoint.sh"]