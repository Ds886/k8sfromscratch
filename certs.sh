#!/bin/sh
set -eux
env
set +ue
CURR_VAR=$CA_COUNTRY_NAME
[ -z "${CURR_VAR}" ] && (printf "Variable CA_COUNTRY_NAME is not defined\n please add it to your vars\n" && exit 1)

CURR_VAR=$CA_LOCALITY
[ -z "${CURR_VAR}" ] && (printf "Variable CA_LOCALITY is not defined\n please add it to your vars\n" && exit 1)

# shellcheck disable=2153
CURR_VAR=$CA_ORGANIZATION
[ -z "${CURR_VAR}" ] && (printf "Variable CA_ORGANIZATION is not defined\n please add it to your vars\n" && exit 1)

CURR_VAR=$CA_ORGANIZATION_UNIT
[ -z "${CURR_VAR}" ] && (printf "Variable CA_ORGANIZATION_UNIT is not defined\n please add it to your vars\n" && exit 1)

CURR_VAR=$CA_ALGO
[ -z "${CURR_VAR}" ] && (printf "Variable CA_ALGO is not defined\n please add it to your vars\n" && exit 1)

CURR_VAR=$CA_SIZE
[ -z "${CURR_VAR}" ] && (printf "Variable CA_SIZE is not defined\n please add it to your vars\n" && exit 1)
set -ue


sc_cert_gen_ca()
{
  sys_ensure_folder_or_exit "${BASE_DIR_CERT}"


  cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "${CA_ALGO}",
    "size": ${CA_SIZE}
  },
  "names": [
    {
      "C": "${CA_COUNTRY_NAME}",
      "L": "${CA_LOCALITY}",
      "O": "${CA_ORGANIZATION}",
      "OU": "${CA_ORGANIZATION_UNIT}",
      "ST": "NSW"
    }
  ]
}
EOF

  cfssl gencert -initca ca-csr.json | cfssljson -bare ca
}

sc_cert_gen_simple()
{
  sys_ensure_folder_or_exit "${BASE_DIR_CERT}"
  _FILE=$1
  _ORGANIZATION=$2
  _CN=$3
  [ -z "$_FILE" ] && echo "No file provided for the certificate" && exit 1
  [ -z "$_Organization" ] && echo "No organization provided" && exit 1
  [ -z "$_CN" ] && echo "No CN provide for the certificate" && exit 1
  [ -z "$_RESULT_FILE" ] && echo "No result file provide for the certificate" && exit 1
  _ALGO="${CA_ALGO}"
  _SIZE="${CA_SIZE}"
  _CSR="${_FILE}-csr.json"

  cat > "${_CSR}" <<EOF
{
  "CN": "${_CN}",
  "key": {
    "algo": "${_ALGO}",
    "size": ${_SIZE}
  },
  "names": [
    {
      "C": "${CA_COUNTRY_NAME}",
      "L": "${CA_LOCALITY}",
      "O": "${_ORGANIZATION}",
      "OU": "${CA_ORGANIZATION_UNIT}",
      "ST": "NSW"
    }
  ]
}
EOF

  cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=kubernetes \
    "${_CSR}" | cfssljson -bare "${_FILE}"
  
}

sc_cert_gen_admin()
{
  sc_cert_gen_simple "admin" "system:masters" "admin"
}

sc_cert_gen_client()
{
  _EXTERNAL_IP=$1 # fill in your external IP here
  [ -z "$_EXTERNAL_IP" ] && echo "No external IP provided" && exit 1

  _INTERNAL_IP=$2
  [ -z "$_INTERNAL_IP" ] && echo "No internal IP provided" && exit 1

  _HOSTNAME="$3"
  [ -z "$_HOSTNAME" ] && echo "No hostname provided" && exit 1

  cat > "${_HOSTNAME}-csr.json" <<EOF
{
  "CN": "system:node:${_HOSTNAME}",
  "key": {
    "algo": "${CA_ALGO}",
    "size": ${CA_SIZE}
  },
  "names": [
    {
      "C": "${CA_COUNTRY_NAME}",
      "L": "${CA_LOCALITY}",
      "O": "system:nodes",
      "OU": "${CA_ORGANIZATION_UNIT}",
      "ST": "NSW"
    }
  ]
}
EOF

  # shellcheck disable=2086
  cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${_HOSTNAME},${_EXTERNAL_IP},${_INTERNAL_IP} \
  -profile=kubernetes \
  "${_HOSTNAME}-csr.json" | cfssljson -bare "${_HOSTNAME}"
}

sc_cert_gen_controller_manager()
{
  sc_cert_gen_simple "kube-controller-manager" \
                     "system:kube-controller-manager" \
                     "system:kube-controller-manager" 
}

sc_cert_gen_kube_proxy()
{
  sc_cert_gen_simple "kube-proxy" "system:node-proxier" "system:kube-proxy"
}

sc_cert_gen_scheduler()
{
  sc_cert_gen_simple "kube-scheduler" "system:kube-scheduler" "system:kube-scheduler" 
}

sc_cert_gen_kubeapi()
{
  _EXTERNAL_IP=$1 # fill in your external IP here
  [ -z "$_EXTERNAL_IP" ] && echo "No external IP provided" && exit 1

  _HOSTNAME="$2"
  [ -z "$_HOSTNAME" ] && echo "No hostname provided" && exit 1

  KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

  cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "${CA_ALGO}",
    "size": "${CA_SIZE}"
  },
  "names": [
    {
      "C": "AU",
      "L": "Sydney",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "NSW"
    }
  ]
}
EOF

  cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname="10.32.0.1,10.244.0.11,10.244.0.12,10.244.0.13,${_EXTERNAL_IP},127.0.0.1,${KUBERNETES_HOSTNAMES}" \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
}

sc_cert_gen_serviceaccount()
{
  sc_cert_gen_simple "service-account" "Kubernetes" "service-accounts"
}

sc_cert_distrbute()
{
  echo "TODO: cert distribution"
}
