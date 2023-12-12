#!/bin/sh
set -eux


IMAGE_NAME="kfs"
IMAGE_TAG="test"


podman build . -t "${IMAGE_NAME}":"${IMAGE_TAG}"
podman run  -it "${IMAGE_NAME}":"${IMAGE_TAG}"
