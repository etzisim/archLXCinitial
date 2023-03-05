#!/bin/bash
# Ask the user for their name
var_yay=false
var_disable_root=false
var_wheel=false


clear
read -p 'Username: ' var_user
[ -z "$var_user" ] && echo "Empty" && exit 0
read -sp 'Password: ' var_pass
[ -z "$var_pass" ] && echo "Empty" && exit 0

clear
read -r -p "install yay? [Y/n]" response
response=${response,,} # tolower
if [[ $response =~ ^(y|z| ) ]] || [[ -z $response ]]; then
  var_yay=true
  echo yay will be installed
fi

clear
read -r -p "disable root account? [Y/n]" response
response=${response,,} # tolower
if [[ $response =~ ^(y|z| ) ]] || [[ -z $response ]]; then
  var_wheel=true
  echo users of group wheel will be able to use sudo
fi

clear
read -r -p "enable wheel group for sudo? [Y/n]" response
response=${response,,} # tolower
if [[ $response =~ ^(y|z| ) ]] || [[ -z $response ]]; then
  var_disable_root=true
  echo root account will be disabled
fi

clear
echo It\'s nice to meet you $var_user with password: $var_pass
#echo yay: $var_yay
#echo disable root: $var_disable_root
#echo enable wheel for sudo: $var_wheel


echo init pacman keys
pacman-key --init
pacman-key --populate archlinux


echo update and install sudo,ssh and zsh 
curl "https://archlinux.org/mirrorlist/?country=AT&country=BE&country=DE&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on" > /etc/pacman.d/mirrorlist
sed -i 's/#Server/Server/' /etc/pacman.d/mirrorlist
pacman -Syy
pacman -S archlinux-keyring --noconfirm
pacman -Syyuu --noconfirm
pacman -S grml-zsh-config sudo openssh --noconfirm

echo add user $var_user
useradd -m -g users -G wheel -s /bin/zsh $var_user
echo -e "$var_pass\n$var_pass" | passwd $var_user

if [ "$var_wheel" = true ] ; then
  echo -e \n enable wheel
  sed -i s/"# %wheel ALL=(ALL:ALL) ALL"/"%wheel ALL=(ALL:ALL) ALL"/g /etc/sudoers
fi

if [ "$var_disable_root" = true ] ; then
  echo -e \n disable root
  passwd -d root
  passwd -l root
fi


if [ "$var_yay" = true ] ; then
  echo -e \n install yay
  pacman -S base-devel git
  cd /tmp
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin/
  sudo -u $var_user makepkg -si
fi
exit 0
