## AWS setup
These instructions were used with a separate EC2 Ubuntu instance for each environment and a shared RDS PostgreSQL instance for the DB.


### RDS

RDS setup (psql into DB):
```sql
create role gis;
create extension postgis;
create extension fuzzystrmatch;
create extension postgis_tiger_geocoder;
create extension postgis_topology;
alter schema tiger owner to rds_superuser;
alter schema topology owner to rds_superuser;
CREATE FUNCTION exec(text) returns text language plpgsql volatile AS $f$ BEGIN EXECUTE $1; RETURN $1; END; $f$;      
SELECT exec('ALTER TABLE ' || quote_ident(s.nspname) || '.' || quote_ident(s.relname) || ' OWNER TO rds_superuser;')
FROM (
       SELECT
         nspname,
         relname
       FROM pg_class c
         JOIN pg_namespace n ON (c.relnamespace = n.oid)
       WHERE nspname IN ('tiger', 'topology') AND
             relkind IN ('r', 'S', 'v')
       ORDER BY relkind = 'S')
     s;
```


RDS restore from backup (on local box):
```bash
$ pg_restore -U aed -h <RDS host> -d aed_staging <dump file>
```


Backup command (ssh onto EC2):
```bash
$ pg_dump -h $RDS_HOSTNAME -d $RDS_DB_NAME -U $RDS_USERNAME -F c -f "$RDS_DB_NAME"_$(date +%Y_%m_%d).dump
```


### EC2

Ubuntu EC2 setup (ssh onto EC2):
```bash
$ sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
$ wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
$ sudo apt-get -y update
$ sudo apt-get install -y curl gnupg build-essential postgresql-client nginx memcached nodejs
$ curl -sSL https://get.rvm.io | bash -s -- --ignore-dotfiles
$ source /home/ubuntu/.rvm/scripts/rvm
$ rvm install ruby-2.2.3
$ vim ~/.bash_profile
```


`~/.bash_profile` contents
```bash
source /home/ubuntu/.rvm/scripts/rvm
export APP_PATH=/home/ubuntu/www
export RAILS_ENV=<environment name>
export UNICORN_PORT=/tmp/unicorn.aed.sock
export RDS_DB_NAME=<RDS DB name>
export RDS_USERNAME=<RDS user>
export RDS_PASSWORD=<RDS password>
export RDS_HOSTNAME=<RDS host>
export RDS_PORT=<RDS port>
```


Ubuntu EC2 setup (continued)
```bash
$ source ~/.bash_profile
$ echo "$RDS_HOSTNAME:$RDS_PORT:$RDS_DB_NAME:$RDS_USERNAME:$RDS_PASSWORD" >> ~/.pgpass
$ sudo chmod 600 ~/.pgpass
$ mkdir www
$ cd www
$ mkdir shared
```


Ubuntu EC2 setup (continued on local box)
```bash
$ tar -cvzf aed.tar.gz --exclude=".git/" --exclude="tmp/" --exclude="log/*.*" --exclude=".idea" AEDwebsite/
$ scp -i <pemfile path> aed.tar.gz ubuntu@5<EC2 host>:/home/ubuntu/www/
```


Ubuntu EC2 setup (continue ssh'd onto EC2)
```bash
$ tar xzf aed.tar.gz && mv AEDwebsite current
$ cd current
$ gem install bundler && bundle
$ rake assets:precompile
$ cd public
$ mkdir system
$ sudo vim /etc/nginx/sites-available/default
```


`/etc/nginx/sites-available/default` contents
```nginx
upstream app {
    server unix:/tmp/unicorn.aed.sock fail_timeout=0;
}

server {
    listen 80;
    server_name <server name or IP address>;
    root /home/ubuntu/www/current/public;
    try_files $uri/index.html $uri @app;
    location @app {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://app;
    }
    error_page 500 502 503 504 /500.html;
    client_max_body_size 4G;
    keepalive_timeout 10;
}
```


Ubuntu EC2 setup (continued)
```bash
$ sudo vim /etc/init.d/unicorn
```


unicorn service file
```bash
 #!/bin/sh

### BEGIN INIT INFO
# Provides:          unicorn
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the unicorn app server
# Description:       starts unicorn using start-stop-daemon
### END INIT INFO

set -e

USAGE="Usage: $0 <start|stop|restart|upgrade|rotate|force-stop>"

# app settings
USER="ubuntu"
APP_NAME="unicorn"
APP_ROOT="/home/$USER/www/current"

# environment settings
PATH="/home/$USER/.rvm/bin:$PATH"
CMD="cd $APP_ROOT && bundle exec unicorn -c config/unicorn/production.rb -D"
PID="$APP_ROOT/public/system/unicorn.pid"
OLD_PID="$PID.oldbin"

# make sure the app exists
cd $APP_ROOT || exit 1

sig () {
  test -s "$PID" && kill -$1 `cat $PID`
}

oldsig () {
  test -s $OLD_PID && kill -$1 `cat $OLD_PID`
}

case $1 in
  start)
    sig 0 && echo >&2 "Already running" && exit 0
    echo "Starting $APP_NAME"
    su - $USER -c "$CMD"
    ;;
  stop)
    echo "Stopping $APP_NAME"
    sig QUIT && exit 0
    echo >&2 "Not running"
    ;;
  force-stop)
    echo "Force stopping $APP_NAME"
    sig TERM && exit 0
    echo >&2 "Not running"
    ;;
  restart|reload|upgrade)
    sig USR2 && echo "reloaded $APP_NAME" && exit 0
    echo >&2 "Couldn't reload, starting '$CMD' instead"
    $CMD
    ;;
  rotate)
    sig USR1 && echo rotated logs OK && exit 0
    echo >&2 "Couldn't rotate logs" && exit 1
    ;;
  *)
    echo >&2 $USAGE
    exit 1
    ;;
esac
```


Ubuntu EC2 setup (continued)
```bash
$ sudo chmod 755 /etc/init.d/unicorn
$ sudo update-rc.d unicorn defaults
$ sudo service unicorn restart
$ sudo service nginx restart
```
