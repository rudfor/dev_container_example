# This is a local copy of FW_DOCKER ansible for debugging only
###### BASE IMAGE ########
FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

LABEL maintainer="Example For you"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

###### BASE TOOLS ########
# hadolint ignore=DL3008
RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        apt-utils \
        apt-transport-https \
        ca-certificates \
        gnupg \
        openssh-client \
        lsb-release \
        sudo \
        sshpass \
        wget \
        curl \
        less \
        nano \
        bzip2 && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Install Azure Cloud requirements
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=script
# Debian Specific (Ubuntu)
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

CMD [ "/bin/bash" ]

# Update these to your specifications
ENV COMPANY=company
ENV GENERIC_USER=generic_user

# Prep For Tool Install
RUN groupadd --gid 1000 ${COMPANY}
RUN useradd -u 1500 -g 1000 toolinstall --create-home
RUN useradd -u 1200 -g 1000 ${GENERIC_USER} --create-home
RUN mkdir -p /opt

###### CONDA INSTALL #####
# Leave these args here to better use the Docker build cache
ARG CONDA_VERSION=py311_23.5.2-0

# derived from anacondas official docker image
RUN set -x && \
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh"; \
    SHA256SUM="634d76df5e489c44ade4085552b97bebc786d49245ed1a830022b0b406de5817"; \
    wget "${MINICONDA_URL}" -O miniconda.sh -q && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
    if [ "${CONDA_VERSION}" != "latest" ]; then sha256sum --check --status shasum; fi && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

ENV PATH /opt/conda/bin:$PATH

###### CONDA ACTIVATE ####
# Enable Conda to be default for the primary user
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN chown toolinstall:${COMPANY} -R /opt && \
    chmod g=u -R /opt

###### TOOL INSTALL #####
USER toolinstall
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# INSTALL ANSIBLE and tools

# just tool very simple command line executor ... just run X
RUN conda install -c conda-forge just==1.14.0
# ansible core and base tooling
RUN conda install -c conda-forge ansible==8.3.0 --yes
# ansible linting tool
RUN conda install -c conda-forge ansible-lint==6.18.0 --yes
# Sphinx toolstack for documentation writing
RUN conda install -c conda-forge sphinx=7.2.6
# Unit testing for ansible
RUN pip install molecule-docker==2.1.0
# breathe allows doxygen XML exported content to be integrated into RST
RUN pip install breathe==4.35.0
# optional for ansible remote controlling of windows
RUN pip install pywinrm[credssp]==0.4.3 

###### Set to non root user #####
USER ${GENERIC_USER}
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc