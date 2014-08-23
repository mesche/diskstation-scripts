#!/bin/sh
#===================================================================
#	              DISKTATION - JENKINS - START - SCRIPT
# 		                    -- VERSION 1.0.0  --
#	
#	Example start command:
#	/var/lib/jenkins/jenkins_start.sh
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
NAME=jenkins
BASE_PATH=/var/lib/jenkins
DATA_PATH=$BASE_PATH/data
PID_FILE=$DATA_PATH/$NAME.pid
LOG_FILE=$DATA_PATH/$NAME.log

#===================================================================
#	RUN
#===================================================================
touch $PID_FILE
chown $NAME:$NAME $PID_FILE
su -s /bin/sh $NAME -c "
        cd /
        JENKINS_HOME=$DATA_PATH    \
        exec java -jar $BASE_PATH/jenkins.war $JENKINS_OPTS \
        </dev/null >>$LOG_FILE 2>&1 & echo \$! >$PID_FILE           
        "
        