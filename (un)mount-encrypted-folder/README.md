Mount / Unmount Encrypted Folder
====================================

### Introduction

With this litte script you can mount or unmount an encrypted folder by command line.

[Guide (in german)](http://www.blogging-it.com/synology-disk-station-mount-unmount-eines-verschluesselten-ordners-mit-einem-shell-script-ueber-die-konsole/hardware/nas.html)


### Requirements

You have to export the `.key` file with the current import-key to the file system.


### Configuration 

You must modify the `KEY_FILE` and `LOG_FILE` to the correct path

```
KEY_FILE="/volume2/backup.key"
LOG_FILE="/volume2/backuplog-`date +%Y-%m-%d`.log"
```


### Getting started

Execute this command from the command line with the startparameter (mount | unmount)

```
  $ ./encrypted-folder.sh mount
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
