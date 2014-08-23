#!/bin/sh
#===================================================================
#	              DISKTATION - JENKINS - SERVICE - SCRIPT
# 		                  -- VERSION 1.0.0  --
#
#	- Startparameter: start | stop | restart
#	
#	Example commands:
#	/usr/local/etc/rc.d/S99jenkins.sh start
#	/usr/local/etc/rc.d/S99jenkins.sh stop
#	/usr/local/etc/rc.d/S99jenkins.sh restart
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

APP_NAME=jenkins
APP_DESC="Jenkins CI Server"
RUN_USER=jenkins
RUN_USER_GROUP=jenkins

BASE_PATH=/var/lib/jenkins
DATA_PATH=$BASE_PATH/data
#EXEC_JAVA="/volume1/@appstore/java8/ejdk1.8.0_06/linux_arm_sflt/jre/bin/java"
EXEC_USER="su -s /bin/sh $RUN_USER -c"
EXEC_APP="java -jar $BASE_PATH/jenkins.war"

PID_FILE=$DATA_PATH/$APP_NAME.pid
LOG_FILE=$DATA_PATH/$APP_NAME.log


#===================================================================
#	RUN
#===================================================================

# init environment
# now there is no need to specify the full path to the java binary
source /etc/profile

d_start() {

  # create data folder if not exist
  if [ ! -e $DATA_PATH ] ; then
      mkdir -p $DATA_PATH
      chown $RUN_USER:$RUN_USER_GROUP $DATA_PATH
  fi
  
  # check if jenkins already running
  if [ -e $PID_FILE ] ; then
      echo "$APP_DESC: $APP_NAME already running. PID=`cat $PID_FILE`"
      exit
  fi
  
  # create pid file
  touch $PID_FILE
  chown $RUN_USER:$RUN_USER_GROUP $PID_FILE
  
  # execute jenkins
  $EXEC_USER "
          cd /
          JENKINS_HOME=$DATA_PATH    \
          exec $EXEC_APP $JENKINS_OPTS \
          </dev/null >>$LOG_FILE 2>&1 & echo \$! >$PID_FILE           
          "
}

d_stop() {
  if [ -e $PID_FILE ] ; then
      kill `cat $PID_FILE`
      sleep 1
      rm -f $PID_FILE 
  else
      echo "$APP_DESC: $APP_NAME is not running.  No PID file!"
  fi
}

case $1 in
	start)
	echo "Starting $APP_DESC: $APP_NAME..."
	d_start
	echo "."
	;;
	stop)
	echo "Stopping $APP_DESC: $APP_NAME..."
	d_stop
	echo "."
	;;
	restart)
	echo "Restarting $APP_DESC: $APP_NAME..."
	d_stop
	sleep 1
	d_start
  echo "."
	;;
	*)
	echo "usage: $APP_NAME {start|stop|restart}"
	exit 1
	;;
esac

exit 0
