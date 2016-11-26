#!/bin/bash
# version 0.1
#================== Global Variables ==================

HOSTS_LIST="hosts.list"
LOGS_DIR="logs"
EDITOR="gedit"
FILE_SEPARATOR=":"
SERVER_ALIAS=1
SERVER_ADDR=2
SERVER_PORT=3
SERVER_CPU=4
SERVER_RAM=5
SERVER_NOTE=6
IMAGE_NAME="anony/mous"
CONTAINER_NAME="anonymous"

#================== All Function ==================

#==== Help ====
function help() {
    separator
    logo
	separator
	echo -e "  Available commands, <> is required, [] is Optional."
	echo -en "  Note: Alias "
	cecho -en -yellow "CAN NOT" " be a number, but it can be a combination of letters and numbers."
	separator
	echo -e "  con     <alias>                                  -  Connect to the specified server."
	echo -e "  run     <alias>/all \"<command> [command]\"        -  Run a one-time command on one or all servers."
	echo -e "  add     <alias>:<addr>:<port>:[cpu]:[ram]:[note] -  Add a server to list."
	echo -e "  del     <alias>                                  -  Delete a server in list."
	echo -e "  ping    <count>                                  -  Input a number of packets to transmit."
	echo -e "          <alias>                                  -  Input a alias to test the server delay."
	echo -e "  test    <addr:port>                              -  Quickly test the server."
	echo -e "  docker  <alias> <docker command>                 -  Use Docker control the server."
	echo -e "  edit                                             -  Edit the server list"
	separator
}

#==== Logo ====
function logo() {
cecho -blue "
   ____             _               ____             _     ____  _          _ _ 
  |  _ \  ___   ___| | _____ _ __  |  _ \ ___   ___ | |_  / ___|| |__   ___| | |
  | | | |/ _ \ / __| |/ / _ \ '__| | |_) / _ \ / _ \| __| \___ \| '_ \ / _ \ | |
  | |_| | (_) | (__|   <  __/ |    |  _ < (_) | (_) | |_   ___) | | | |  __/ | |
  |____/ \___/ \___|_|\_\___|_|    |_| \_\___/ \___/ \__| |____/|_| |_|\___|_|_|
  Email: i@zuolan.me                                     Blog: https://zuolan.me"
}

#==== Test Delay ====
function ping_host() {
    time=$(ping -c1 -W1 $@ | grep "ttl" | awk '{print $7}' | cut -d= -f2 &)
	if [ "$time" = "" ] ; then
	    echo -n "  "
		cecho -n -red "EROR\t"
	else
	    echo -n "  "
		cecho -n -green $time
		echo -n " ms"
	fi
}

#==== Separator ====
function separator() {
	echo "================================================================================================================"
}

#==== Read The List ====

function get_raw() {
	als=$1
	grep -w -e $als $HOSTS_LIST 2> /dev/null
}

function get_addr() {
	als=$1
	get_raw "$als" | awk -F "$FILE_SEPARATOR" '{ print $'$SERVER_ADDR' }'
}

function get_port() {
	als=$1
	get_raw "$als" | awk -F "$FILE_SEPARATOR" '{ print $'$SERVER_PORT'}'
}

function test_alias() {
	alias_tmp=$(echo $1 | cut -d: -f1)
	grep -w -e $alias_tmp $HOSTS_LIST > /dev/null
	return $?
}

#==== Color Settings ====
function cecho() {
	while [ "$1" ]; do
		case "$1" in 
			-normal)        color="\033[00m" ;;
            -black)         color="\033[30;01m" ;;
            -red)           color="\033[31;01m" ;;
            -green)         color="\033[32;01m" ;;
            -yellow)        color="\033[33;01m" ;;
            -blue)          color="\033[34;01m" ;;
            -magenta)       color="\033[35;01m" ;;
            -cyan)          color="\033[36;01m" ;;
            -white)         color="\033[37;01m" ;;
            -n)             one_line=1;   shift ; continue ;;
            *)              echo -n "$1"; shift ; continue ;;
        esac
    shift
    echo -en "$color"
    echo -en "$1"
    echo -en "\033[00m"
    shift

    done
    if [ ! $one_line ]; then
	    echo
    fi
}

