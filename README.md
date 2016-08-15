# pacli
A simple and interactive Bash Frontend for Pacman/Yaourt

pacli is a CLI tool, which provides simple and advanced Pacman and Yaourt commands in an easy to use text interface. Additionally, it offers some Manjaro exclusive commands.

pacli is meant for experienced/intermediate/advanced users, who have basic knowledge of the structure of their Linux system and how Pacman and Yaourt work. Absolute beginners are probably overwhelmed by the amount of choices pacli provides.

It is highly recommended to use an utility, which notifies the user about available updates alongside of pacli. Such a lightweight utility is for example [update-notifier](https://github.com/Chrysostomus/update-notifier).


## Screenshots

Home Screen of pacli:
![Screenshot 01](http://i.imgur.com/UlECqkm.png)

Installing the package "cantata" from the Manjaro repositories:
![Screenshot 02](http://i.imgur.com/m1Kzp8U.png)

Removing "qt4" and another package from my system:
![Screenshot 03](http://i.imgur.com/jJKrdp5.png)

Downgrading the package "file-roller":
![Screenshot 04](http://i.imgur.com/kKzqbSl.png)

Looking up what packages on my system depend on "gtk2":
![Screenshot 05](http://i.imgur.com/dVfXdLj.png)


## Installation
Pacli is the official repository Manjaro and can be installed with the following command:
```
sudo pacman -S pacli
```

### Installation from the AUR
Install [pacli from the AUR](https://aur.archlinux.org/packages/pacli/).

Then, start pacli in your terminal with:
```
pacli
```

### Manual Installation
This installation method is no longer available.


## Configuration

pacli accepts the following config file:
$HOME/.config/paclirc

A default version of this file is available in this github repository. In this config file you can tweak the behavior of pacli e.g. for using pacaur instead of yaourt.


## Hidden Options

There are some hidden Options available without documentation:
- m: use different menu
- 100: Shows system information
- 111: Let's you manage .pacnew files
- 220: Let's you install directly from git repository


## Help

### pacli Help
Choose the "Help" option in pacli by entering "10" and pressing "ENTER".

This help page explains a little bit about pacli. It also explains every pacli option in detail. If you want to look up which commands pacli uses and understand them, this is the right place for you!

### Manjaro Forum
There are 2 threads in the Manjaro forum. Most of the discussion between the developers is going on there:
 - [Main Thread](https://forum.manjaro.org/index.php?topic=21399.0)
 - [Additional Thread](https://forum.manjaro.org/index.php?topic=28563.0)
