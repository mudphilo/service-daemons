#!/bin/sh

### BEGIN INIT INFO
# Provides:          exampledaemon
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Example
# Description:       Example start-stop-daemon - Debian
### END INIT INFO

NAME=`basename $0`
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
APP_DIR="/usr/bin"
APP_BIN="python"
APP_ARGS="-m SimpleHTTPServer 8000"
USER="minecraft"
GROUP="minecraft"

# Include functions 
set -e
. /lib/lsb/init-functions

start() {
  printf "Starting '$NAME'... "
  start-stop-daemon --start --chuid "$USER:$GROUP" --background --make-pidfile --pidfile /var/run/$NAME.pid --exec "$APP_DIR/$APP_BIN" -- $APP_ARGS || true
  printf "done\n"
}

#We need this function to ensure the whole process tree will be killed
killtree() {
    local _pid=$1
    local _sig=${2-TERM}
    for _child in $(ps -o pid --no-headers --ppid ${_pid}); do
        killtree ${_child} ${_sig}
    done
    kill -${_sig} ${_pid}
}

stop() {
  printf "Stopping '$NAME'... "
  [ -z `cat /var/run/$NAME.pid 2>/dev/null` ] || \
  while test -d /proc/$(cat /var/run/$NAME.pid); do
    killtree $(cat /var/run/$NAME.pid) 15
    sleep 0.5
  done 
  [ -z `cat /var/run/$NAME.pid 2>/dev/null` ] || rm /var/run/$NAME.pid
  printf "done\n"
}

status() {
  status_of_proc -p /var/run/$NAME.pid "" $NAME && exit 0 || exit $?
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  status)
    status
    ;;
  *)
    echo "Usage: $NAME {start|stop|restart|status}" >&2
    exit 1
    ;;
esac

exit 0