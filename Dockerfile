FROM askomics/virtuoso:7.2.5.1
MAINTAINER Xavier Garnier 'xavier.garnier@irisa.fr'


# Environment variables
ENV ASKOMICS_GIT_URL="https://github.com/askomics/askomics.git" \
    ASKOMICS_DIR="/usr/local/askomics" \
    ASKOMICS_GIT_VERSION="19.01.3" \
    SPARQL_UPDATE=true

# Copy files
COPY start.sh /start.sh

# Install prerequisites, clone repository and install
RUN apk update && \
    apk del openssl openssl-dev  && \
    apk add bash make gcc g++ zlib-dev libzip-dev bzip2-dev xz-dev git python3 python3-dev nodejs nodejs-npm wget openldap-dev linux-headers sqlite && \
    git clone ${ASKOMICS_GIT_URL} ${ASKOMICS_DIR} && \
    cd ${ASKOMICS_DIR} && \
    git checkout ${ASKOMICS_GIT_VERSION} && \
    npm install gulp -g && \
    npm install --production && \
    chmod +x startAskomics.sh && \
    rm -rf /usr/local/askomics/venv && \
    bash ./startAskomics.sh -b && \
    rm -rf /var/cache/apk/* && \
    chmod +x /start.sh

WORKDIR /usr/local/askomics/

EXPOSE 6543
CMD ["/start.sh"]
