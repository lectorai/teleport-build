# Mirrors upstream build.assets/charts/Dockerfile-distroless, but installs the
# binaries from our release archive instead of upstream's .deb package.
ARG BASE_IMAGE=gcr.io/distroless/cc-debian13

FROM debian:13 AS staging
RUN apt-get update
COPY upstream/build.assets/charts/fetch-debs ./
RUN ./fetch-debs dumb-init libpam0g libaudit1 libcap-ng0

FROM debian:13 AS teleport
ARG RELEASE_ARCHIVE
COPY $RELEASE_ARCHIVE ./
RUN mkdir -p /opt/staging/etc/teleport /opt/staging/usr/local/bin /opt/staging/usr/share/doc/teleport && \
    tar -xzf $RELEASE_ARCHIVE --strip-components=1 -C /opt/staging/usr/local/bin \
        teleport/teleport teleport/tctl teleport/tsh teleport/tbot teleport/fdpass-teleport && \
    tar -xzf $RELEASE_ARCHIVE -O teleport/LICENSE-community > /opt/staging/usr/share/doc/teleport/LICENSE

FROM $BASE_IMAGE
LABEL org.opencontainers.image.licenses="AGPL-3.0-only" \
      org.opencontainers.image.source="https://github.com/lectorai/teleport-build"
COPY --from=teleport /opt/staging /
COPY --from=staging /opt/staging/root /
COPY --from=staging /opt/staging/status /var/lib/dpkg/status.d
ENV TELEPORT_TOOLS_VERSION=off
STOPSIGNAL SIGQUIT
ENTRYPOINT ["/usr/bin/dumb-init", "/usr/local/bin/teleport", "start", "-c", "/etc/teleport/teleport.yaml"]
