#!/bin/bash

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
NC="\033[0m"

IS_WSL=false
if grep -q Microsoft /proc/version 2>/dev/null; then
    echo -e "${YELLOW}WSL environment detected${NC}"
    IS_WSL=true
fi

IS_RENTED_SERVER=false
if [ -d "/opt/deeplearning" ] || [ -d "/opt/aws" ] || [ -d "/opt/cloud" ]; then
    echo -e "${YELLOW}Rented GPU server environment detected${NC}"
    IS_RENTED_SERVER=true
fi

echo -e "\n${BLUE}System Information:${NC}"
UBUNTU_VERSION=""
if [ -f /etc/lsb-release ]; then
    source /etc/lsb-release
    UBUNTU_VERSION=$DISTRIB_RELEASE
elif [ -f /etc/os-release ]; then
    source /etc/os-release
    UBUNTU_VERSION=$(echo $VERSION_ID | tr -d '"')
else
    if [ -f /etc/issue ]; then
        UBUNTU_VERSION=$(cat /etc/issue | grep -oP 'Ubuntu \K[0-9]+\.[0-9]+' | head -1)
    fi
fi

if [ -z "$UBUNTU_VERSION" ]; then
    echo -e "${YELLOW}Installing lsb-release to determine system version...${NC}"
    apt-get update >/dev/null 2>&1
    apt-get install -y lsb-release >/dev/null 2>&1
    
    if command -v lsb_release >/dev/null 2>&1; then
        UBUNTU_VERSION=$(lsb_release -rs)
    else
        UBUNTU_VERSION="22.04"
        echo -e "${YELLOW}Could not determine Ubuntu version, defaulting to ${UBUNTU_VERSION}${NC}"
    fi
fi

echo -e "Ubuntu Version: ${CYAN}$UBUNTU_VERSION${NC}"
ARCH=$(uname -m)
echo -e "Architecture: ${CYAN}$ARCH${NC}"

check_nvidia_gpu() {
    echo -e "\n${BLUE}Checking for NVIDIA GPU...${NC}"
    if command -v nvidia-smi &> /dev/null; then
        echo -e "${GREEN}NVIDIA GPU detected via nvidia-smi${NC}"
        echo -e "\n${BLUE}GPU Details:${NC}"
        nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
        return 0
    elif lspci | grep -i nvidia &> /dev/null; then
        echo -e "${GREEN}NVIDIA GPU detected via lspci${NC}"
        if command -v lspci &> /dev/null; then
            echo -e "\n${BLUE}GPU Details:${NC}"
            lspci | grep -i nvidia
        fi
        return 0
    elif [ "$IS_RENTED_SERVER" = true ]; then
        echo -e "${YELLOW}Running on a rented server, assuming GPU is available${NC}"
        return 0
    else
        echo -e "${RED}CPU environment detected - NVIDIA GPU required for CUDA${NC}"
        echo -e "${CYAN}Skipping CUDA installation as no compatible GPU was found${NC}"
        return 1
    fi
}

check_cuda_installed() {
    echo -e "\n${BLUE}Checking for existing CUDA installation...${NC}"

    local cuda_installed=false
    local driver_installed=false
    local cuda_version=""
    local driver_cuda_version=""

    if command -v nvcc &> /dev/null; then
        cuda_installed=true
        cuda_version=$(nvcc --version | grep -oP 'release \K\d+\.\d+' 2>/dev/null || echo "unknown")
        echo -e "${GREEN}CUDA Toolkit version $cuda_version is installed${NC}"
        echo -e "   CUDA Path: $(which nvcc)"
    else
        echo -e "${YELLOW}CUDA Toolkit (nvcc) is not installed${NC}"
    fi

    if command -v nvidia-smi &> /dev/null; then
        driver_installed=true
        driver_cuda_version=$(nvidia-smi | grep -oP 'CUDA Version: \K[0-9.]+' 2>/dev/null || echo "unknown")
        echo -e "${GREEN}NVIDIA driver with CUDA compatibility $driver_cuda_version is installed${NC}"
    else
        echo -e "${YELLOW}NVIDIA driver not found or not loaded${NC}"
    fi

    for cuda_path in /usr/local/cuda* /usr/local/cuda*/bin; do
        if [ -d "$cuda_path" ]; then
            echo -e "${GREEN}CUDA installation found at: ${CYAN}$cuda_path${NC}"
            cuda_installed=true
        fi
    done

    if $cuda_installed; then
        return 0
    else
        return 1
    fi
}

