#!/bin/bash

# Colors for better readability
BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
NC="\e[0m"

SWARM_DIR="$HOME/rl-swarm"
TEMP_DATA_PATH="$SWARM_DIR/modal-login/temp-data"
HOME_DIR="$HOME"
GENSYN_TESTNET_DIR="$(pwd)"

cd $HOME

# Prompt the user to choose an option
while true; do
    echo -e "${BOLD}${YELLOW}Please choose an option:${NC}"
    echo -e "${BOLD}${CYAN}1) Download swarm.pem via URL${NC}"
    echo -e "${BOLD}2) Use existing swarm.pem from gensyn-testnet${NC}"
    echo -e "${BOLD}${RED}3) Delete existing swarm.pem and start fresh${NC}"
    read -r -p $'\e[1mEnter your choice (1, 2, or 3): \e[0m' choice

    if [ "$choice" == "1" ]; then
        # Option 1: Download via URL
        echo -e "${BOLD}${CYAN}[✓] Option 1 selected: Downloading swarm.pem via URL...${NC}"
        read -r -p $'\e[1mEnter the source URL for swarm.pem: \e[0m' SWARM_PEM_URL

        # Create /home/rl-swarm if it doesn't exist
        mkdir -p "$SWARM_DIR"

        # Download the file
        echo -e "${BOLD}${YELLOW}[✓] Downloading swarm.pem from the provided source URL...${NC}"
        wget -q --show-progress "$SWARM_PEM_URL" -O "$SWARM_DIR/swarm.pem" || {
            echo -e "${BOLD}${RED}[✗] Failed to download swarm.pem. Exiting.${NC}"
            exit 1
        }

        # Clone the repo into /home/rl-swarm
        echo -e "${BOLD}${YELLOW}[✓] Cloning the GitHub repository...${NC}"
        git clone https://github.com/jitkumark1232/gensyn-testnet.git "$SWARM_DIR" > /dev/null 2>&1

        # Move additional files if they exist
        [ -f "$GENSYN_TESTNET_DIR/userData.json" ] && mv "$GENSYN_TESTNET_DIR/userData.json" "$TEMP_DATA_PATH/"
        [ -f "$GENSYN_TESTNET_DIR/userApiKey.json" ] && mv "$GENSYN_TESTNET_DIR/userApiKey.json" "$TEMP_DATA_PATH/"

        # Remove swarm.pem from gensyn-testnet
        rm -f "$GENSYN_TESTNET_DIR/swarm.pem"
        break

    elif [ "$choice" == "2" ]; then
    echo -e "${BOLD}${YELLOW}[✓] Option 2 selected: Checking for swarm.pem in /home/rl-swarm...${NC}"

    # Check if swarm.pem exists in /home/rl-swarm
    if [ -f "$SWARM_DIR/swarm.pem" ]; then
        echo -e "${BOLD}${GREEN}[✓] swarm.pem found in /home/rl-swarm.${NC}"

        # Clone the repo into /home/rl-swarm
        echo -e "${BOLD}${YELLOW}[✓] Cloning the GitHub repository...${NC}"
        git clone https://github.com/jitkumark1232/gensyn-testnet.git "$SWARM_DIR" > /dev/null 2>&1
    else
        echo -e "${BOLD}${RED}[✗] No swarm.pem found in /home/rl-swarm. Returning to choices...${NC}"

        # Restart the option prompt
        continue
    fi
    break

    elif [ "$choice" == "3" ]; then
        # Option 3: Delete swarm.pem and rl-swarm folder
        echo -e "${BOLD}${RED}[✓] Option 3 selected: Deleting existing swarm.pem and starting fresh...${NC}"

        # Delete swarm.pem from gensyn-testnet
        rm -f "$GENSYN_TESTNET_DIR/swarm.pem"

        # Delete swarm.pem from rl-swarm and remove the rl-swarm folder if it exists
        rm -f "$SWARM_DIR/swarm.pem"
        if [ -d "$SWARM_DIR" ]; then
            rm -rf "$SWARM_DIR"
            echo -e "${BOLD}${YELLOW}[✓] Deleted existing rl-swarm folder.${NC}"
        fi

        # Clone the repo into /home/rl-swarm
        echo -e "${BOLD}${YELLOW}[✓] Cloning the GitHub repository...${NC}"
        git clone https://github.com/jitkumark1232/gensyn-testnet.git "$SWARM_DIR" > /dev/null 2>&1

        # Create a fresh swarm.pem file
        touch "$SWARM_DIR/swarm.pem"
        echo -e "${BOLD}${YELLOW}[✓] Created a new swarm.pem file in /home/rl-swarm.${NC}"
        break

    else
        # Handle invalid input
        echo -e "${BOLD}${RED}[✗] Invalid choice. Please enter 1, 2, or 3.${NC}"
    fi
done

# Proceed to the next step
cd "$SWARM_DIR" || { echo -e "${BOLD}${RED}[✗] Failed to enter rl-swarm directory. Exiting.${NC}"; exit 1; }

if [ -n "$VIRTUAL_ENV" ]; then
    echo -e "${BOLD}${YELLOW}[✓] Deactivating existing virtual environment...${NC}"
    deactivate
fi

echo -e "${BOLD}${YELLOW}[✓] Setting up Python virtual environment...${NC}"
python3 -m venv .venv
source .venv/bin/activate