#!/bin/bash
set -x
ARCH=$(uname -m)

detect_architecture() {
    if [[ "$ARCH" == "x86_64" ]]; then
        echo "Detected architecture: x86_64"
        KUBECTL_BIN="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        MINIKUBE_BIN="minikube-linux-amd64"
        
    elif [[ "$ARCH" == "aarch64" ]]; then
        echo "Detected architecture: arm64"
        KUBECTL_BIN="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
        MINIKUBE_BIN="minikube-linux-arm64"
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi
}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ -f /etc/lsb-release || -f /etc/debian_version ]]; then
        echo "Installing neccesary packages..."
        sudo apt update -y && sudo apt install git gettext

        echo "Installing Nodejs 20..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
        echo "Installed Node.js version:"
        node -v

        echo "Installing Docker..."
        sudo apt update -y
        sudo apt install -y \
            ca-certificates \
            curl \
            gnupg \
            lsb-release

        # Add Docker’s official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        # Set up the stable repository for Docker
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker Engine
        sudo apt update -y
        sudo apt install -y docker-ce
        sudo systemctl enable docker
        sudo usermod -aG docker $USER

        # Allowing interacting with http Docker repo
        sudo cp setups/docker-registry/daemon.json /etc/docker/
        sudo systemctl restart docker

        echo "Installing kubectl & minikube..."
        detect_architecture
        curl -LO $KUBECTL_BIN
        sudo install kubectl /usr/local/bin
        rm kubectl
        curl -LO https://storage.googleapis.com/minikube/releases/latest/$MINIKUBE_BIN
        sudo install $MINIKUBE_BIN /usr/local/bin/minikube
        rm $MINIKUBE_BIN

        echo "Installing Terraform..."
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install terraform

        echo "Installing Nginx to expose service publicly..."
        sudo apt install -y nginx
        sudo cp setups/nginx/default.conf /etc/nginx/conf.d/ && sudo rm -rf /etc/nginx/sites-enabled/* /etc/nginx/sites-available/*
        sudo systemctl restart nginx

        echo "Starting Minikube..."
        sudo su $USER -c ./setups/minikube_init.sh


    elif [ -f /etc/redhat-release ]; then
        echo "Installing neccesary packages..."
        sudo yum install git gettext

        echo "Installing Nodejs 20..."
        curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
        sudo yum install -y nodejs
        echo "Installed Node.js version:"
        node -v

        echo "Installing Docker..."
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl start docker
        sudo systemctl enable docker

        echo "Docker version:"
        docker --version

        # Allowing interacting with http Docker repo
        sudo cp setups/docker-registry/daemon.json /etc/docker/
        sudo systemctl restart docker

        echo "Installing kubectl & minikube..."
        detect_architecture
        curl -LO $KUBECTL_BIN
        sudo install kubectl /usr/local/bin
        rm kubectl
        curl -LO https://storage.googleapis.com/minikube/releases/latest/$MINIKUBE_BIN
        sudo install $MINIKUBE_BIN /usr/local/bin/minikube
        rm $MINIKUBE_BIN

        echo "Installing Terraform..."
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
        sudo yum -y install terraform

        echo "Installing Nginx to expose service publicly..."
        sudo yum install -y nginx
        sudo cp setups/nginx/default.conf /etc/nginx/conf.d/ && sudo rm -rf /etc/nginx/sites-enabled/* /etc/nginx/sites-available/*
        sudo systemctl restart nginx

        echo "Starting Minikube..."
        sudo su $USER -c ./setups/minikube_init.sh

    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then 
    # Check if Brew is available
    if ! command -v brew &> /dev/null; then
        echo "Brew not yet available, installing Brew..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "Installing Nodejs 20..."
    brew install node@20
    echo "Installed Node.js version:"
    node -v

    echo "Installing Docker on MacOS..."
    brew install --cask docker

    echo "Installing kubectl & minikube..."
    detect_architecture
    curl -LO $KUBECTL_BIN
    sudo install kubectl /usr/local/bin
    rm kubectl
    brew install minikube

    echo "Installing Terraform..."
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
else
    echo "OS not supported"
    exit 1
fi

# # Start Jenkins
# echo "Starting Jenkins..."
# cd setups/jenkins && docker compose up -d