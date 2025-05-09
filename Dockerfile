FROM mongo:8.0.9-noble


COPY scripts /home/mongodb/scripts
COPY ssl /home/mongodb/ssl
COPY mongod.conf /home/mongodb

WORKDIR /home/mongodb

RUN chmod +x /home/mongodb/scripts/*.sh

CMD ["/bin/bash", "/home/mongodb/scripts/run.sh"]