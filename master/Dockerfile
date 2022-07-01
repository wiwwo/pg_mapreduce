FROM postgres:14
RUN apt-get update && apt-get --assume-yes install vim procps

COPY ./setup-master.sh /docker-entrypoint-initdb.d/setup-master.sh
RUN chmod 0666 /docker-entrypoint-initdb.d/setup-master.sh
