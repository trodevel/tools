#!/bin/bash

# Install Ubuntu package (include file)
#
# Copyright (C) 2015 Sergey Kolevatov
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

ccred=$( echo -e "\033[41m" )
ccgreen=$( echo -e "\033[42m" )
ccblue=$( echo -e "\033[44m" )
ccend=$( echo -e "\033[0m" )

print_exist()
{
    local type=$1
    local name=$2
    local exists=$3

    [[ "$exists" -eq 0 ]] && echo "$type $name - ${ccgreen}new$ccend" || echo "$type $name - ${ccblue}exists${ccend}";
}

install_repos()
{
    declare -a repos=("${!1}")

    local is_update_needed=0

    for s in ${repos[@]}
    do
        has=$( egrep -v '^#|^ *$' /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null | grep $s )
        if [ -z "$has" ]
        then
            print_exist "repository" $s 0
            is_update_needed=1
            sudo add-apt-repository ppa:$s
        else
            print_exist "repository" $s 1
        fi
    done

    return $is_update_needed
}


install_packages()
{
    declare -a apps=("${!1}")

    for s in ${apps[@]}
    do
        has=$( dpkg -l | grep "\s${s}\s" )
        if [ -z "$has" ]
        then
            print_exist "package" $s 0
            sudo apt-get -y install $s
        else
            print_exist "package" $s 1
        fi
    done
}

setup()
{
    declare -a repos=("${!1}")
    declare -a apps=("${!2}")

    install_repos repos[@]
    local is_update_needed=$?

    if [ $is_update_needed -eq 1 ]
    then
        sudo apt-get update
    fi

    install_packages apps[@]
}