setup_cuda_env() {
    echo -e "\n${BLUE}Setting up CUDA environment variables...${NC}"
    
    local cuda_path=""
    local cuda_version="12.8"
    
    if command -v nvcc &> /dev/null; then
        nvcc_path=$(which nvcc)
        cuda_path=$(dirname $(dirname $nvcc_path))
        cuda_version=$(nvcc --version | grep -oP 'release \K\d+\.\d+' 2>/dev/null || echo "12.8")
    else
        local latest_cuda=""
        for dir in /usr/local/cuda*; do
            if [ -d "$dir" ]; then
                latest_cuda=$dir
            fi
        done
        
        if [ -n "$latest_cuda" ]; then
            cuda_path=$latest_cuda
            cuda_version=$(echo $cuda_path | grep -oP 'cuda-\K\d+\.\d+' || echo "12.8")
        else
            cuda_path="/usr/local/cuda-12.8"
        fi
    fi
    
    echo -e "Using CUDA path: ${CYAN}$cuda_path${NC}"
    
    cat > /etc/profile.d/cuda.sh <<EOL
#!/bin/bash
export PATH=$cuda_path/bin\${PATH:+:\${PATH}}
export LD_LIBRARY_PATH=$cuda_path/lib64\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}
EOL

    chmod +x /etc/profile.d/cuda.sh

    export PATH=$cuda_path/bin${PATH:+:${PATH}}
    export LD_LIBRARY_PATH=$cuda_path/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    
    echo -e "${GREEN}CUDA environment variables configured${NC}"
    echo -e "   Added to: /etc/profile.d/cuda.sh"
    
    return 0
}

install_cuda() {
    echo -e "\n${BLUE}Starting CUDA installation process...${NC}"
    
    local PIN_FILE=""
    local PIN_URL=""
    local DEB_FILE=""
    local DEB_URL=""
    local CUDA_VERSION="12.8"
    
    if [ "$IS_RENTED_SERVER" = true ] && command -v nvidia-smi &> /dev/null; then
        echo -e "${YELLOW}Rented GPU server with NVIDIA drivers detected${NC}"
        echo -e "Would you like to ${CYAN}verify the existing setup${NC} instead of installing? [Y/n]"
        read -r response
        if [[ ! "$response" =~ ^[Nn]$ ]]; then
            echo -e "${GREEN}Skipping installation and verifying existing setup...${NC}"
            return 0
        fi
    fi
    
    if $IS_WSL; then
        echo -e "${CYAN}Configuring for WSL installation...${NC}"
        PIN_FILE="cuda-wsl-ubuntu.pin"
        PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin"
        DEB_FILE="cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb"
        DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb"
    else
        case $UBUNTU_VERSION in
            24.04|"24.04")
                echo -e "${CYAN}Configuring for Ubuntu 24.04...${NC}"
                PIN_FILE="cuda-ubuntu2404.pin"
                PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin"
                DEB_FILE="cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb"
                DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb"
                ;;
            22.04|"22.04")
                echo -e "${CYAN}Configuring for Ubuntu 22.04...${NC}"
                PIN_FILE="cuda-ubuntu2204.pin"
                PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin"
                DEB_FILE="cuda-repo-ubuntu2204-12-8-local_12.8.0-1_amd64.deb"
                DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2204-12-8-local_12.8.0-1_amd64.deb"
                ;;
            20.04|"20.04")
                echo -e "${CYAN}Configuring for Ubuntu 20.04...${NC}"
                PIN_FILE="cuda-ubuntu2004.pin"
                PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin"
                DEB_FILE="cuda-repo-ubuntu2004-12-8-local_12.8.0-1_amd64.deb"
                DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2004-12-8-local_12.8.0-1_amd64.deb"
                ;;
            18.04|"18.04")
                echo -e "${CYAN}Configuring for Ubuntu 18.04...${NC}"
                PIN_FILE="cuda-ubuntu1804.pin"
                PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin"
                DEB_FILE="cuda-repo-ubuntu1804-12-8-local_12.8.0-1_amd64.deb"
                DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu1804-12-8-local_12.8.0-1_amd64.deb"
                ;;
            *)
                echo -e "${YELLOW}Unsupported Ubuntu version: $UBUNTU_VERSION${NC}"
                echo -e "${YELLOW}Using Ubuntu 22.04 configuration...${NC}"
                PIN_FILE="cuda-ubuntu2204.pin"
                PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin"
                DEB_FILE="cuda-repo-ubuntu2204-12-8-local_12.8.0-1_amd64.deb"
                DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2204-12-8-local_12.8.0-1_amd64.deb"
                ;;
        esac
    fi

    echo -e "\n${BLUE}Downloading $PIN_FILE...${NC}"
    if [ -f "$PIN_FILE" ]; then
        rm -f "$PIN_FILE"
    fi
    
    wget --quiet "$PIN_URL" -O "$PIN_FILE" || { 
        echo -e "${RED}Failed to download $PIN_FILE${NC}"
        return 2
    }

    echo -e "${BLUE}Setting up repository preferences...${NC}"
    cp "$PIN_FILE" /etc/apt/preferences.d/cuda-repository-pin-600 || {
        echo -e "${RED}Failed to copy $PIN_FILE to /etc/apt/preferences.d/${NC}"
        return 2
    }

    echo -e "\n${BLUE}Downloading CUDA repository package...${NC}"
    echo -e "Source: $DEB_URL"
    if [ -f "$DEB_FILE" ]; then
        rm -f "$DEB_FILE"
    fi
    
    echo -e "${CYAN}Downloading CUDA installation package...${NC}"
    wget --progress=bar:force "$DEB_URL" -O "$DEB_FILE"
    
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}wget download failed, trying with curl...${NC}"
        if ! command -v curl &> /dev/null; then
            apt-get install -y curl >/dev/null 2>&1
        fi
        curl -L "$DEB_URL" -o "$DEB_FILE" --progress-bar
    fi
    
    if [ ! -f "$DEB_FILE" ] || [ ! -s "$DEB_FILE" ]; then
        echo -e "${RED}Failed to download $DEB_FILE${NC}"
        echo -e "${YELLOW}Trying alternative installation method...${NC}"
        return 2
    fi

    echo -e "\n${BLUE}Installing CUDA repository package...${NC}"
    dpkg -i "$DEB_FILE" || {
        echo -e "${RED}Failed to install $DEB_FILE${NC}"
        return 2
    }

    echo -e "\n${BLUE}Setting up repository keys...${NC}"
    if [ -f /var/cuda-repo-*/cuda-*-keyring.gpg ]; then
        cp /var/cuda-repo-*/cuda-*-keyring.gpg /usr/share/keyrings/ || {
            echo -e "${RED}Failed to copy CUDA keyring${NC}"
            return 2
        }
    fi

    echo -e "\n${BLUE}Updating package list...${NC}"
    apt-get update || {
        echo -e "${RED}Failed to update package list${NC}"
        return 2
    }

    echo -e "\n${BLUE}Installing CUDA Toolkit ${CUDA_VERSION}...${NC}"
    echo -e "${YELLOW}This may take several minutes. Please be patient.${NC}"
    apt-get install -y cuda-toolkit-12-8 || {
        echo -e "${YELLOW}Specific package not found, trying generic cuda...${NC}"
        apt-get install -y cuda || {
            echo -e "${RED}Failed to install CUDA${NC}"
            return 2
        }
    }

    echo -e "\n${BLUE}Cleaning up installation files...${NC}"
    rm -f "$DEB_FILE" "$PIN_FILE"

    echo -e "\n${GREEN}CUDA Toolkit installed successfully!${NC}"
    return 0
}

