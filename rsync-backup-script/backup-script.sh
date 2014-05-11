#!/bin/sh
#===================================================================
#	                DISKTATION RSYNC BACKUP SCRIPT
# 		                -- VERSION 1.0.0  --
#
#	- Startparameter: daily | weekly | monthly
#	
#	Example start command:
#	./volumeUSB1/usbshare/Backup/backup-script.sh weekly >> /var/log/backup-script-weekly.log 2>&1
#
#    ::::::::::::::: www.blogging-it.com :::::::::::::::
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


#===================================================================
#	SETTINGS
#===================================================================
BASE_DIR="$(dirname $0)"
CONFIG_FILELIST="$BASE_DIR/backup-script-files.properties"
TODAY=$(date +%Y-%m-%d-%H-%M-%S)
BACKUP_TYPE_REGEX="^\[.*]$"

#RSYNC PARAMETER
RSYNC_OPTIONS="-agrEl --stats "
RSYNC_EXCLUSIONS="--exclude Thumbs.db"


# CUSTOM VARIABLES
#This is the the base backup directory path
ROOT_DIR="/volumeUSB1/usbshare/Backup"
MAIL_TO="STATUS-MAIL@MAILPROVIDER.COM"
#===================================================================

#===================================================================
#	Convert given folder to a compressed tar file
#===================================================================
compressFolder(){ 
	local param1="$1"

	log "Run folder compression"
			
	log "Compress folder '$param1'"
	  
	tar -czf "$param1.tar.gz" "$param1" 2>/dev/null

	log "Compression finished to file '$param1.tar.gz'"

	if [ $? != 0 ]; then
		log "Compress folder FAILED for $param1"
		sendMail "Error: Diskstation-Backup!!!!" "Error: Diskstation-Backup! See log for more informations"
	else
	 	log "Compress folder success remove files"
		rm -rf "$param1"
	fi
}

runSync(){
    local line="$@" # get all args

    local src=$(echo $line |cut -d"|" -f1)
    local target=$(echo $line |cut -d"|" -f2)
    local param=$(echo $line |cut -d"|" -f3)
    
    src=`trimStr "$src"`
    target=`trimStr "$target"`
    param=`trimStr "$param"`

    local dest="$BACKUP_DIR/$target"

    mkdir -p $dest

    log "Run RSync for   $src   $dest"  
    rsync $RSYNC_OPTIONS $RSYNC_EXCLUSIONS "$src" "$dest"

    if [ $? != 0 ]; then
	log "RSYNC FAILED: Error on file backup"
	sendMail "Error: Diskstation-Backup!!!!" "Error: Diskstation-Backup! See log for more informations"
	exit 0
    fi
    
    if [ ! -z "$(echo "$param" | awk '/compress/')" ]; then compressFolder "$dest"; fi
}



#===================================================================
#	MAIN FUNCTION - READS FILE-LIST AND RUN SYNC FUNCTION
#===================================================================
MAIN(){
	
	log "********************  Start Backup DiskStation-Data ($BACKUP_TYPE) ********************"

	local foundCorrectType="false"

	while read line; do 
		line=`trimStr "$line"`
		if [[ ! -n "$line" ]]; then continue; fi  #if line is empty string

		isComment "$line"
		if [[ "$?" == 1 ]]; then continue; fi #if line is a comment
			
		matches "$line" "$BACKUP_TYPE_REGEX"  #check if line is backup type

		if [[ "$?" == 1 ]]; then 
			isCorrectBackupType "$BACKUP_TYPE" "$line"
			if [[ "$?" == 1 ]]; then foundCorrectType="true"; else foundCorrectType="false"; fi
		  continue
		fi
	
		if [[ "$foundCorrectType" == "true" ]]; then 
			let lineCounter++		 	
		 	runSync "$line" 	
		fi


	done < $CONFIG_FILELIST

	log "********************  End Backup DiskStation-Data ($BACKUP_TYPE) ********************"
}



    
#===================================================================
#	Trim white space from both sides of a string
#===================================================================
trimStr(){ echo $(echo "$1" | sed 's/^ *//;s/ *$//'); }

#===================================================================
#	Check if parameter string contains the correct backup type
#===================================================================
isCorrectBackupType (){ return $(echo "$2" | awk '/\['"$1"'\]/ {print 1;}'); }

#===================================================================
#	Check if parameter is a comment string! Then return 1
#===================================================================
isComment(){ return $(echo "$@" | awk '/^#/ {print 1;}'); }

#===================================================================
#	Check if string starts with parameter! Then return 1
#===================================================================
matches(){ return $(echo "$1" | awk '/'"$2"'/ {print 1;}'); }

#===================================================================
#	Sends a mail with Nail! Parameter: 1. Subject  2. Mailtext
#===================================================================
sendMail(){ echo "Send Mail with subject: $1"; echo "$2" | /opt/bin/nail -s "$1" "$MAIL_TO"; }

#===================================================================
#	Prints the given parameter as formatted log message
#===================================================================
log(){ echo "[$(date +%Y-%m-%d) $(date +%H:%M:%S)] - $@"; }



#===================================================================
#	INITIALIZE 
#===================================================================
	local BACKUP_TYPE="$@"

	if [[ "$BACKUP_TYPE" != "daily" && "$BACKUP_TYPE" != "weekly" && "$BACKUP_TYPE" != "monthly" ]]; then
		log "Wrong parameter '$BACKUP_TYPE'  --- Only 'daily' / 'weekly' / 'monthly' allowed"
		exit 0; 
	fi
	
	log "Found sync type: $BACKUP_TYPE"
	
	local BACKUP_DIR=$ROOT_DIR/$BACKUP_TYPE  
	mkdir -p $BACKUP_DIR

#===================================================================
#	START THE PROGRAMM
#===================================================================
	MAIN

#===================================================================
#	SHUTDOWN THE PROGRAMM
#===================================================================
	echo "$TODAY" > "$ROOT_DIR/$BACKUP_TYPE/lastrun"
	sendMail "Diskstation-Backup completed ($BACKUP_TYPE)!!!!" "Diskstation-Backup ($BACKUP_TYPE) completed  successfully!"




