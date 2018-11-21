consul-base:
  image: consul:1.3.0
  entrypoint:
    - /opt/rancher/bin/start_consul.sh
  net: "container:consul"
  labels:
    io.rancher.container.hostname_override: container_name
    io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=consul-base
  volumes_from:
    - consul-data
consul-data:
  image: alpine:latest
  entrypoint:
    - /bin/true
  labels:
    io.rancher.container.hostname_override: container_name
    io.rancher.container.start_once: true
    io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=consul-data
  volumes:
    - /var/consul
    - /opt/rancher/bin
    - /opt/rancher/ssl
    - /opt/rancher/config
  net: none
consul:
  image: registry.cn-beijing.aliyuncs.com/consul/consul-repo:0.1.6
  labels:
    io.rancher.container.hostname_override: container_name
    io.rancher.sidekicks: consul-base,consul-data
    io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=consul
  volumes_from:
    - consul-data
{{- if eq .Values.ui "true"}}
consul-lb:
  ports:
  - 8500:8500/tcp
  expose:
  - 8500:8500/tcp
  tty: true
  image: rancher/load-balancer-service
  links:
  - consul:consul-base
  stdin_open: true
{{- end }}