install_cuda_alternative() {
    echo -e "\n${BLUE}Installing CUDA using apt repository method...${NC}"
    
    local repo_url=""
    local keyring_url=""
    
    if [ "$IS_RENTED_SERVER" = true ] && command -v nvidia-smi &> /dev/null; then
        echo -e "${GREEN}Rented GPU server with NVIDIA drivers detected${NC}"
        echo -e "${YELLOW}Setting up environment variables only...${NC}"
        return 0
    fi
    
    case $UBUNTU_VERSION in
        24.04|"24.04")
            echo -e "${CYAN}Using Ubuntu 24.04 repositories...${NC}"
            repo_url="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/"
            keyring_url="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb"
            ;;
        22.04|"22.04")
            echo -e "${CYAN}Using Ubuntu 22.04 repositories...${NC}"
            repo_url="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/"
            keyring_url="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb"
            ;;
        20.04|"20.04")
            echo -e "${CYAN}Using Ubuntu 20.04 repositories...${NC}"
            repo_url="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/"
            keyring_url="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb"
            ;;
        18.04|"18.04")
            echo -e "${CYAN}Using Ubuntu 18.04 repositories...${NC}"
            repo_url="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/"
            keyring_url="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.1-1_all.deb"
            ;;
        *)
            echo -e "${YELLOW}No specific repository for version $UBUNTU_VERSION, using Ubuntu 22.04...${NC}"
            repo_url="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/"
            keyring_url="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb"
            ;;
    esac
    
    echo -e "\n${BLUE}Installing CUDA apt keyring...${NC}"
    local keyring_file="cuda-keyring.deb"
    
    wget --progress=bar:force "$keyring_url" -O "$keyring_file" || {
        if ! command -v curl &> /dev/null; then
            apt-get install -y curl >/dev/null 2>&1
        fi
        curl -L "$keyring_url" -o "$keyring_file" --progress-bar
    }
    
    if [ ! -f "$keyring_file" ] || [ ! -s "$keyring_file" ]; then
        echo -e "${RED}Failed to download keyring file${NC}"
        return 1
    fi
    
    dpkg -i "$keyring_file" || {
        echo -e "${RED}Failed to install CUDA keyring${NC}"
        return 1
    }
    
    echo -e "\n${BLUE}Updating package list...${NC}"
    apt-get update
    
    echo -e "\n${BLUE}Installing CUDA packages...${NC}"
    echo -e "${YELLOW}This may take several minutes. Please be patient.${NC}"
    
    apt-get install -y cuda-toolkit-12-8 || {
        echo -e "${YELLOW}Specific version not found, trying generic cuda package...${NC}"
        apt-get install -y cuda || {
            echo -e "${RED}Failed to install CUDA packages${NC}"
            return 1
        }
    }
    
    rm -f "$keyring_file"
    
    echo -e "\n${GREEN}CUDA installed via repository method!${NC}"
    return 0
}

