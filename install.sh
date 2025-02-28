#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status

# Define variables
INSTALL_DIR="$HOME/.local/bin"
EXECUTABLE_NAME="textenc"
REPO_URL="https://github.com/b1kr3m/text-encrypter.git"

# Function to display error messages and exit
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# Function to install dependencies (for Debian-based systems)
install_dependencies() {
  if command -v apt-get &>/dev/null; then
    echo "Installing dependencies..."
    sudo apt-get update || error_exit "Failed to update package list"
    sudo apt-get install -y openssl git || error_exit "Failed to install dependencies"
  else
    echo "Warning: apt-get not found. Please install OpenSSL and Git manually."
  fi
}

# Function to clone the repository
clone_repository() {
  echo "Cloning repository..."
  git clone "$REPO_URL" "$HOME/text-encrypter" || error_exit "Failed to clone repository"
  cd "$HOME/text-encrypter" || error_exit "Failed to change directory"
}

# Function to set necessary permissions
set_permissions() {
  echo "Setting permissions..."
  chmod +x textenc.sh || error_exit "Failed to set executable permissions"
}

# Function to install the script globally in ~/.local/bin
install_script() {
  echo "Installing $EXECUTABLE_NAME..."
  mkdir -p "$INSTALL_DIR"
  cp global.sh "$INSTALL_DIR/$EXECUTABLE_NAME" || error_exit "Failed to copy script to $INSTALL_DIR"
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
  install_dependencies
  clone_repository
  set_permissions
  install_script
  update_path
  echo "Installation complete. Run '$EXECUTABLE_NAME' from anywhere to start."
}

# Execute the main function
main