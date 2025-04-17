#!/bin/bash

# Define text styles and colors
BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
NC="\e[0m"

# Define paths
SWARM_DIR="$HOME/rl-swarm"
TEMP_DATA_PATH="$SWARM_DIR/modal-login/temp-data"
HOME_DIR="$HOME"

# Ensure process begins only after a valid option is entered
while true; do
    # Display menu choices
    echo -e "${BOLD}${YELLOW}Do you want to:${NC}"
    echo -e "${BOLD}${CYAN}1) Import swarm.pem via source URL (Recommended)${NC}"
    echo -e "${BOLD}${GREEN}2) Use an existing swarm.pem${NC}"
    echo -e "${BOLD}${RED}3) Create a new swarm.pem file${NC}"

    # Prompt user for choice
    read -p $'\e[1mEnter your choice (1, 2, or 3): \e[0m' choice

    if [ "$choice" == "1" ]; then
        # Import swarm.pem via URL
        echo -e "${BOLD}${CYAN}[✓] Importing swarm.pem via source URL...${NC}"
        read -p $'\e[1mEnter the source URL for swarm.pem: \e[0m' SWARM_PEM_URL

        echo -e "${BOLD}${YELLOW}[✓] Downloading swarm.pem from the provided source URL...${NC}"
        mkdir -p "$SWARM_DIR"
        wget -q --show-progress "$SWARM_PEM_URL" -O "$SWARM_DIR/swarm.pem" || {
            echo -e "${BOLD}${RED}[✗] Failed to download swarm.pem. Please check the URL or your internet connection.${NC}"
            continue  # Return to menu if download fails
        }

        echo -e "${BOLD}${YELLOW}[✓] Cloning fresh repository...${NC}"
        cd $HOME && [ -d rl-swarm ] && rm -rf rl-swarm; git clone https://github.com/jitkumark1232/rl-swarm.git > /dev/null 2>&1 || {
            echo -e "${BOLD}${RED}[✗] Failed to clone repository. Exiting.${NC}"
            exit 1
        }

        mv "$SWARM_DIR/swarm.pem" "$HOME_DIR/" 2>/dev/null
        mv "$TEMP_DATA_PATH/userData.json" "$HOME_DIR/" 2>/dev/null
        mv "$TEMP_DATA_PATH/userApiKey.json" "$HOME_DIR/" 2>/dev/null

        rm -rf "$SWARM_DIR"

        mv "$HOME_DIR/swarm.pem" rl-swarm/
        mv "$HOME_DIR/userData.json" rl-swarm/modal-login/temp-data/ 2>/dev/null
        mv "$HOME_DIR/userApiKey.json" rl-swarm/modal-login/temp-data/ 2>/dev/null

        break

    elif [ "$choice" == "2" ]; then
        # Use existing swarm.pem
        if [ -f "$SWARM_DIR/swarm.pem" ]; then
            echo -e "\n${BOLD}${YELLOW}[✓] Using existing swarm.pem...${NC}"
            mv "$SWARM_DIR/swarm.pem" "$HOME_DIR/" 2>/dev/null
            mv "$TEMP_DATA_PATH/userData.json" "$HOME_DIR/" 2>/dev/null
            mv "$TEMP_DATA_PATH/userApiKey.json" "$HOME_DIR/" 2>/dev/null

            rm -rf "$SWARM_DIR"

            echo -e "${BOLD}${YELLOW}[✓] Cloning fresh repository...${NC}"
            cd $HOME && [ -d rl-swarm ] && rm -rf rl-swarm; git clone https://github.com/jitkumark1232/rl-swarm.git > /dev/null 2>&1 || {
                echo -e "${BOLD}${RED}[✗] Failed to clone repository. Exiting.${NC}"
                exit 1
            }

            mv "$HOME_DIR/swarm.pem" rl-swarm/
            mv "$HOME_DIR/userData.json" rl-swarm/modal-login/temp-data/ 2>/dev/null
            mv "$HOME_DIR/userApiKey.json" rl-swarm/modal-login/temp-data/ 2>/dev/null

            break
        else
            echo -e "${BOLD}${RED}[✗] No existing swarm.pem found.${NC}"
            continue
        fi

    elif [ "$choice" == "3" ]; then
        # Create a new swarm.pem file
        echo -e "${BOLD}${YELLOW}[✓] Creating a new swarm.pem file...${NC}"
        mkdir -p "$SWARM_DIR"
        touch "$SWARM_DIR/swarm.pem" || {
            echo -e "${BOLD}${RED}[✗] Failed to create swarm.pem file. Exiting.${NC}"
            continue
        }

        echo -e "${BOLD}${YELLOW}[✓] Cloning fresh repository...${NC}"
        cd $HOME && [ -d rl-swarm ] && rm -rf rl-swarm; git clone https://github.com/jitkumark1232/rl-swarm.git > /dev/null 2>&1 || {
            echo -e "${BOLD}${RED}[✗] Failed to clone repository. Exiting.${NC}"
            exit 1
        }

        mv "$SWARM_DIR/swarm.pem" "$HOME_DIR/" 2>/dev/null
        rm -rf "$SWARM_DIR"

        mv "$HOME_DIR/swarm.pem" rl-swarm/

        break

    else
        echo -e "\n${BOLD}${RED}[✗] Invalid choice. Please enter 1, 2, or 3.${NC}"
    fi
done

cd rl-swarm || {
    echo -e "${BOLD}${RED}[✗] Failed to enter rl-swarm directory. Exiting.${NC}"
    exit 1
}

if [ -n "$VIRTUAL_ENV" ]; then
    echo -e "${BOLD}${YELLOW}[✓] Deactivating existing virtual environment...${NC}"
    deactivate
fi

echo -e "${BOLD}${YELLOW}[✓] Setting up Python virtual environment...${NC}"
python3 -m venv .venv
source .venv/bin/activate || {
    echo -e "${BOLD}${RED}[✗] Failed to activate virtual environment. Exiting.${NC}"
    exit 1
}

echo -e "${BOLD}${YELLOW}[✓] Running rl-swarm...${NC}"
./run_rl_swarm.sh