# > Simple usage:
# > docker-compose build
# > Iniciamos el contenedor con:
# > docker-compose up

# Cosmos binaries image builder
FROM alpine AS monitor-build

# Set up dependencies
ENV PACKAGES wget

# Set  versions
ENV PROMETHEUS_VERSION 2.15.2
ENV NODE_EXPORTER_VERSION 0.18.1
ENV GRAFANA_VERSION=6.6.0

# Install minimum necessary dependencies, build Cosmos SDK, remove packages
RUN apk add --no-cache $PACKAGES 

# Set working directory for the build
#WORKDIR /usr/src/app

# Add source files from repo
RUN mkdir /tmp/grafana \
  && mkdir /tmp/prometheus \
  && mkdir /tmp/node_exporter \
  && wget -P /tmp/ https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
  && tar xfz /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz --strip-components=1 -C /tmp/prometheus \
  && wget -P /tmp/ https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz \
  && tar xfz /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz --strip-components=1 -C /tmp/node_exporter \
  && wget -P /tmp/ https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz \
  && tar xfz /tmp/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz --strip-components=1 -C /tmp/grafana

########## LAST STAGE #########
FROM nginx:alpine

ENV EXTRA_PKG curl jq bash vim

RUN apk add --no-cache $EXTRA_PKG

ENV PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

WORKDIR $GF_PATHS_HOME 

COPY --from=monitor-build /tmp/prometheus/prometheus /usr/local/bin/prometheus
COPY --from=monitor-build /tmp/node_exporter/node_exporter /usr/local/bin/node_exporter

RUN set -ex \
    && addgroup -S grafana \
    && adduser -S -G grafana grafana \
    && apk add --no-cache libc6-compat ca-certificates su-exec bash

COPY --from=monitor-build /tmp/grafana "$GF_PATHS_HOME"
RUN mkdir -p "$GF_PATHS_PROVISIONING/datasources" \
        "$GF_PATHS_PROVISIONING/dashboards" \
        "$GF_PATHS_PROVISIONING/notifiers" \
        "$GF_PATHS_LOGS" \
        "$GF_PATHS_PLUGINS" \
        "$GF_PATHS_DATA" \
    && chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING" \
    && chmod -R 777 "$GF_PATHS_DATA" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING"



# Copy default config

RUN mkdir /etc/prometheus
COPY config/prometheus.yml /etc/prometheus/
COPY config/nginx.conf /etc/nginx/
COPY config/grafana.ini /etc/grafana/grafana.ini

#  Copy startup scripts
##############################################################################
COPY start_script.sh start_service.sh /usr/bin/
RUN chmod +x /usr/bin/start_script.sh

#  Start
###############################################################################
# Run gaiad by default, omit entrypoint to ease using container with gaiacli
EXPOSE 80 9090 3000
ENTRYPOINT start_script.sh
