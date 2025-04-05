ARG DEBIAN_VERSION=bullseye

FROM --platform=${BUILDPLATFORM} debian:${DEBIAN_VERSION}

ARG CHROMIUM_VERSION

RUN test -n "$CHROMIUM_VERSION" || (echo "ERROR: CHROMIUM_VERSION is required" && exit 1)

RUN apt update
RUN apt -y upgrade
RUN apt -y install ca-certificates tzdata locales
RUN echo 'UTC' | tee /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
RUN apt install -y --no-install-recommends --no-install-suggests libnss3 p11-kit libgtk-3-0 libgl1-mesa-glx libegl1-mesa gsettings-desktop-schemas unzip
RUN apt install -y curl gnupg wget
RUN mkdir -p /var/lib/locales/supported.d/
RUN grep UTF-8 /usr/share/i18n/SUPPORTED > /var/lib/locales/supported.d/all

RUN apt install -y chromium-common=${CHROMIUM_VERSION} chromium-driver=${CHROMIUM_VERSION} || (apt list -a chromium && apt list -a chromium-driver && exit 1)

RUN apt clean && rm -rf /tmp/* && rm -rf /var/tmp/* && rm -Rf /var/lib/apt/lists/*

USER 4096:4096
EXPOSE 4444
ENTRYPOINT ["chromedriver", "--port=4444"]
