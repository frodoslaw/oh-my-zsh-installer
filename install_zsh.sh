#!/usr/bin/env bash

set -e

# Install Zsh, Git, Curl, fonts, Python, Node.js, Docker
install_zsh() {
    echo "Installing Zsh and required packages..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y \
            zsh git curl fonts-powerline fonts-firacode python3 python3-venv python3-pip nodejs npm docker.io jq
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y zsh git curl powerline-fonts fira-code-fonts python3 python3-venv python3-pip nodejs npm docker jq
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y zsh git curl powerline-fonts python3 python3-venv python3-pip nodejs npm docker jq
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm zsh git curl powerline-fonts ttf-fira-code python nodejs npm docker jq
    else
        echo "Unsupported package manager. Install Zsh manually."
        exit 1
    fi
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

# Install Oh My Zsh plugins
install_plugins() {
    ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

    # zsh-autosuggestions
    [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

    # zsh-syntax-highlighting
    [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
}

# Install Powerlevel10k theme
install_powerlevel10k() {
    ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
    [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ] && \
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
}

# Configure plugins in .zshrc
configure_plugins_in_zshrc() {
    if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
        sed -i 's/plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
    fi
}

# Apply developer-friendly Powerlevel10k config with error highlighting
apply_dev_powerlevel10k_config() {
    P10K_CONFIG="$HOME/.p10k.zsh"
    if [ ! -f "$P10K_CONFIG" ]; then
        echo "Applying developer-friendly Powerlevel10k configuration..."
        cat > "$P10K_CONFIG" << 'EOF'
# Powerlevel10k developer-friendly configuration
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs python_venv node_version docker time)
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

# Prompt arrows with success/failure colors
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{%(?.green.red)}╭─%f"
typeset -g POWERLEVEL9K_MULTILINE_SECOND_PROMPT_PREFIX="%F{%(?.green.red)}╰─%f "

# Directory display
typeset -g POWERLEVEL9K_DIR_HOME_SUBSTITUTE="~"

# Time format
typeset -g POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S}"

# Git icons
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='🌿 '
typeset -g POWERLEVEL9K_VCS_MODIFIED_ICON='✗'
typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'
typeset -g POWERLEVEL9K_VCS_CONFLICTS_ICON='!'

# Python virtual environment
function prompt_python_venv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "🐍 $(basename $VIRTUAL_ENV)"
    elif command -v conda >/dev/null 2>&1 && conda info --json >/dev/null 2>&1; then
        env=$(conda info --json | jq -r '.active_prefix_name')
        [ "$env" != "base" ] && echo "🐍 $env"
    fi
}

# Node version
function prompt_node_version() {
    if command -v node >/dev/null 2>&1; then
        echo "⬢ $(node -v)"
    fi
}

# Docker status
function prompt_docker() {
    if command -v docker >/dev/null 2>&1; then
        running=$(docker ps -q | wc -l)
        [ "$running" -gt 0 ] && echo "🐳 $running"
    fi
}
EOF
    fi
}

# Change default shell to zsh
set_default_shell() {
    [ "$SHELL" != "$(which zsh)" ] && chsh -s "$(which zsh)"
}

# Main execution
install_zsh
install_oh_my_zsh
install_plugins
install_powerlevel10k
configure_plugins_in_zshrc
apply_dev_powerlevel10k_config
set_default_shell

echo "✅ Developer-ready Zsh installed with error highlighting!"
echo "➡️ Restart terminal: green arrow = success, red arrow = error, plus Git, Python venv, Node, Docker, and time."
