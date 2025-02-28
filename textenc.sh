#!/bin/bash

# Colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
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
    shift
    local color="$1"
    shift
    
    echo -e "${color}${BOX_CORNER_TL}$(printf "%0.s${BOX_HORIZONTAL}" $(seq 1 $((width - 2))))${BOX_CORNER_TR}${RESET}"
    for line in "$@"; do
        printf "${color}${BOX_VERTICAL} %-*s ${color}${BOX_VERTICAL}${RESET}\n" $((width - 4)) "$line"
    done
    echo -e "${color}${BOX_CORNER_BL}$(printf "%0.s${BOX_HORIZONTAL}" $(seq 1 $((width - 2))))${BOX_CORNER_BR}${RESET}"
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
 
               [[  @b1kr3m   ]]
               
EOF

# Encryption Functions
aes_encrypt() {
    local text="$1"
    echo -n "$text" | openssl enc -aes-256-cbc -salt -pbkdf2 -a
}

des_encrypt() {
    local text="$1"
    echo -n "$text" | openssl enc -des-cbc -salt -pbkdf2 -a 2>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "${RED}DES encryption failed. DES is not supported by your OpenSSL version.${RESET}"
        exit 1
    fi
}

rsa_encrypt() {
    local text="$1"
    if [[ ! -f private.pem || ! -f public.pem ]]; then
        openssl genpkey -algorithm RSA -out private.pem
        openssl rsa -pubout -in private.pem -out public.pem
        echo -e "${GREEN}RSA keys generated: private.pem, public.pem${RESET}"
    fi
    echo -n "$text" | openssl pkeyutl -encrypt -pubin -inkey public.pem | base64
}

blowfish_encrypt() {
    local text="$1"
    echo -n "$text" | openssl enc -bf-cbc -salt -pbkdf2 -a
}

# Algorithm selection
# draw_box 40 "${GREEN}" "===== Algorithms =====" "${YELLOW}" "1. AES" "2. DES" "3. RSA" "4. Blowfish"
echo -e "${GREEN}╔══════════════════════════════════════╗"
echo -e "║ ===== Algorithms =====               ║"
echo -e "║ ${YELLOW}1. AES${RESET}                               ║"
echo -e "║ ${YELLOW}2. DES${RESET}                               ║"
echo -e "║ ${YELLOW}3. RSA${RESET}                               ║"
echo -e "║ ${YELLOW}4. Blowfish${RESET}                          ║"
echo -e "${GREEN}╚══════════════════════════════════════╝${RESET}"
read -p "$(echo -e "${BLUE}Choose algorithm (1-4): ${RESET}")" algo

case $algo in
    1) algorithm="aes";;
    2) algorithm="des";;
    3) algorithm="rsa";;
    4) algorithm="blowfish";;
    *)
        draw_box 40 "${RED}" "Invalid algorithm!"
        exit 1
        ;;
esac

# Text input
draw_box 40 "${BLUE}" "Enter text to encrypt:"
read -p "$(echo -e "${BLUE}>> ${RESET}")" input_text

# Perform encryption
case $algorithm in
    "aes") encrypted_text=$(aes_encrypt "$input_text") ;;
    "des") encrypted_text=$(des_encrypt "$input_text") ;;
    "rsa") encrypted_text=$(rsa_encrypt "$input_text") ;;
    "blowfish") encrypted_text=$(blowfish_encrypt "$input_text") ;;
esac

# Display encrypted text
if [ -n "$encrypted_text" ]; then
    echo -e "${GREEN}Encrypted Text:${RESET}"
    echo -e "${CYAN}$encrypted_text${RESET}"
else
    draw_box 40 "${RED}" "Encryption failed!"
fi
