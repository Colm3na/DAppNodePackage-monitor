#!/bin/sh
# Start the first process
nginx > /dev/null 2>&1 & 
/usr/bin/start_service.sh > /dev/null 2>&1 &
/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --web.listen-address=127.0.0.1:9090 &
exec su-exec grafana grafana-server  						\
  --homepath="$GF_PATHS_HOME"                               \
  --config="$GF_PATHS_CONFIG"                               \
  --packaging=docker                                        \
  "$@"                                                      \
  cfg:default.log.mode="console"                            \
  cfg:default.paths.data="$GF_PATHS_DATA"                   \
  cfg:default.paths.logs="$GF_PATHS_LOGS"                   \
  cfg:default.paths.plugins="$GF_PATHS_PLUGINS"             \
  cfg:default.paths.provisioning="$GF_PATHS_PROVISIONING"
