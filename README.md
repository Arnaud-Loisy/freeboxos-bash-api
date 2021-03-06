freeboxos-bash-api
==================

Access [FreeboxOS API](http://dev.freebox.fr/sdk/os/#api-list) from bash

Démarrage
-----------

You need to have `curl` and `openssl` installed for the API, `logrotate` for the log rotation of the script and `cronie` for scheduling it.

Get the source:

    $ curl -L http://github.com/Arnaud-Loisy/freeboxos-bash-api/raw/master/freeboxos_bash_api.sh > freeboxos_bash_api.sh
    $ curl -L http://github.com/Arnaud-Loisy/freeboxos-bash-api/raw/master/script_reboot_auto.sh > script_reboot_auto.sh
    $ curl -L http://github.com/Arnaud-Loisy/freeboxos-bash-api/raw/master/script_reboot_auto.sh > /etc/logrotate.d/freeboxos-bash-api
    $ touch /var/log/freebox-bash-api.log && chown `whoami` /var/log/freebox-bash-api.log
    $ crontab -l | { cat; echo "*/5 * * * * `pwd`/script_reboot_auto.sh"; } | crontab - 
    
Appairage avec la Freebox
-------------------------
#### *  authorize_application *app_id* *app_name* *app_version* *device_name*
It is used to obtain a token to identify a new application (need to be done only once)
##### Exemple
```bash
$ source ./freeboxos_bash_api.sh
$ authorize_application  'BASH_SCRIPT_API'  'BASH_SCRIPT_API'  '1.0.0'  'Chapeau Rouge Huit'
Please grant/deny access to the app on the Freebox LCD...
Authorization granted

MY_APP_ID="BASH_SCRIPT_API"
MY_APP_TOKEN="TOKEN_GENERE"
```


API
---

#### *  login_freebox *app_id* *app_token*
It is used to log the application (you need the application token obtain from authorize_application function)
##### Exemple
```bash
#!/bin/bash

MY_APP_ID="BASH_SCRIPT_API"
MY_APP_TOKEN="TOKEN_OBTENU_PAR_ASSOCIATION"

# source the freeboxos-bash-api
source ./freeboxos_bash_api.sh

# login
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"
```

#### *  call_freebox_api *api_path*
It is used to call a freebox API. The function will return a json string with an exit code of 0 if successfull. Otherwise it will return an empty string with an exit code of 1 and the reason of the error output to STDERR.
You can find the list of all available api [here](http://dev.freebox.fr/sdk/os/#api-list)
##### Exemple
```bash
answer=$(call_freebox_api '/connection/xdsl')
```

#### *  get_json_value_for_key *json_string* *key*
This function will return the value for the *key* from the *json_string*
##### Exemple
```bash
value=$(get_json_value_for_key "$answer" 'result.down.maxrate')
```

#### *  dump_json_keys_values *json_string*
This function will dump on stdout all the keys values pairs from the *json_string*
##### Exemple
```bash
answer=$(call_freebox_api '/connection/')
dump_json_keys_values "$answer"
echo
bytes_down=$(get_json_value_for_key "$answer" 'result.bytes_down')
echo "bytes_down: $bytes_down"
```
<pre>
success = true
result.type = rfc2684
result.rate_down = 40
result.bytes_up = 945912
result.rate_up = 0
result.bandwidth_up = 412981
result.ipv6 = 2a01:e35:XXXX:XXX::1
result.bandwidth_down = 3218716
result.media = xdsl
result.state = up
result.bytes_down = 2726853
result.ipv4 = XX.XXX.XXX.XXX
result = {"type":rfc2684,"rate_down":40,"bytes_up":945912,"rate_up":0,"bandwidth_up":412981,"ipv6":2a01:e35:XXXX:XXXX::1,"bandwidth_down":3218716,"media":xdsl,"state":up,"bytes_down":2726853,"ipv4":XX.XXX.XXX.XXX}

bytes_down: 2726853</pre>

#### *  reboot_freebox
This function will reboot your freebox. Return code will be 0 if the freebox is rebooting, 1 otherwise.
The application must be granted to modify the setup of the freebox (from freebox web interface).
##### Exemple
```bash
reboot_freebox
```

Exemple
-------
```bash
#!/bin/bash

MY_APP_ID="BASH_SCRIPT_API"
MY_APP_TOKEN="4uZTLMMwSyiPB42tSCWLpSSZbXIYi+d+F32tVMx2j1p8oSUUk4Awr/OMZne4RRlY"

# source the freeboxos-bash-api
source ./freeboxos_bash_api.sh

# login
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"

# get xDSL data
answer=$(call_freebox_api '/connection/xdsl')

# extract max upload xDSL rate
up_max_rate=$(get_json_value_for_key "$up_xdsl" 'result.up.maxrate')

echo "Max Upload xDSL rate: $up_max_rate kbit/s"
```
Capture des statistiques de synchronisation après mise en place de script de reboot auto
![Capture](synchro.jpg?raw=true)
