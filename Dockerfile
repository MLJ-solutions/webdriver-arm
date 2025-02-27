ARG DEBIAN_VERSION=bullseye

FROM --platform=${BUILDPLATFORM} debian:${DEBIAN_VERSION}

ARG CHROMEDRIVER_VERSION
ARG CHROMIUM_VERSION

RUN test -n "$CHROMEDRIVER_VERSION" || (echo "ERROR: CHROMEDRIVER_VERSION is required" && exit 1)
RUN test -n "$CHROMIUM_VERSION" || (echo "ERROR: CHROMIUM_VERSION is required" && exit 1)

RUN apt update
RUN apt -y upgrade
RUN apt -y install ca-certificates tzdata locales
RUN echo 'UTC' | tee /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
RUN apt install -y --no-install-recommends --no-install-suggests libnss3 p11-kit libgtk-3-0 libgl1-mesa-glx libegl1-mesa gsettings-desktop-schemas unzip
RUN apt install -y curl gnupg wget
RUN mkdir -p /var/lib/locales/supported.d/
RUN grep UTF-8 /usr/share/i18n/SUPPORTED > /var/lib/locales/supported.d/all

RUN wget https://github.com/electron/electron/releases/download/${CHROMEDRIVER_VERSION}/chromedriver-${CHROMEDRIVER_VERSION}-linux-arm64.zip
RUN unzip chromedriver-${CHROMEDRIVER_VERSION}-linux-arm64.zip
RUN mv chromedriver /usr/local/bin/chromedriver
RUN chmod +x /usr/local/bin/chromedriver

RUN apt install -y chromium=${CHROMIUM_VERSION}

RUN apt clean && rm -rf /tmp/* && rm -rf /var/tmp/* && rm -Rf /var/lib/apt/lists/*

COPY init /usr/local/sbin/init

USER 4096:4096
EXPOSE 4444
ENTRYPOINT ["chromedriver", "--port=4444"]
