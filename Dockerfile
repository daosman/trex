FROM quay.io/centos/centos:stream9

ARG TREX_VERSION
ENV TREX_VERSION ${TREX_VERSION}

# install requirements
RUN dnf install -y --nodocs git wget procps python3 vim python3-pip pciutils gettext https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && dnf clean all
RUN dnf install -y --nodocs hostname iproute net-tools ethtool nmap iputils perf numactl sysstat htop rdma-core-devel libibverbs libibverbs-devel net-tools dmidecode libatomic tmux && dnf clean all

RUN pip3 install jsonschema pyyaml
WORKDIR /opt/
RUN git clone --branch openshift https://github.com/daosman/bench-trafficgen.git
WORKDIR /opt/bench-trafficgen
# install trex server
RUN ./trafficgen/install-trex.sh --insecure --version=${TREX_VERSION}

ENV TOOLBOX_HOME=/opt/bench-trafficgen/trafficgen/toolbox
