# Some bash scripts & commands

## Accessing boot logs
`sudo less +G /var/log/syslog` The +G option tells less to start at the end of the file. When you run this command, you'll see the last page of the syslog file, which contains the most recent log entries.

`sudo cat /var/log/dmesg`
`sudo cat /var/log/boot.log`
