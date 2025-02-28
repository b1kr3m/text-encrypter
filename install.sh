#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status

# Define variables
INSTALL_DIR="$HOME/.local/bin"
EXECUTABLE_NAME="textenc"
REPO_URL="https://github.com/b1kr3m/text-encrypter.git"
REPO_DIR="$HOME/text-encrypter"

# Function to display error messages and exit
error_exit() {
  echo -e "\e[31mError: $1\e[0m" >&2
  exit 1
}

# Function to display success messages
success_msg() {
  echo -e "\e[32m$1\e[0m"
}

# Function to install dependencies (for Debian-based systems)
install_dependencies() {
  if command -v apt-get &>/dev/null; then
    echo "Installing dependencies..."
    sudo apt-get update || error_exit "Failed to update package list"
    sudo apt-get install -y openssl git || error_exit "Failed to install dependencies"
  else
    echo "Warning: apt-get not found. Please install OpenSSL and Git manually."
    echo "For Arch Linux: sudo pacman -S openssl git"
    echo "For macOS: brew install openssl git"
  fi
}

# Function to clone the repository
clone_repository() {
  if [[ -d "$REPO_DIR" ]]; then
    echo "Repository already exists at $REPO_DIR. Updating..."
    cd "$REPO_DIR" || error_exit "Failed to change directory"
    git pull || error_exit "Failed to update repository"
  else
    echo "Cloning repository..."
    git clone "$REPO_URL" "$REPO_DIR" || error_exit "Failed to clone repository"
    cd "$REPO_DIR" || error_exit "Failed to change directory"
  fi
}

# Function to check if textenc.sh exists
check_textenc_sh() {
  if [[ ! -f "$REPO_DIR/textenc.sh" ]]; then
    error_exit "textenc.sh not found in the repository!"
  fi
}

# Function to set necessary permissions
set_permissions() {
  echo "Setting permissions..."
  chmod +x "$REPO_DIR/textenc.sh" || error_exit "Failed to set executable permissions"
}

# Function to install the script globally in ~/.local/bin
install_script() {
  echo "Installing $EXECUTABLE_NAME..."
  mkdir -p "$INSTALL_DIR" || error_exit "Failed to create $INSTALL_DIR"
  cp "$REPO_DIR/textenc.sh" "$INSTALL_DIR/$EXECUTABLE_NAME" || error_exit "Failed to copy script to $INSTALL_DIR"
  chmod +x "$INSTALL_DIR/$EXECUTABLE_NAME" || error_exit "Failed to set executable permissions"
}

# Function to add ~/.local/bin to PATH if not already included
update_path() {
  if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "Adding $INSTALL_DIR to PATH..."
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >>"$HOME/.bashrc"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >>"$HOME/.zshrc"
    source "$HOME/.bashrc" || source "$HOME/.zshrc"
  fi
}

# Main function to execute installation steps
main() {
  echo "Starting installation of $EXECUTABLE_NAME..."
  install_dependencies
  clone_repository
  check_textenc_sh
  set_permissions
  install_script
  update_path
  success_msg "Installation complete. Run '$EXECUTABLE_NAME' from anywhere to start."
}

# Execute the main function
main
