FROM quay.io/centos/centos:stream9

COPY root/ root/

RUN INSTALL_PKGS=" \
      which tar wget hostname util-linux iputils \
      socat tree findutils lsof bind-utils file shadow-utils \
      iproute gzip procps-ng rsync iproute diffutils python3 \
      python-unversioned-command git" && \
    echo 'skip_missing_names_on_install=0' >> /etc/yum.conf && \
    dnf install --nodocs --setopt=install_weak_deps=False -y ${INSTALL_PKGS} && \
    dnf clean all && rm -rf /var/cache/*

RUN set -ex; arch=$(uname -m | sed 's/aarch64/arm64/;s/x86_64/amd64/'); \
    wget -qO /usr/bin/yq "https://github.com/mikefarah/yq/releases/download/v4.32.2/yq_linux_${arch}" && \
    chmod +x /usr/bin/yq

RUN set -ex; arch=$(uname -m | sed 's/aarch64/arm64/;s/x86_64/amd64/'); \
    wget -qO - https://github.com/estesp/manifest-tool/releases/download/v2.0.8/binaries-manifest-tool-2.0.8.tar.gz | \
    tar -C /usr/bin --transform 's/manifest-tool-linux-.*/mtl/' -xvzf - manifest-tool-linux-${arch}

RUN wget -qO - $(curl https://api.github.com/repos/okd-project/okd/releases/latest | \
    yq '.assets | .[] | select(.name|test("openshift-client-linux-'$(uname -m | sed 's/x86_64//;s/aarch64/arm64-/')'4")) | .browser_download_url') | \
    tar -C /usr/bin -xvzf - && rm /usr/bin/README.md

