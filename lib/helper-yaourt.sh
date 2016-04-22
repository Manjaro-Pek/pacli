#!/bin/bash
#yaourt


# run command <OPTIONS> <PACKAGES(s)>
helper()
{
    local options="$1" packages="$2"
    yaourt $options $packages
}

helper_islocal()
{
    yaourt -Qs "^${1}$" | head -n 1 | grep "^local" &>/dev/null
}

helper_sync()
{
    local options="$1" packages="$2"
    yaourt $options $packages
}

helper_pkgisinstalled()
{
    yaourt -Qq "$1" &>/dev/null
}

# list packages with description
helper_listdesc()
{
    package-query -Sl -f '%n - %d'
}

# return config file
# if param, return model file in /etc/
helper_getconffile()
{
    local model="$1"
    if [ -n "$1" ]; then
        echo "/etc/yaourtrc"
    else
        echo "$HOME/.config/yaourt/yaourtrc"
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