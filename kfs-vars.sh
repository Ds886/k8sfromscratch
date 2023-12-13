#!/bin/sh



export K8S_HOSTS_CONTR_NAME=kcont01
K8S_HOSTS_CONTR_EXTERNAL_IP=$(ip -4 addr|grep inet|grep -v 127.0.0.1|awk '{print $2}'|awk -F/ '{print $1}')
export K8S_HOSTS_CONTR_EXTERNAL_IP
K8S_HOSTS_CONTR_INTERNAL_IP=$(hostname -i)
export K8S_HOSTS_CONTR_INTERNAL_IP

export BASE_DIR=/opt/k8s
export BASE_DIR_CERT="${BASE_DIR}/certs"


export CA_COUNTRY_NAME="IL"
export CA_LOCALITY="LAB01"
export CA_ORGANIZATION="K8SLab"
export CA_ORGANIZATION_UNIT="LAB01"
export CA_ALGO=rsa
export CA_SIZE=4096

