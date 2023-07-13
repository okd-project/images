# This is a community version of the openshift-golang-builder definition from
# https://github.com/openshift/ocp-build-data/blob/golang-1.18/images/openshift-golang-builder.Dockerfile
# They should be kept in sync.

FROM quay.io/centos/centos:stream9

ARG GOPATH

ENV container=oci \
    GOFLAGS='-mod=vendor' \
    GOPATH=${GOPATH:-/go} \
    GOMAXPROCS=8 \
    NVM_DIR=/usr/local/nvm \
    NODE_VERSION=14.21.3

ENV NODE_PATH=${NVM_DIR}/v${NODE_VERSION}/lib/node_modules \
    PATH=/go/bin:/opt/app-root/src/node_modules/.bin:${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}

COPY root/ /

RUN set -x; mkdir -p /go/src/ \
    && yum install -y yum-utils centos-release-okd-4.14 \
    && yum-config-manager --enable '*' \
    && yum-config-manager --save \
        --setopt=install_weak_deps=False \
        --setopt=skip_missing_names_on_install=False \
        --setopt=*.skip_if_unavailable=True \
    && yum upgrade --refresh -y \
    && yum install -y \
        bc file findutils gpgme git hostname lsof make socat tar tree util-linux wget which zip \
        gcc-toolset-12 go-toolset openssl openssl-devel \
        systemd-devel gpgme-devel libassuan-devel golang-github-josephspurrier-goversioninfo \
    && yum clean all \
    && chmod +x /usr/bin/*

RUN mkdir -p "${NVM_DIR}" && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash \
   && source $NVM_DIR/nvm.sh \
   && nvm install $NODE_VERSION

WORKDIR /opt/app-root/src

LABEL \
        io.k8s.description="This is a golang builder image for building OKD components." \
        summary="This is a golang builder image for building OKD components." \
        io.k8s.display-name="okd-golang-builder" \
        maintainer="The OKD Maintainers <maintainers@okd.io>" \
        name="okd/golang-builder" \
        io.openshift.tags="openshift"
