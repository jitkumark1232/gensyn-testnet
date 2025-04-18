#!/bin/bash

# Colors for better readability
BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
NC="\e[0m"

SWARM_DIR="$HOME/rl-swarm"
TEMP_DATA_PATH="$SWARM_DIR/modal-login/temp-data"
GENSYN_TESTNET_DIR="$(pwd)"

# Ensure $HOME is set and accessible
if [ -z "$HOME" ] || [ ! -d "$HOME" ]; then
    echo -e "${BOLD}${RED}[✗] HOME directory not set or does not exist. Exiting.${NC}"
    exit 1
fi

cd "$HOME" || {
    echo -e "${BOLD}${RED}[✗] Failed to navigate to HOME directory. Exiting.${NC}"
    exit 1
}

# Debugging HOME variable
echo -e "${BOLD}${YELLOW}HOME directory is: $HOME${NC}"

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

        # Debugging: Check if destination directory exists
        echo -e "${BOLD}${YELLOW}[✓] Cloning the GitHub repository into $SWARM_DIR...${NC}"
        if [ -d "$SWARM_DIR" ]; then
            echo -e "${BOLD}${CYAN}[!] Removing pre-existing directory: $SWARM_DIR...${NC}"
            rm -rf "$SWARM_DIR"
        fi

        # Clone the repo into $SWARM_DIR
        git clone https://github.com/jitkumark1232/rl-swarm.git "$SWARM_DIR" || {
            echo -e "${BOLD}${RED}[✗] Failed to clone repository. Exiting.${NC}"
            exit 1
        }

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

            # Debugging: Check if destination directory exists
            echo -e "${BOLD}${YELLOW}[✓] Cloning the GitHub repository into $SWARM_DIR...${NC}"
            if [ -d "$SWARM_DIR" ]; then
                echo -e "${BOLD}${CYAN}[!] Removing pre-existing directory: $SWARM_DIR...${NC}"
                rm -rf "$SWARM_DIR"
            fi

            git clone https://github.com/jitkumark1232/rl-swarm.git "$SWARM_DIR" || {
                echo -e "${BOLD}${RED}[✗] Failed to clone repository. Exiting.${NC}"
                exit 1
            }
        else
            echo -e "${BOLD}${RED}[✗] No swarm.pem found in /home/rl-swarm. Returning to choices...${NC}"
            continue
        fi
        break

    elif [ "$choice" == "3" ]; then
        # Option 3: Delete swarm.pem and rl-swarm folder
        echo -e "${BOLD}${RED}[✓] Option 3 selected: Deleting existing swarm.pem and starting fresh...${NC}"

        # Delete swarm.pem from gensyn-testnet
        rm -f "$GENSYN_TESTNET_DIR/swarm.pem"

        # Debugging: Check if destination directory exists
        echo -e "${BOLD}${YELLOW}[✓] Checking for rl-swarm directory in $HOME...${NC}"
        rm -rf "$SWARM_DIR"
        echo -e "${BOLD}${CYAN}[✓] Deleted pre-existing rl-swarm directory.${NC}"

        # Clone the repo into $SWARM_DIR
        git clone https://github.com/jitkumark1232/rl-swarm.git "$SWARM_DIR" || {
            echo -e "${BOLD}${RED}[✗] Failed to clone repository. Exiting.${NC}"
            exit 1
        }

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