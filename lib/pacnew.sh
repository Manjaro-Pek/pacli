#!/bin/bash

declare -r GREENC='\e[32m'
declare -i AGE=360
declare -r EXT='pacnew'
declare -i islib=0

declare -a pacnews=()

#params files : <ORIGINAL> <PACNEW>
show_diff()
{
    declare file1="$1" file2="$2" c line
    if (( $(diff "${file1}" "${file2}"|wc -l) == 0 )); then
        # can remove etc/pacnew
        echo -e "\n${BOLD}You can erase this file${NC} : sudo rm $file2"
    else
        ((NOCLEAR)) || clear
        echo "#${file2}"
        declare IFS=$'\n'
        # < : removed       > : added
        diff "$file1" "$file2" | grep -E "^>|^<" | while read line ; do
            [[ "${line::1}" == '<' ]] &&  c="${RED}-" || c="${GREENC}+"
            printf "$c ${line:2}$NC\n"
        done   
    fi
}

get_su(){
    declare mysu='sudo'
    if [ -f '/usr/bin/kdesu' ]; then
        mysu='kdesu'
    elif [ -f '/usr/bin/gksu' ]; then
        mysu='gksu'
    fi
    echo "$mysu"
}
get_editor_news(){
    declare -a cmd=( $(get_su) )
    declare edit="$(command -v "${PARAMS[peditor]}")"
    [ ! -f "$edit" ] && return 1
    [[ "$cmd" != 'sudo' ]] && cmd+=( '-c' )
    cmd+=( "$edit" )
    echo "${cmd[@]}"
}

# param <ID> index +1 array pacnews
run_pacnew()
{
    declare choix ofile fname
    choix=$(($1+0))
    fname="${pacnews[$choix]}"
    ofile="${fname/.$EXT/}"

    if [ -f "$ofile" ]; then
        show_diff "$ofile" "$fname"
        echo
        read -p "edit [e] or other key for return > " choix 
        if [[ "$choix" == "e" || "$choix" == "E" ]]; then
            if [ -z "${PARAMS[peditor]}" ]; then
                [ -z "$EDITOR" ] && EDITOR='nano'
                sudo $EDITOR "$ofile" "$fname"
            else
                declare -a edit=( $(get_editor_news) )
                if [ -z "$edit" ]; then
                    echo -e "Error: editor not found\nEdit $HOME/.config/paclirc, key:peditor"
                    exit 1
                fi
                set -x
                "${edit[@]}" "$ofile" "$fname" 1> /dev/null
                set +x
            fi
        fi
    fi
}

get_files()
{
    #pacnews=($(find '/etc' -name "*.$EXT" -mtime -$AGE -type f 2>/dev/null))
    while read  key value; do
        pacnews["$key"]="$value"
    done < <(find '/etc' -name "*.$EXT" -mtime -$AGE -type f 2>/dev/null | nl)
    MAX="${#pacnews[@]}"
}

display_pacnews()
{
    local id=0 ids=0 old line='' fistline='' str
    ((NOCLEAR)) || clear
    mcenter "$(gettext 'Pacnews')"
    menu_sep "┌─┐"

    declare IFS=$'\n'
    for id in "${!pacnews[@]}"; do
        ((id==0)) && continue
        line="${pacnews[$id]##*/}"
        line="${line/.$EXT/}"
        if [ -z "$firstline" ]; then
            firstline="${pacnews[$id]##*/}"
            firstline="${firstline/.$EXT/}"
            continue
        fi
        ids=$((id-1))
        menu_items "$ids" "${firstline}" ""  "$id" "${line}" ""
        firstline=''
    done
    # rest one item no pair ?
    if [ -n "$firstline" ]; then
        #ids=$((id+1))
        menu_items "$id" "${firstline}" ""  "" "" ""
        firstline=''
    fi

    menu_sep "└─┘"
    echo
    str=$(printf "To view difference, enter 1..%s and [Enter] - Return to pacli [0]" "${ids}")
    printf "${NC}%s${NC}\n" "$(mcenter "$str")"
}

main_pacnew()
{
    declare choice
    get_files
    while true; do
        display_pacnews
        read choice 
        choice=$((choice+0))
        if ((choice==0)); then
            return 0
        fi
        if ((choice<1 || choice>MAX)); then
            printf "$RED %s $NC\n" "$(gettext 'Wrong option')"
            echo "$(gettext 'Wait and try again later...')"
            echo
            sleep 1
            ((NOCLEAR)) || clear
        else
            run_pacnew "$choice"
        fi
    done
}

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
    # "load pacnew as script"
    unset islib
    pwd=$(dirname "$PWD/$0")
    libfile="${pwd}/../pacli"
    [ ! -f "$libfile" ] && libfile='/usr/bin/pacli'
    source "$libfile"
    main_pacnew "$@"
else
    # "load pacnew as lib"
    declare -ir islib=0
fi
