FROM quay.io/centos/centos:stream9
# A cs9 image will expose python3 as /usr/bin/python. It does not contain
# python2. Subsequent layers should install if it needed.
#
# Set install_weak_deps=False to avoid libmaxminddb from pulling in the
# very large geolite databases.

ARG OCP_VERSION=4.13

COPY root/ /

RUN INSTALL_PKGS=" \
      which tar wget hostname util-linux iputils \
      socat tree findutils lsof bind-utils file shadow-utils \
      iproute centos-release-nfv-openvswitch \
      gzip procps-ng rsync iproute diffutils python3 \
      python-unversioned-command" && \
    echo 'skip_missing_names_on_install=0' >> /etc/yum.conf && \
    echo "${OCP_VERSION}" > /etc/yum/vars/ocpversion && \
    dnf install --nodocs --setopt=insatll_weak_deps=False -y ${INSTALL_PKGS} && \
    dnf clean all && rm -rf /var/cache/* && \
    mkdir -p /var/lib/origin

# Enable x509 common name matching for golang 1.15 and beyond.
# Enable madvdontneed=1, for golang < 1.16 https://github.com/golang/go/issues/42330
ENV GODEBUG=x509ignoreCN=0,madvdontneed=1

LABEL io.k8s.display-name="OKD Base CS9" \
      io.k8s.description="This is the base image from which all OpenShift CS9 images inherit."
