ARG FEDORA_MAJOR_VERSION=38

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}

ADD setup /usr/bin/silverblue-setup
ADD script.sh /tmp/script.sh

RUN /tmp/script.sh
# Cleanup
RUN rm -rf /tmp/* /var/*
# Commit changes
RUN ostree container commit
RUN mkdir -p /var/tmp && chmod -R 1777 /var/tmp