#================== Let's Go ==================

cmd=$1
alias=$2
command=$3

# If the server list doesn't exist, it will create a new list.
if [ ! -f $HOSTS_LIST ]; then touch "$HOSTS_LIST"; fi
# If the logs folder doesn't exist, it will create a new folder.
if [ ! -f $LOGS_DIR ]; then mkdir -p "$LOGS_DIR"; fi
# Install Docker.
command -v docker >/dev/null 2>&1; if [ $? != 0 ]; then curl -sSL https://get.docker.com/ | sh; fi


# Output the server list.
if [ $# -eq 0 ]; then
    let i=1
	separator 
	echo -en "  Num\t- Alias\t- Address Port\t\t- CPU Mem  \t-  Note\n"
	separator
    while IFS=: read alias addr port cpu mem note         
	    do
	    echo -en "  $i"
	    let i=$i+1
	    echo -en "\t- $alias\t- $addr $port\t- $cpu Cu $mem GB  \t-  $note\n"
    done < $HOSTS_LIST
    help
    exit 0;
fi

case "$cmd" in
#==== Connect To The Server ====
con )
addr=$(get_addr "$alias")
port=$(get_port "$alias")
test_alias "$alias"
if [ $? -eq 0 ]; then
    separator
    echo "Connecting to '$alias' ($addr:$port)"
    separator
    docker -H tcp://$addr:$port run -it --name $CONTAINER_NAME --rm -v /:/host_dir $IMAGE_NAME
    separator
    echo "Cleaning the '$alias' ($addr:$port) history...."
    separator
    docker -H tcp://$addr:$port rmi $IMAGE_NAME
    separator
else
    echo "$0: The alias unknown: '$alias'"
fi
;;

#==== Run The Command On One Or All Server ====
run )
addr=$(get_addr "$alias")
port=$(get_port "$alias")
test_alias "$alias"
if [ $? -eq 0 ]; then
	if [ "$command" == ""  ]; then
        echo "Command Unknown"
        exit 1;
	fi
	separator
	echo -en '  Running the command on '$alias'('$addr:$port'):\n'
	separator
    docker -H tcp://$addr:$port run -v /:/host_dir --name $CONTAINER_NAME --rm $IMAGE_NAME chroot /host_dir /bin/sh -c "$command" > $LOGS_DIR/$alias.log 2> $LOGS_DIR/$alias.docker.log
    docker -H tcp://$addr:$port rmi $IMAGE_NAME 2> $LOGS_DIR/$alias.docker.log
    echo -en '  The '$alias'('$addr:$port') finished, logs file are '$LOGS_DIR/$alias'.log\n'
else
	if [ "$alias" == "all"  ]; then
        while IFS=: read label addr port cpu mem note         
	    do
        	separator 
	        echo -en '  Running the command on '$alias'('$addr:$port'), logs file will save in '$LOGS_DIR/$alias'.log....\n'
	        separator
	        docker -H tcp://$addr:$port run -v /:/host_dir --rm $IMAGE_NAME chroot /host_dir /bin/sh -c "$command" > $LOGS_DIR/$label.log 2> $LOGS_DIR/$label.docker.log &
        done < $HOSTS_LIST
        wait
        echo -en 'All commands of the servers are completed.(Docker logs saved in '$LOGS_DIR'/*.docker.log)\n\n\n\n'
        while IFS=: read label addr port cpu mem note         
	    do
	        separator
	        echo -en "Cleaning the $label($addr:$port) history....\n"
	        separator
	        docker -H tcp://$addr:$port rmi $IMAGE_NAME 2>> $LOGS_DIR/$label.docker.log
	        separator
	        echo -en 'The Server '$label'('$addr:$port') clean finished.\n\n'
        done < $HOSTS_LIST
        echo -en 'All servers history are clean.Docker logs saved in '$LOGS_DIR'/*.docker.log)\n\n'
        exit 0;
	fi
	echo "$0: The alias unknown: '$alias'"
