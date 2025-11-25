# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.183.0/containers/ubuntu/.devcontainer/base.Dockerfile

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG USERNAME=vscode
#To list all available versions of terraform, run: 'sudo apt update && apt-cache madison terraform' from inside the container
ARG TF_VERSION=1.10.3-1
ARG NODE_MAJOR=20
#To see all available packages of TFDOCS, go to 'https://github.com/terraform-docs/terraform-docs/releases/''
ARG TFDOCS_VERSION=0.19.0
#To list all available packages of TFSEC, go to 'https://github.com/aquasecurity/tfsec/releases'
ARG TFSEC_VERSION=1.28.11
#To list all available versions of azure-cli, run: 'pip index versions azure-cli' from inside the container
ARG AZCLI_VERSION=2.67.0
#To list all available versions of powershell, run: 'sudo apt update && apt-cache madison powershell' from inside the container
ARG POWERSHELL_VERSION=7.4.6-1.deb
#To list all available versions of powershell, run: 'sudo apt update && apt-cache search dotnet-sdk' from inside the container
ARG DOTNET_SDK_VERSION=8.0
ARG WORKSPACE="/home/$USERNAME/workspace"

WORKDIR ${WORKSPACE}
VOLUME ${WORKSPACE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    dos2unix \
    figlet \
    gawk \
    git \
    gnupg \
    jq \
    less \
    lsb-release \
    nano \
    rsync \
    software-properties-common \
    sudo \
    tree \
    unzip \
    vim \
    wget \
    zsh \
    && update-ca-certificates \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/hashicorp.gpg arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get -y update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    python3-venv \
    python3-pip \
    python-is-python3

# Due to PEP 668 enforcement in Ubuntu 24.04, use a virtual environment for pip installations
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install mdformat-gfm \
    && echo "export PATH=/opt/venv/bin:$PATH" >> /etc/bash.bashrc
ENV PATH="/opt/venv/bin:$PATH"

# Add Terraform
RUN  apt-get -y install --no-install-recommends \
     terraform=$TF_VERSION

# Add Az Cli
RUN pip install --upgrade pip \
    && pip install azure-cli==$AZCLI_VERSION

# Add Terraform Docs
RUN curl -sLo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v${TFDOCS_VERSION}/terraform-docs-v${TFDOCS_VERSION}-$(uname)-amd64.tar.gz \
    && tar -xzf terraform-docs.tar.gz \
    && chmod +x terraform-docs \
    && rm terraform-docs.tar.gz \
    && mv terraform-docs /usr/local/bin/terraform-docs

# Add Tfsec
RUN curl -sLo tfsec.tar.gz https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec_${TFSEC_VERSION}_linux_amd64.tar.gz \
    && tar -xzf tfsec.tar.gz \
    && mv tfsec /usr/local/bin/tfsec \
    && rm tfsec*

# Add Repo
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo \
    && chmod a+x /usr/local/bin/repo

    RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && NODE_MAJOR=${NODE_MAJOR} \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get -y update \
    && apt-get -y install --no-install-recommends nodejs

# Add dotnet
RUN apt-get -y install --no-install-recommends dotnet-sdk-${DOTNET_SDK_VERSION}

# Install Infracost
# Downloads the CLI based on your OS/arch and puts it in /usr/local/bin
RUN curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# Install Powershell
RUN curl -fsSL "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" -o packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends powershell=$POWERSHELL_VERSION

# Add Terraform Sentinel
RUN curl -fsSL "https://releases.hashicorp.com/sentinel/0.22.1/sentinel_0.22.1_linux_amd64.zip" -o sentinel_0.22.1_linux_amd64.zip \
    && unzip sentinel_0.22.1_linux_amd64.zip \
    && rm sentinel_0.22.1_linux_amd64.zip \
    && chmod a+x sentinel \
    && mv sentinel /usr/local/bin/

# Add Azcopy
RUN if [ $(dpkg --print-architecture) = "arm64" ]; \
    then curl -fsSL https://aka.ms/downloadazcopy-v10-linux-arm64 -o azcopy.tar.gz; \
    else curl -fsSL https://aka.ms/downloadazcopy-v10-linux -o azcopy.tar.gz; \
    fi \
    && tar -xvf azcopy.tar.gz \
    && cp ./azcopy*/azcopy /usr/local/bin/ \
    && chmod +x /usr/local/bin/azcopy \
    && rm ./azcopy* -rf

# Clean Apt get list
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install azure-cost-cli
RUN dotnet tool install --global azure-cost-cli

# Install npm check updates
RUN npm i -g npm-check-updates dotenv dotenv-expand is-ci markdownlint-cli node-emoji yaml-lint

