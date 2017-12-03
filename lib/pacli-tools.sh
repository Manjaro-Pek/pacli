#!/bin/bash

shopt -s extglob

########   config    ########

# secure load user params with trim(value) - not the command "source"
load_user_params() {
    declare file="$HOME/.config/${pkgname}rc"
    declare key value
    [ -f "$file" ] || return 1
    while IFS='=' read  key value; do
        key="${key%%*( )}"
        if [ -n "$key" ]; then
            value="${value%%*( )}"
            PARAMS[$key]="${value##*( )}"
        fi
    done < <(grep -v "^#" "${file}")
    [ -n "${PARAMS[boxcolor]}" ] && PARAMS[boxcolor]="\e[${PARAMS[boxcolor]}"
    readonly PARAMS
}

get_is_local() {
    if [ -f "./pacli.help" ]; then
        LOCAL=1
    else
        unset LOCAL
    fi
}

# read console args for debug/tests
get_options() {
    ((LOCAL)) || return 1
    #only for test
    unset TESTMENU
    while getopts tw:l: option; do
        case $option in
            w) WMENU="$OPTARG";;
            l) LG="${OPTARG:0:2}";;
            t) NOCLEAR=1;;
        esac
    done
    # end get params for test
}

# show text file created by hook if exist
print_hook() {
    (("${PARAMS['hook']}" != 1)) && return 0
    if [ -f "${pacli_desc}" ]; then
        sudo cat "${pacli_desc}"
        sudo rm -f "${pacli_desc}"
    fi
}


########    menu    ########


# params : "┌─┐" or "└─┘"
menu_sep() {
    if [[ -z "$1" ]]; then
        echo ""
        return 0
    fi
    declare bar=''
    declare -i i
    for (( i=1; i<=$WMENU; i++ )); do
        bar="${bar}${1:1:1}"
    done
    echo -e " ${PARAMS[boxcolor]}${1:0:1}${bar}${1:2:1}$NC"
}

# params <id> <text> <color>
menu_item() {
    declare -i w=$(( (WMENU/2)-8  ))
    declare id="${1}" color="${3:-$NC}" txt="${2}" colorend="$NC"
    #for unicode
    txt="${txt}                                                        "
    [[ "$color" == "$RED" ]] && colorend=''
    printf "${color}%3s  ${colorend} %-${w}s" "$id" "${txt:0:$w}"
}

# params <id> <txt> <color> <id> <txt> <color>
menu_items() {
    declare c1=$(menu_item "$1" "$2" "$3")
    declare c2=$(menu_item "$4" "$5" "$6")
    printf " ${PARAMS[boxcolor]}│$NC  %s %s $NC${PARAMS[boxcolor]}│$NC\n" "$c1" "$c2"
}

