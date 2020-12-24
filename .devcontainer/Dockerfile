# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.154.0/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="bionic"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
 RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && apt-get -y install --no-install-recommends build-essential \
     && git clone https://github.com/rbenv/ruby-build.git /tmp/ruby-build \
     && PREFIX=/usr/local /tmp/ruby-build/install.sh
#     && apt install ruby-full -v
#     && gem install test-kitchen \
#     && gem install kitchen-terraform -v 5.6.0
