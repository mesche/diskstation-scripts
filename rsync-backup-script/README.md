RSync Backup Script
===================

### Introduction

With this litte script you can backup your data to an external or internal device.

[Guide (in german)](http://www.blogging-it.com/shell-backup-script-mit-rsync-fuer-die-synology-diskstation/hardware/nas.html)

### Requirements

- RSYNC: do the backup job
- NAIL: Send status mails
- TAR mit GZIP: compress files    

### Getting started

Execute this command from the command line with the startparameter (daily | weekly | monthly)

```
  $ ./backup-script.sh weekly
```  

When using the script in a cronjob it is  recommended to write the log data into a file.

```
  $ ./backup-script.sh weekly >> /var/log/backup-script-weekly.log 2>&1
```  


### Links

* [Synology](http://www.synology.com)
* [NAS Tipps & Tricks](http://www.blogging-it.com/hardware/nas)


### License
The license is committed to the repository in the project folder as `LICENSE.txt`.  
Please see the `LICENSE.txt` file for full informations.


----------------------------------

Markus Eschenbach  
http://www.blogging-it.com
