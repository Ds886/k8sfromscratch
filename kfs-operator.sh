#!/bin/sh
set -eux
DATE="$(date)"
printf "[%s] %s - %s\n"  "-" "${DATE}"  "Staring operator cli"
. ./kfs-utils.sh
sys_log_trace "Checking dependencies"
. ./kfs-deps.sh
sys_log_trace "loading vars"
. ./kfs-vars.sh
sys_log_trace "loading certs"
. ./kfs-certs.sh

sys_log_trace "success import"

sc_cert_gen_all

