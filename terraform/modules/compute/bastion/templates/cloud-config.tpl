#cloud-config
hostname: ${hostname}
output:
  all: '| tee -a /var/log/cloud-init-output.log'
