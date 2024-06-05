#!/bin/bash

sudo apt update && sudo apt upgrade -y
cd ~/ && mkdir -p downloads
cd ~/ && mkdir -p projects

sudo apt install -y \
    zsh ca-certificates build-essential \
    curl gnupg software-properties-common \
    python3-dev libpq-dev unzip wget make \
    libreadline-dev libsqlite3-dev xz-utils \
    libssl-dev zlib1g-dev libbz2-dev llvm \
    libncurses5-dev libncursesw5-dev tk-dev \
    apt-transport-https

# Homebrew
## NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/th1alexandre/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install gcc

# Python uv - https://github.com/astral-sh/uv
brew install uv

# Poetry
curl -sSL https://install.python-poetry.org | python3 -
export PATH="/home/th1alexandre/.local/bin:$PATH"

# GitHub CLI
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y

# AWS CLI
cd ~/downloads && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install && cd ~/

# Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

brew update # upgrade terraform
brew upgrade hashicorp/tap/terraform

# Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
docker run hello-world

# python 3.11
cd ~/downloads && wget https://www.python.org/ftp/python/3.11.4/Python-3.11.4.tgz
tar xvf Python-3.11.4.tgz && cd Python-3.11.4
./configure --enable-optimizations --with-ensurepip=install
make -j 8 && sudo make altinstall

# nodejs
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &&\
sudo apt-get install -y nodejs

# kubernetes # with brew just do: brew install kubectl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt-get install -y kubectl

# minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
minikube start

# oh my zsh
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
ln -s .profile .zprofile
[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'
terraform -install-autocomplete

# test all
docker --version && docker compose version && terraform --version && aws --version && poetry --version && brew --version && python3.11 --version && uv --version && minikube version

# cleanup
cat /dev/null > ~/.bash_history
cat /dev/null > ~/.bash_history && history -c && exit
cat /dev/null > ~/.zsh_history
cat /dev/null > ~/.zsh_history && history -c && exit
