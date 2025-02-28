#!/bin/bash

# Initialize paths
LOG_FILE="logs/encryption.log"

# Colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
RESET='\e[0m'

# Box drawing characters
BOX_HORIZONTAL="═"
BOX_VERTICAL="║"
BOX_CORNER_TL="╔"
BOX_CORNER_TR="╗"
BOX_CORNER_BL="╚"
BOX_CORNER_BR="╝"

# Function to draw a box
draw_box() {
    local width="$1"
    local text="$2"
    local color="$3"
    local padding=2

    # Top border
    echo -e "${color}${BOX_CORNER_TL}$(printf "%0.s${BOX_HORIZONTAL}" $(seq 1 $((width-2))))${BOX_CORNER_TR}${RESET}"

    # Text line
    echo -e "${color}${BOX_VERTICAL}${RESET} $(echo -e "${text}" | sed -e :a -e "s/^.\{1,$((width-4))\}$/ & /;ta") ${color}${BOX_VERTICAL}${RESET}"

    # Bottom border
    echo -e "${color}${BOX_CORNER_BL}$(printf "%0.s${BOX_HORIZONTAL}" $(seq 1 $((width-2))))${BOX_CORNER_BR}${RESET}"
}

# ASCII Art
echo -e "${CYAN}"
cat << "EOF"
  _                  _   ________                  
 / |_               / |_|_   __  |                 
`| |-'.---.  _   __`| |-' | |_ \_| _ .--.   .---.  
 | | / /__\\[ \ [  ]| |   |  _| _ [ `.-. | / /'`\] 
 | |,| \__., > '  < | |, _| |__/ | | | | | | \__.  
 \__/ '.__.'[__]`\_]\__/|________|[___||__]'.___.' 
                                               
EOF
echo -e "${RESET}"

# Encryption Functions

# AES Encryption
aes_encrypt() {
    local text="$1"
    echo -n "$text" | openssl enc -aes-256-cbc -salt -pbkdf2 -a
}

# DES Encryption
des_encrypt() {
    local text="$1"
    echo -n "$text" | openssl enc -des-cbc -salt -a
}

# RSA Encryption
rsa_encrypt() {
    local text="$1"
    # Generate RSA keys if they don't exist
    if [[ ! -f private.pem || ! -f public.pem ]]; then
        openssl genpkey -algorithm RSA -out private.pem
        openssl rsa -pubout -in private.pem -out public.pem
        echo -e "${GREEN}RSA keys generated: private.pem, public.pem${RESET}"
    fi
    echo -n "$text" | openssl pkeyutl -encrypt -pubin -inkey public.pem | base64
}

# Blowfish Encryption
blowfish_encrypt() {
    local text="$1"
    echo -n "$text" | openssl enc -bf-cbc -salt -a
}

# Algorithm selection
draw_box 40 "${GREEN}===== Algorithms =====" "${GREEN}"
draw_box 40 "${YELLOW}1. AES\n${YELLOW}2. DES\n${YELLOW}3. RSA\n${YELLOW}4. Blowfish" "${YELLOW}"
read -p "$(echo -e "${BLUE}Choose algorithm (1-4): ${RESET}")" algo

case $algo in
    1) algorithm="aes";;
    2) algorithm="des";;
    3) algorithm="rsa";;
    4) algorithm="blowfish";;
    *)
        draw_box 40 "${RED}Invalid algorithm!${RESET}" "${RED}"
        exit 1
        ;;
esac

# Text input
draw_box 40 "${BLUE}Enter text to encrypt: ${RESET}" "${BLUE}"
read -p "$(echo -e "${BLUE}>> ${RESET}")" input_text

# Perform encryption
case $algorithm in
    "aes")
        encrypted_text=$(aes_encrypt "$input_text")
        ;;
    "des")
        encrypted_text=$(des_encrypt "$input_text")
        ;;
    "rsa")
        encrypted_text=$(rsa_encrypt "$input_text")
        ;;
    "blowfish")
        encrypted_text=$(blowfish_encrypt "$input_text")
        ;;
esac

# Display encrypted text
draw_box 40 "${GREEN}Encrypted Text:${RESET}" "${GREEN}"
echo -e "${CYAN}$encrypted_text${RESET}"

# Logging
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Algorithm=$algorithm Input=\"${input_text:0:10}...\" Encrypted=\"${encrypted_text:0:10}...\"" >> "$LOG_FILE"
