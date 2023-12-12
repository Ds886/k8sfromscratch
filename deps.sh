#!/bin/sh

DEPS_LIST="cfssl cfssljson"

for DEP in $DEPS_LIST; do
  set +ue
  COMM=$(command -v "$DEP")
  if [ -z "${COMM}" ]; then
    sys_log_error "Command ${DEP} is not found"
    exit 1
  fi
  set -ue
done
