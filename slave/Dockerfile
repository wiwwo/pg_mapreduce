FROM postgres:14
RUN apt-get update && apt-get --assume-yes install vim procps

COPY ./setup-slave.sh /docker-entrypoint-initdb.d/setup-slave.sh
RUN chmod +x /docker-entrypoint-initdb.d/setup-slave.sh