# calculate WMENU minimum from items or prompt
# menu_calculate_size <PROMPT: string>
# use : MENUS: array
# return WMENU
# return PROMPT string
# return last_id for prompt menu
menu_calculate_size() {
    declare -g PROMPT=''
    declare -ig last_id=0
    declare -i item_long=0 l=0 ww=0
    declare line item datas

    declare IFS=$'\n'
    for line in "${MENUS[@]}"; do
        datas=( ${line//:/$'\n' } )
        if [[ "${datas[0]}" =~ [0-9] ]]; then
            #extend menu, dont show
            (("${datas[0]}">49))  && continue
            item=${datas[1]}
            id=${datas[0]}
            l="${#item}"
            ((l > item_long )) && item_long=$l
            ((id > last_id )) && last_id=$id
        fi
    done
    (( ww=(item_long+9)*2 ))   # add number and spaces
    ((ww %2 )) && ((ww++))
    WMENU=$ww

    #from prompt ?
    PROMPT=$(printf "$1" "$last_id")
    l=${#PROMPT}
    if (( l > WMENU )); then
        WMENU=$l
        ((WMENU %2 )) && ((WMENU++))
    fi
    readonly WMENU
    readonly last_id
    readonly PROMPT
}

# parse array and transform it to str
# user MENUS array
menu_load()
{
    declare line
    declare -a item=() datas=()
    declare IFS=$'\n'
    for line in "${MENUS[@]}"; do
        datas=($(echo "${line//:/$'\n'}"))

        if [[ ! "${datas[0]}" =~ [0-9] ]]; then
            #one separator
            if [ -n "$item" ]; then
                menu_items "${item[0]}" "${item[1]}" "${item[2]}"  "" "" ""
                unset item
            fi
            menu_sep "${datas[0]}"
            continue
        fi

        #extend menu, dont show
        (("${datas[0]}">49))  && continue

        # if we want a blanck at right ?
        if [[ -n "$item" ]] && (( datas[0] % 2 )); then
            menu_items "${item[0]}" "${item[1]}" "${item[2]}"  "" "" ""
            item=($(echo "${line//:/$'\n'}"))
            continue
        fi

        if [ -z "$item" ]; then
            item=($(echo "${line//:/$'\n'}"))
        else
            menu_items "${item[0]}" "${item[1]}" "${item[2]}"  "${datas[0]}" "${datas[1]}" "${datas[2]}"
            unset item
        fi

    done
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

# show in main menu all items (id>49)
# input_mnu <label>
input_mnu()
{
    declare -a choice=()
    declare line datas ret
    declare IFS=$'\n'
    for line in "${MENUS[@]}"; do
        datas=( ${line//:/$'\n' } )
        if [[ "${datas[0]}" =~ [0-9] ]]; then
            choice=("$(echo -e "${datas[1]} (${datas[0]})\n${choice[@]}")")
        fi
    done
    ret=$(fzf-tmux -e --exit-0 --tac --prompt="$1 >" <<< "$choice" | awk -F'(' '{print $2}' )
    if (($?==0)); then
        [[ "$ret" == "" ]] && return 1
        echo "${ret%?}"
    else
        return 1
    fi
}

#show main menu  <menu_buffer:string in option>
menu_show()
{
    ((NOCLEAR)) || clear
    echo ""
    printf "\n$NC%s$NC" "$(mcenter '::Pacli - Package manager::')"
    echo ""
    [ -z "$1" ] && menu_load || echo -e "$1"
    echo ""
    printf "\n$NC%s$NC\n" "$(mcenter $PROMPT)"
}

# read choise after main menu
read_choice()
{
    declare choice="$1"
    if [ -n "$choice" ]; then
        declare -i int=$((choice+0))
        ((int>0)) && { echo $int; return 0; }
    fi
    if ((MENUEX==1)); then
        choice=$(input_mnu "MENU")
        if (($?!=0));then
            choice=''
        fi
    else
        read choice
    fi
    printf "$choice"
}


########    page    ########


# params <id> <text> <color> <align :r=right>
page_item() {
    declare id="${1}" color="${3:-$BOLD}" txt="${2}" align="$4"
    declare -i w=$(( (WMENU/2)-11 ))
    declare -i w2=$(( w+14 ))
    id="${id}                                                          " #for unicode
    if [ -z "$align" ]; then
        txt="${txt}                                                        "
        printf " ${PARAMS[boxcolor]}│${NC}  ${NC}%-${w}s ${NC}${color} %-${w2}s${NC}  ${PARAMS[boxcolor]}│${NC}\n" "${id:0:$w} :" "${txt:0:$w2}"
    else
        printf " ${PARAMS[boxcolor]}│${NC}  ${NC}%-${w}s ${NC}${color} %${w2}s${NC}  ${PARAMS[boxcolor]}│${NC}\n" "${id:0:$w} :" "${txt:0:$w2}"
    fi
}

int_to_yes() {
    [[ "$1" == "1" ]] && printf 'yes' || printf 'no'
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