verify_cuda() {
    echo -e "\n${BLUE}Verifying CUDA installation...${NC}"
    
    if command -v nvcc &> /dev/null; then
        echo -e "${GREEN}CUDA compiler (nvcc) found:${NC}"
        nvcc --version
        
        if [ "$IS_RENTED_SERVER" = true ]; then
            echo -e "${YELLOW}Skipping test compilation on rented server${NC}"
            return 0
        fi
        
        echo -e "\n${BLUE}Running a simple CUDA test...${NC}"
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        cat > cuda_test.cu << 'EOL'
#include <stdio.h>

__global__ void helloFromGPU() {
    printf("Hello World from GPU!\n");
}

int main() {
    printf("Hello World from CPU!\n");
    
    helloFromGPU<<<1, 1>>>();
    cudaDeviceSynchronize();
    
    return 0;
}
EOL

        echo -e "${BLUE}Compiling test program...${NC}"
        if nvcc cuda_test.cu -o cuda_test; then
            echo -e "${GREEN}Compilation successful!${NC}"
            echo -e "${BLUE}Running test program:${NC}"
            ./cuda_test
            echo -e "\n${GREEN}CUDA verified successfully!${NC}"
        else
            echo -e "${RED}Test compilation failed${NC}"
            echo -e "${YELLOW}This could indicate an issue with the CUDA installation${NC}"
        fi
        
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
    else
        echo -e "${RED}CUDA compiler (nvcc) not found. Installation may have failed${NC}"
        
        for cuda_path in /usr/local/cuda* /usr/local/cuda*/bin; do
            if [ -d "$cuda_path" ]; then
                echo -e "${YELLOW}CUDA installation found at ${CYAN}$cuda_path${NC} but nvcc not in PATH${NC}"
                echo -e "${YELLOW}Setup the environment variables to include this path${NC}"
            fi
        done
        return 1
    fi
    
    return 0
}

main() {
    if ! check_nvidia_gpu; then
        if [ "$IS_RENTED_SERVER" = true ]; then
            echo -e "${YELLOW}Proceeding with setup on rented server despite GPU detection issue...${NC}"
        else
            echo -e "\n${RED}No GPU found - CUDA requires an NVIDIA GPU${NC}"
            exit 1
        fi
    fi
    
    if check_cuda_installed; then
        echo -e "\n${GREEN}CUDA is already installed${NC}"
        echo -e "Would you like to ${YELLOW}reinstall/update${NC} CUDA anyway? [y/N]"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "\n${BLUE}Setting up environment variables for existing installation...${NC}"
            setup_cuda_env
            echo -e "\n${GREEN}All done! CUDA environment is ready${NC}"
            exit 0
        fi
    else
        echo -e "\n${YELLOW}CUDA not installed. Proceeding with installation...${NC}"
    fi
    
    echo -e "\n${BLUE}Starting CUDA installation...${NC}"
    install_cuda
    install_status=$?
    
    if [ $install_status -eq 0 ]; then
        setup_cuda_env
        verify_cuda
        echo -e "\n${GREEN}CUDA installation completed!${NC}"
        echo -e "\n${GREEN}Enjoy your CUDA-enabled environment!${NC}"
    elif [ $install_status -eq 2 ]; then
        echo -e "\n${YELLOW}Primary installation method failed, trying alternative...${NC}"
        install_cuda_alternative
        alt_status=$?
        
        if [ $alt_status -eq 0 ]; then
            setup_cuda_env
            verify_cuda
            echo -e "\n${GREEN}CUDA installation completed!${NC}"
            echo -e "\n${GREEN}Enjoy your CUDA-enabled environment!${NC}"
        else
            echo -e "\n${RED}CUDA installation failed${NC}"
            exit 1
        fi
    else
        echo -e "\n${RED}CUDA installation failed${NC}"
        exit 1
    fi
}

main
