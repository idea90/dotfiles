#!/bin/bash
#
# This script manages the desktop wallpaper, allowing you to choose from a thumbnail grid
# of images found in the wallpapers directory (default to "$HOME/wallpaper").
#
# Dependencies: rofi, swww, pywal, mako, waybar
# Optional: feh

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
ROFI_CONFIG_DIR="${ROFI_CONFIG_DIR:-$SCRIPT_PATH/config}"
WALLPAPERS_DIR="${WALLPAPERS_DIR:-$HOME/wallpaper}"
WALLPAPER_CACHE="$ROFI_CONFIG_DIR/wallpapers"
GRID_ROWS=${GRID_ROWS:-2}   # Number of rows
GRID_COLS=${GRID_COLS:-6}   # Number of columns

# Function to build rofi theme string
build_theme() {
    rows=$1
    cols=$2
    icon_size=6  # Size of the icon
    echo "element {orientation: vertical;} element-text {horizontal-align: 0.5;} element-icon {size: ${icon_size}.0000em;} listview {lines: ${rows}; columns: ${cols};}"
}
# Check if swww-daemon is running
check_swww_daemon

# Find images and format for rofi
images=$(find "$WALLPAPERS_DIR" -type f -maxdepth 1 -printf "%T@ %f\x00icon\x1f$WALLPAPERS_DIR/%f\n" | sort -rn | cut -d' ' -f2-)

# Show rofi menu and get user's choice
choice=$(echo -en "Random Choice\n$images" | $ROFI_CMD -show-icons -theme-str "$(build_theme $GRID_ROWS $GRID_COLS)" -p "Wallpaper")

if [ -z "$choice" ]; then
    exit 1
fi

# Determine the selected wallpaper
if [ "$choice" == "Random Choice" ]; then
    selected_wallpaper=$(find "$WALLPAPERS_DIR" -type f | shuf -n 1)
else
    selected_wallpaper="$WALLPAPERS_DIR/$choice"
fi

# Set the wallpaper using swww and apply color scheme
if swww img "$selected_wallpaper" \
    --transition-type outer \
    --transition-fps 60 \
    --transition-duration 1; then
    
    # Add a delay to ensure the wallpaper is fully set before proceeding
    sleep 1.28

    # Apply the color scheme using pywal
    wal -i "$selected_wallpaper"
    
    # Source the generated color scheme from pywal
    . "${HOME}/.cache/wal/colors.sh"

    # Define the mako config file
    conffile="${HOME}/.config/mako/config"

    # Associative array, color name -> color code
    declare -A colors
    colors=(
        ["background-color"]="$background"
        ["text-color"]="$foreground"
        ["border-color"]="$color13"
    )

    # Loop through the colors and replace them in the mako config file
    for color_name in "${!colors[@]}"; do
        sed -i "s/^$color_name=.*/$color_name=${colors[$color_name]}/" "$conffile"
    done

    # Reload mako to apply the new color scheme
    makoctl reload

    # Send a notification that the wallpaper and color have changed
    notify-send "Wallpaper and Color Changed" "The wallpaper has changed and the color scheme has been applied."
 
    pywalfox update

    # Restart Waybar to apply the new color scheme
    killall -SIGUSR2 waybar
else
    echo "Failed to set wallpaper: $selected_wallpaper"
    exit 1
fi
