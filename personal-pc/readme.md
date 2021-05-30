Install auto update:

sudo dnf install dnf-automatic
sudo vi /etc/dnf/automatic.conf
systemctl enable --now dnf-automatic.timer
