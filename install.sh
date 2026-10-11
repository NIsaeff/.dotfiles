#!/bin/bash
# ~/dotfiles/install.sh

echo "🚀 Installing dotfiles..."

# List of packages to install
packages=(
    "hyprland"
    "waybar" 
    "kitty"
    "rofi"
    "dunst"
    "zsh"
    "git"
    "nvim"
    "gtk"
    "fontconfig"
)

# Install each package
for package in "${packages[@]}"; do
    if [ -d "$package" ]; then
        echo "📦 Installing $package configuration..."
        stow "$package"
    else
        echo "⚠️  Package $package not found, skipping..."
    fi
done

echo "✅ Dotfiles installation complete!"
echo "🔄 You may need to restart your session or reload configurations."
