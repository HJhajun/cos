#!/bin/bash

echo "=== Installing COS ==="

echo "Updating package lists..."
sudo apt update

echo "Installing required packages..."
sudo apt install -y neofetch git curl feh

sudo cp branding/os-release /etc/os-release

echo "Setting COS login logo..."
sudo mkdir -p /usr/share/cos
sudo cp branding/cos.png /usr/share/cos/logo.png

if [ -f /etc/gdm3/greeter.dconf-defaults ]; then
sudo sed -i 's|#logo=.*|logo=/usr/share/cos/logo.png|' /etc/gdm3/greeter.dconf-defaults
fi

echo "Setting COS distro logo..."
sudo cp branding/cos.png /usr/share/pixmaps/cos.png
sudo sed -i 's|LOGO=.*|LOGO=/usr/share/pixmaps/cos.png|' /etc/os-release


################################
# WALLPAPER (ALL DESKTOPS)
################################

echo "Setting COS wallpaper..."

sudo mkdir -p /usr/share/backgrounds
sudo cp branding/wallpaper.png /usr/share/backgrounds/cos-wallpaper.png

WALL="/usr/share/backgrounds/cos-wallpaper.png"
URI="file://$WALL"

DE=$(echo "$XDG_CURRENT_DESKTOP $DESKTOP_SESSION" | tr '[:upper:]' '[:lower:]')

echo "Detected DE: $DE"

# GNOME / Unity / Budgie
if [[ "$DE" == *"gnome"* || "$DE" == *"unity"* || "$DE" == *"budgie"* ]]; then
gsettings set org.gnome.desktop.background picture-uri "$URI"
gsettings set org.gnome.desktop.background picture-uri-dark "$URI"
fi

# KDE Plasma
if [[ "$DE" == *"kde"* || "$DE" == *"plasma"* ]]; then
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var d=desktops();
for(i=0;i<d.length;i++){
d[i].wallpaperPlugin='org.kde.image';
d[i].currentConfigGroup=['Wallpaper','org.kde.image','General'];
d[i].writeConfig('Image','$URI');
}"
fi

# XFCE
if [[ "$DE" == *"xfce"* ]]; then
xfconf-query -c xfce4-desktop -p /backdrop -r -R
for p in $(xfconf-query -c xfce4-desktop -l | grep last-image); do
xfconf-query -c xfce4-desktop -p "$p" -s "$WALL"
done
fi

# Cinnamon
if [[ "$DE" == *"cinnamon"* ]]; then
gsettings set org.cinnamon.desktop.background picture-uri "$URI"
fi

# MATE
if [[ "$DE" == *"mate"* ]]; then
gsettings set org.mate.background picture-filename "$WALL"
fi

# Deepin
if [[ "$DE" == *"deepin"* ]]; then
gsettings set com.deepin.wrap.gnome.desktop.background picture-uri "$URI"
fi

# LXQt
if [[ "$DE" == *"lxqt"* ]]; then
pcmanfm-qt --set-wallpaper "$WALL"
fi

# LXDE
if [[ "$DE" == *"lxde"* ]]; then
pcmanfm --set-wallpaper "$WALL"
fi

# i3 / sway / others fallback
if command -v feh >/dev/null; then
feh --bg-scale "$WALL"
fi

echo "Installing COS boot theme..."
sudo apt install -y plymouth plymouth-themes
sudo mkdir -p /usr/share/plymouth/themes/cos
sudo cp plymouth/* /usr/share/plymouth/themes/cos/
sudo cp branding/cos.png /usr/share/plymouth/themes/cos/
sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/cos/cos.plymouth 100
sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/cos/cos.plymouth
sudo update-initramfs -u

echo "COS installed."
