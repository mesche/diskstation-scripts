#===================================================================
#    ::::::::::::::: www.blogging-it.com :::::::::::::::
#                         Version 1.0
#
# Copyright (C) 2014 Markus Eschenbach. All rights reserved.
# 
# 
# This software is provided on an "as-is" basis, without any express or implied warranty.
# In no event shall the author be held liable for any damages arising from the
# use of this software.
# 
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter and redistribute it,
# provided that the following conditions are met:
# 
# 1. All redistributions of source code files must retain all copyright
#    notices that are currently in place, and this list of conditions without
#    modification.
# 
# 2. All redistributions in binary form must retain all occurrences of the
#    above copyright notice and web site addresses that are currently in
#    place (for example, in the About boxes).
# 
# 3. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software to
#    distribute a product, an acknowledgment in the product documentation
#    would be appreciated but is not required.
# 
# 4. Modified versions in source or binary form must be plainly marked as
#    such, and must not be misrepresented as being the original software.
#    
#    ::::::::::::::: www.blogging-it.com :::::::::::::::
#===================================================================

#############################################################
# VARIABLES
#############################################################
KEY_FILE="/volume2/scripts/backup.key"
LOG_FILE="/volume2/scripts/backuplog2-`date +%Y-%m-%d`.log"

ENCRYPT_DIR_PATH=/volume2/@backup@
MOUNTED_DIR_PATH=/volume2/backup

TODAY=`date +%Y-%m-%d`

KEY_PASS=""

#############################################################
# MOUNT FUNCTION
#      Step 1: try to get the password from the keyfile
#      Step 2: create mounted dir if not exist
#      Step 3: try to mount encrypted filesystem
#############################################################

mount(){
	isMounted $MOUNTED_DIR_PATH
	if [ "$?" -ne "0" ]; then
		log "WARN: Encrypted filesystem is already mounted"
		return 0
	fi

	getKeyFromFile	

	createDir $MOUNTED_DIR_PATH

	/usr/syno/sbin/mount.ecryptfs $ENCRYPT_DIR_PATH $MOUNTED_DIR_PATH \
	-o key=passphrase:passphrase_passwd=$KEY_PASS,ecryptfs_cipher=aes,ecryptfs_key_bytes=32,ecryptfs_passthrough=n,no_sig_cache,ecryptfs_enable_filename_crypto >> $LOG_FILE

	if [ "$?" -ne "0" ]; then
        log "ERROR: Can not mount the encrypted filesystem"
        exit 1
	fi

	log "Encrypted filesystem mounted successfully"
	return 1
}

#############################################################
# UNMOUNT FUNCTION
#      Step 1: try to unmount directory
#      Step 2: try to remove mounted folder
#############################################################

unmount(){
	isMounted $MOUNTED_DIR_PATH
	if [ "$?" -eq "0" ]; then
		log "WARN: Encrypted filesystem is not mounted"
		return 0
	fi

	/bin/umount $ENCRYPT_DIR_PATH >> $LOG_FILE

	if [ "$?" -ne "0" ];	then
       log "ERROR: Can not unmount the encrypted filesystem"
       exit 1
	fi

	log "Encrypted filesystem unmounted successfully"

	removeDir $MOUNTED_DIR_PATH

	return 1
}

##############################################################
#	HELPER FUNCTIONS
##############################################################

getKeyFromFile(){
	KEY_PASS=`cat $KEY_FILE`

	if [ "$?" -ne "0" ]; then
	        log "ERROR: Could not find keyfile: $KEY_FILE"
	        exit 1
	fi

	log "Find password in keyfile"
}

log(){
	echo "$TODAY `date +%k:%M:%S`  --  $1" >> $LOG_FILE
}

isMounted(){
	 /bin/mount | /bin/grep $1 > /dev/null

   if [ "$?" -eq "0" ]; then
        log "$1 is mounted"
        return 1
   else
        log "$1 is not mounted"
        return 0
   fi
}

removeDir(){
	 if [ -d "$1" ]; then
 	 	  rm -r $1
      log "directory removed: $1"
 	 else
      log "WARN: Can't remove directory - REASON: does not exist: $1"
   fi

}

createDir(){
	 if [ ! -d "$1" ]; then
 			mkdir $1
 			log "directory created: $1"
 	 else
      log "WARN: Can not create directory - REASON: already exists: $1"
   fi
}

#############################################################
# RUN FUNCTION
#############################################################

	log "Starting the script"
	mount
	unmount
	log "Finished"