fi
;;

#==== Add A New Server ====
add )
test_alias "$alias"
if [ $? -eq 0 ]; then
	echo "$0: alias '$alias_tmp' already exists."
else
	echo "$alias$FILE_SEPARATOR$addr" >> $HOSTS_LIST
	echo "New Server '$alias' added successfully."
fi
;;

#==== Remove A Server ====
del )
test_alias "$alias"
if [ $? -eq 0 ]; then
	cat $HOSTS_LIST | sed '/^'$alias$FILE_SEPARATOR'/d' > /tmp/.tmp.$$
	mv /tmp/.tmp.$$ $HOSTS_LIST
	echo "Alias '$alias' removed."
else
	echo "$0: The alias unknown: '$alias'"
fi
;;

#==== Test Server Delay ====
ping )
count=$alias
if [ "$count" -gt 0 ] 2>/dev/null; then 
    separator
    echo -en "  Alias\t-  Address Port\t\t\t-  Delay\t-  CPU Mem\t-  Note\n"
    separator
    while IFS=: read alias addr port cpu mem note         
        do
        time=$(ping -c$count -W1 $addr | grep "avg" | awk '{print $4}' | cut -d/ -f2 | cut -d. -f1 &)
        if [ "$time" = "" ] ; then
            time=$(ping -c3 -W1 $addr | grep "avg" | awk '{print $4}' | cut -d/ -f2 | cut -d. -f1 &)
            if [ "$time" = "" ] ; then
                echo -en "  $alias\t-  $addr $port\t\t-  "
                cecho -en -red "TimeOut"
                echo -en "\t-  $cpu Cu $mem GB\t-  $note\n"
            else
                echo -en "  $alias\t-  $addr $port\t\t-  "
                cecho -n -red "$time"
                echo -en " ms\t-  $cpu Cu $mem GB\t-  $note\n"
            fi
        else
            echo -en "  $alias\t-  $addr $port\t\t-  "
            cecho -n -green $time
            echo -en " ms\t-  $cpu Cu $mem GB\t-  $note\n"
        fi
    done < $HOSTS_LIST
    separator
    exit 0
else
    time=$(ping -c1 -W1 $(get_addr "$alias") | grep "ttl" | awk '{print $7}' | cut -d= -f2 &)
    if [ "$time" = "" ] ; then
        echo -n "  "
            cecho -n -red "TimeOut\n"
    else
        echo -n "  "
            cecho -n -green $time
            echo -en " ms"
            echo
    fi
fi
;;

#==== Test A Server ====
test )
addr_port=$alias
separator
echo "  Starting container in the server ...."
separator
docker -H tcp://$addr_port run -v /:/host_dir --name $CONTAINER_NAME --rm -it $IMAGE_NAME
separator
echo "  Clean the history in the server...."
separator
docker -H tcp://$addr_port rmi $IMAGE_NAME
separator
;;

#==== Use Docker ====
docker )
addr=$(get_addr "$alias")
port=$(get_port "$alias")
docker_command="$command"
test_alias "$alias"
if [ $? -eq 0 ]; then
    echo "Connecting to '$alias' ($addr:$port)"
    docker -H tcp://$addr:$port $docker_command
    separator
else
    echo "$0: The alias unknown: '$alias'"
fi
;;

#==== Edit The Server List ====
edit )
command -v $EDITOR >/dev/null 2>&1
if [ $? = 0 ]; then
    $EDITOR $HOSTS_LIST
else
    vi $HOSTS_LIST
fi
;;

* )
echo "$0: The alias command unknown: '$cmd'"
;;
esac
