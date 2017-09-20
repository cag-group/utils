#!/usr/bin/env bash
set -e
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <namespace>"
    exit 1
fi
namespace=$1

# Generate basic auth credentials for all users
bash basic-auth-checker-credentials-generate.sh \
  u1 \
  u2 \
  > basic-auth-checker-credentials.json

kubectl create namespace ${namespace} > /dev/null 2>&1 || true
kubectl -n ${namespace} delete secret api-credentials 2> /dev/null || true
kubectl -n ${namespace} create secret generic api-credentials --from-file=basic-auth-checker-credentials.json
