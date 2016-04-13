#!/bin/bash

shopt -s extglob

########   config    ########

# show text file created by hook if exist
print_hook() {
    if [ -f "${pacli_desc}" ]; then
        sudo cat "${pacli_desc}"
        sudo rm -f "${pacli_desc}"
    fi
}


########    menu    ########


# params : "┌─┐" or "└─┘"
menu_sep() {
    local bar=''
    for (( i=1; i<=$WMENU; i++ )); do
        bar="${bar}${1:1:1}"
    done
    echo -e " ${1:0:1}${bar}${1:2:1}"
}

# params <id> <text> <color>
menu_item() {
    local id="${1}" color="${3:-$NC}" txt="${2}"
    local colorend="$NC"
    local w=$(( (WMENU/2)-8  ))
    #for unicode
    txt="${txt}                                                        "
    [[ "$color" == "$RED" ]] && colorend=''
    printf "${color}%3s  ${colorend} %-${w}s" "$id" "${txt:0:$w}"
}

# params <id> <txt> <color> <id> <txt> <color>
menu_items() {
    local c1=$(menu_item "$1" "$2" "$3")
    local c2=$(menu_item "$4" "$5" "$6")
    printf " │  %s %s $NC│\n" "$c1" "$c2"
}

menu_show()
{
    clear
    echo ""
    printf "$NC%s$NC" "                      ::Pacli - Package manager::"
    echo ""
    menu_sep "┌─┐"
    menu_items "1" "Update System" "$NC"        "2" "Clean System"
    menu_items "3" "Install Package" "$NC"        "4" "Remove Package + Deps"
    menu_items "5" "Package Information" "$NC"        "6" "List Local Package Files"
    menu_items "7" "Dependency Tree " "$NC"        "8" "Reverse Dependency Tree"
    menu_sep "└─┘"
    menu_sep "┌─┐"
    menu_items "9" "Defragment Database" "$NC"        "10" "Help"
    menu_items "11" "Downgrade Packages" "$NC"        "12" "Pacman Log"
    menu_items "13" "Fix Errors" "$RED"             "14" "Configure Pacman" "$RED"
    menu_items "15" "Force Install Package" "$RED"  "16" "Force Update System" "$RED"
    menu_items "17" "Force Remove Package" "$RED"   "18" "Empty Package Cache" "$RED"
    menu_sep "└─┘"
    echo ""
    menu_sep "┌─┐"
    menu_items "19" "Update AUR" "$NC"                  "20" "Force Update AUR"
    menu_items "21" "Search + Install from AUR" "$NC"   "22" "Install from AUR"
    menu_items "23" "List Installed from AUR" "$NC"    "24" "Configure Yaourt"
    menu_sep "└─┘"
    echo ""
    printf "$NC%s$NC $NC%s$NC\n" "   Enter a number between 0 and 24 and press [Enter]" "- 0 Exit Pacli"
    echo ""
}

# mcenter <text>
# add left spaces for center text on screen
mcenter(){
    declare txt="$@"
    declare -i w="${#txt}" i=1 wmnu=$((WMENU+3))
    if (( w < wmnu )); then
        w=$(( (wmnu-w)/2 ))
        for (( i=1; i<=w; i++ )); do
            txt=" $txt"
        done
    fi
    echo "$txt"
}

# print_prompt <text> <text> <want_return =0>
# print centered text ans wait a key press
print_prompt()
{
    declare wantreturn=${3} str end default
    if [ -n "$wantreturn" ]; then
        str="$(gettext 'To return to pacli press [Enter]')"
    else
        str="$(gettext 'To return to pacli Press any key')"
    fi
    end="${2:-$str}"
    [ -z "$end" ] && end="$str"
    default="${1} ${str}"
    printf "\n$NC%s$NC\n" "$(mcenter $default)"
    if [ -n "$wantreturn" ]; then
        read
    else
        read -n1 -s
    fi
}

# print_enter <label> <list> <option>
# use fzf for select one or more items in list
# return only first colum
print_enter()
{
    declare ret="" choice=("$2") cancel
    if (("${PARAMS['cancellist']}"==1)); then
        cancel=("** $(gettext 'CANCEL OR ESC TOUCH')")
        choice=("$(echo -e "${cancel}\n$2")")
    fi
    ret=$(fzf-tmux -e $3 --reverse --exit-0 --prompt="$1 >" <<< "$choice" | awk '{print $1}' )
    if (($?==0)); then
        [[ "$ret" == "**" ]] && return 1
        echo "$ret"
    else
        return 1
    fi
}


########   help    ########

# catplus()
# params : catplus <file> <section-id (defaut:all)>
catplus()
{
    declare file="$1" txt
    declare id="${2:-0}" ids=$((id+1))
    if [ -r "$file" ]; then
        if ((id>0)); then
            txt=$(sed -n "/[\*\*?\!\!]${id} /,/[\*\*?\!\!]${ids} /p" "$file" | head -n-1)
        else
            txt=$(cat "$file")
        fi
        # bold for **texte**
        txt=$(sed -e 's|\*\*\([^\*]*\)\*\*|\\033[1m\1\\033[0m|g' <<< "$txt")
        # red for !!texte!!
        txt=$(sed -e 's|!!\([^!]*\)!!|\\e[01;31m\1\\033[0m|g' <<< "$txt")
        echo -e "$txt"
    fi
}

# help_text()
# params : help_text <section> <user config if show this help (default:1)>
# return 0 run command after (default)
# return 1 go to menu
help_text()
{
    [[ "${2:-1}" != "1" ]] && return 0    # not help for red command
    declare id="${1:-0}" command='less -R'
    [ -z "$LG" ] && LG=${LANG:0:2}
    declare help="./pacli.${LG}.help"   # first for devs or manual install
    [ -f "$help" ] || help="/usr/share/doc/${pkgname}/${LG}.help"
    [ -f "$help" ] || help="./pacli.help"
    [ -f "$help" ] || help="/usr/share/doc/${pkgname}/help"
    ((id>0)) && command='cat'
    #clear
    catplus "$help" "$id" | eval $command
    if ((id>0)); then
        printf "\n$NC%s$NC\n" "$(gettext 'To continue to pacli press [Enter], To return enter [q] and press [Enter]')"
        read key
        [[ "$key" != '' ]] && return 1
    fi
    return 0
}
