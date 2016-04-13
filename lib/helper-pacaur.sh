#!/bin/bash
#pacaur

# run command <OPTIONS> <PACKAGES(s)>
helper()
{
    local options="$1" packages="$2"
            #[[ "$options" =~ '--' ]] && echo "o1:$options , p:$packages"
    options="${options/'--nocolor'/}"
            #[[ "$options" =~ '--' ]] && 
            #echo "o2:$options, p:$packages";
            #echo "pacaur $options "$packages""
    pacaur $options $packages
}

helper_islocal()
{
    expac -Q "%r" "^${1}$" | head -n 1 | grep "^local" &>/dev/null
}

helper_sync()
{
    local options="$1" packages="$2"
    options="${options/'--nocolor'/}"
    pacaur $options $packages
}

helper_pkgisinstalled()
{
    pacaur -Qq "$1" &>/dev/null
}

# list all packages with description
helper_listdesc()
{
    expac -S "%n : %d" 
}

# return config file
# if param, return model file in /etc/
helper_getconffile()
{
    local model="$1"
    if [ -n "$1" ]; then
        echo "/etc/xdg/pacaur/config"
    else
        echo "$HOME/.config/pacaur/config"
    fi
}

helperrc_edit()
{
    [[ -z "$EDITOR" ]] && EDITOR='nano'
    local file=$(helper_getconffile)
    if [ ! -f "$file" ]; then
        cp -v "$(helper_getconffile 'model')" "$file"
    fi
    $EDITOR "$file"
}