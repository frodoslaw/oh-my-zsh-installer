#!/usr/bin/env bash

set -e

# Function to detect package manager and install zsh, git, curl
install_zsh() {
    echo "Installing Zsh and required packages..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y zsh git curl
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y zsh git curl
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y zsh git curl
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm zsh git curl
    else
        echo "Unsupported package manager. Install Zsh manually."
        exit 1
    fi
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "Oh My Zsh already installed."
    fi
}

# Function to install Oh My Zsh plugins
install_plugins() {
    ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        echo "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    else
        echo "zsh-autosuggestions already installed."
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        echo "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    else
        echo "zsh-syntax-highlighting already installed."
    fi

    # Add plugins to .zshrc if not already present
    if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
        sed -i 's/plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
    fi
}

# Change default shell to zsh
set_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "Changing default shell to Zsh..."
        chsh -s "$(which zsh)"
    fi
}

# Main
install_zsh
install_oh_my_zsh
install_plugins
set_default_shell

echo "✅ Zsh, Oh My Zsh, and plugins installed successfully!"
echo "➡️  Restart your terminal or log out and back in to start using Zsh."
