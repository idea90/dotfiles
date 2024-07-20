#!/bin/bash

# Variables
USER=$(whoami)
DOTFILES_DIR="/home/$USER/dotfiles"
TARGET_DIR="/home/$USER/.config"

# List of packages to install
PACKAGES=(
    "firefox"
    "thunar"
    "waybar"
    "alacritty"
    "pywal-16-colors"
    "rofi-lbonn-wayland-git"
    "wlogout"
    "hyprland"
    "mako"
    "zsh"
    "vim"
    "ttf-jetbrains-mono-nerd"
    "swww"
    "git"
    "papirus-icon-theme"
)

# Function to install yay
install_yay() {
    if ! command -v yay &> /dev/null; then
        echo "yay not found. Installing yay..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay || exit
        makepkg -si --noconfirm
        cd - || exit
        rm -rf /tmp/yay
    else
        echo "yay is already installed."
    fi
}

# Function to install packages using yay
install_packages() {
    echo "Installing packages..."
    for package in "${PACKAGES[@]}"; do
        yay -S --noconfirm --needed "$package"
    done
}

# Function to copy config from dotfiles to target directory
copy_config() {
    echo "Copying config from $DOTFILES_DIR to $TARGET_DIR"
    rm -rf .config/hypr
    cp -r "$DOTFILES_DIR/hypr" "$TARGET_DIR"
    cp -r "$DOTFILES_DIR/waybar" "$TARGET_DIR"
    cp -r "$DOTFILES_DIR/rofi" "$TARGET_DIR"
    cp -r "$DOTFILES_DIR/mako" "$TARGET_DIR"
    cp -r "$DOTFILES_DIR/wlogout" "$TARGET_DIR"
    cp -r "$DOTFILES_DIR/swaylock" "$TARGET_DIR"
    cp -r "$DOTFILES_DIR/.vimrc" "/home/$USER"
    cp -r "$DOTFILES_DIR/.zshrc" "/home/$USER"
    cp -r "$DOTFILES_DIR/wallpaper" "/home/$USER"
    wal -i /home/$USER/wallpaper/0001.jpg
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}
# install gtk theme
install_gtk_theme() {
    echo "intalling gtk theme"
    git clone https://github.com/vinceliuice/Graphite-gtk-theme.git
    cd Graphite-gtk-theme
    ./install.sh --tweaks black
    rm -rf Graphite-gtk-theme
}


# Main script execution
install_yay
install_packages
copy_config
install_gtk_theme

read -p "Would you like to reboot the system now? (y/n): " answer
case ${answer:0:1} in
    y|Y )
        echo "Rebooting the system..."
        sudo reboot
    ;;
    * )
        echo "Please reboot the system manually to apply all changes."
    ;;
esac
