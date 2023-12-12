#!/bin/sh
set -eux
DATE="$(date)"
printf "[%s] %s - %s\n"  "-" "${DATE}"  "Staring operator cli"
. ./utils.sh
sys_log_trace "Checking dependencies"
. ./deps.sh
sys_log_trace "loading vars"
. ./vars.sh
sys_log_trace "loading certs"
. ./certs.sh

sys_log_trace "success import"

sc_cert_gen_all

