#!/bin/sh -x

IMG="desktopcontainers/tor-browser"

#PLATFORM="linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6"
PLATFORM="linux/amd64"

if [ -z ${DEBIAN_VERSION+x} ] || [ -z ${TOR_BROWSER_VERSION+x} ]; then
  docker-compose build -q --pull --no-cache
  export DEBIAN_VERSION=$(docker run --rm -ti "$IMG" cat /etc/debian_version | tail -n1 | tr -d '\r')
  export TOR_BROWSER_VERSION=$(basename $(dirname $(docker run --rm -ti "$IMG" cat /tor-browser-version | tail -n1)))
fi

if echo "$@" | grep -v "force" 2>/dev/null >/dev/null; then
  echo "check if image was already build and pushed - skip check on release version"
  echo "$@" | grep -v "release" && docker pull "$IMG:d$DEBIAN_VERSION-tb$TOR_BROWSER_VERSION" 2>/dev/null >/dev/null && echo "image already build" && exit 1
fi

docker buildx build -q --pull --no-cache --platform "$PLATFORM" -t "$IMG:d$DEBIAN_VERSION-tb$TOR_BROWSER_VERSION" --push .

echo "$@" | grep "release" 2>/dev/null >/dev/null && echo ">> releasing new latest" && docker buildx build -q --pull --platform "$PLATFORM" -t "$IMG:latest" --push .
