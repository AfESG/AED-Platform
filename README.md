# African Elephant Database

This is the web application for the African Elephant Database (www.AfricanElephantDatabase.org).

## Hosting Stack

- **Application Server**: DigitalOcean One-click app Dokku Droplet with Nginx/Puma
- **Database**: DigitalOcean One-click app Dokku Droplet with PostgreSQL 9.6, PostGIS 2.4
- **Memcached**: DigitalOcean One-click app Dokku Droplet with Memcached
- **Email Delivery**: AWS Simple Email Service
- **DNS**: AWS Route53

**NOTE**: The application server, database server, and memcached server are all hosted on a single Droplet in their own containers. This droplet also hosts all the environments (production, staging, dev, etc.).

## Docker Development Environment Setup

- Install [Docker](https://www.docker.com/) and Docker Compose
- Create the `.env` file per instructions in the "Development Environment Setup" below
- Spin up the containerized environment
  - `docker-compose up -d`
  - *NOTE: if you have issues you can always `docker-compose down && docker-compose up -d`
- Set up the database
  - `createdb -h 0.0.0.0 -U postgres -p 6543 aed_development`
  - `createuser -h 0.0.0.0 -U postgres -p 6543 --superuser root`
- Load the most recent dump into the DB
  - `pg_restore -U postgres -h 0.0.0.0 -p 6543 -d aed_development --verbose <dump file>`
  - *NOTE: if this fails just run the above command multiple times until it doesn't fail*
- View the local development site
  - Open `http://localhost:3000` in a web browser

## Docker Development Environment helpful commands

- To tail logs:
  - `docker-compose logs -f`
- To destroy the local database (if a clean setup is desired):
  - `docker volume rm aed-platform_db_storage`
- To rebuild app container (needed if adding gems to `Gemfile`):
  - `docker-compose build app`

## Development Environment Setup

- Clone the repository
- Install Ruby and Bundler
- Install PostgreSQL 9.6
- Install PostGIS 2.5 (https://postgis.net/install)
  - `sudo apt install postgresql-9.6-postgis-2.5`
- Install the GEOS library. This library must be installed before `bundle install` (or before the "rgeo" GEM is installed)
  - `sudo apt install libgeos-dev`
  - If shapefile imports fail then reinstall rgeo:
    - `gem uninstall rgeo`, `sudo apt install libgeos-dev`, `gem install rgeo`
- `bundle install`
- `rake db:create`
- Load the database: use a production copy or `rake db:reset` to get an empty database.
- Prepare the "test" database: `bundle exec rake db:reset RAILS_ENV=test`
  - Run tests: `rake`
- Create a '.env' file at the root of the project with the following variables:
  ```bash
  DOMAIN=test.com
  AWS_ACCESS_KEY_ID=
  AWS_SECRET_ACCESS_KEY=
  AWS_DEFAULT_REGION=eu-central-1
  REQUEST_FORM_SUBMITTED_TO_EMAIL=
  REQUEST_FORM_SUBMITTED_BCC_EMAIL=
  REQUEST_FORM_THANKS_BCC_EMAIL=
  GOOGLE_ANALYTICS_TRACKING_ID=u-disabled-1
  RECAPTCHA_SITE_KEY=
  RECAPTCHA_SECRET_KEY=
  ```
  - Fill in the blanks with your development values.
  - It is recommended you create your own reCAPTCHA key/secret for your development environment [here](https://www.google.com/recaptcha/admin)
  - See [aed_env.rb](app/lib/aed_env.rb) for complete list of environment variables.

## Setup DigitalOcean Droplet

- Login into the AED account on DigitalOcean.
- Click **Create** then select **Droplets**.
- Click on **One-click apps**.
- Choose an image:
  - Select **Dokku 0.12.13 on 18.04** (or whatever the latest versions are).
- Choose a size:
  - **$40/mo**
  - 8 GB / 4 CPUs
  - 160 GB SSD disk
  - 5 TB transfer
- Add backups:
  - Enable this.
- Add block storage:
  - Skip this section.
- Choose a datacenter region:
  - Select **Frankfurt**
- Select additional options:
  - Select **Monitoring**
- Add your SSH key:
  - Add or select your SSH key.
- Finalize and create:
  - How many Droplets?: **1**
  - Choose a hostname: **africanelephantdatabase.org**
- Click the **Create** button.
- Wait for the Droplet to be created and started.
- Open the Droplet’s IP address in your web browser.
  - ADMIN ACCESS:
    - Public Key: Enter your key unless already populated.
  - HOSTNAME CONFIGURATION:
    - Hostname: **africanelephantdatabase.org**
    - Select **Use virtualhost naming for apps**
  - Click **Finish Setup**
- Log into the AED AWS Console and open Route53.
- Open the record set for africanelephantdatabase.org.
- Change each of the africanelephantdatabase.org records so they point to the IP address of the newly created Droplet.

## Create a New Application Instance

- SSH into the Droplet: `ssh root@africanelephantdatabase.org`
- Copy the [create-app-.sh](script/dokku/create-app.sh) script to the droplet.
- Run the create-app script: `./create-app.sh`
- Follow the prompts in the script.
- Add a git remote for the new instance. The script will print out the command to run.
  - Example: `git remote add production dokku@africanelephantdatabase.org:production`
- Push your code to the new instance. 
  - Example: `git push production master`

## Deployments

1. Add the GIT remotes:
   - `git remote add production dokku@africanelephantdatabase.org:production`
   - `git remote add staging dokku@africanelephantdatabase.org:staging`
2. Push your branch to a specific remote:
   - Production:`git push production master`
   - Staging: `git push staging master`
   - Or push a specific branch: `git push production my-branch:master`

Note: This application uses multiple buildpacks. The GEOS buildpack is located at: https://github.com/AfESG/heroku-geo-buildpack

## Backups

- The Droplet will be configured to take complete backups once a week.
  - This is standard feature that DigitalOcean provides for an extra fee.
- All non-Droplet backups will be stored on AWS S3 in the `aed-server-backups` bucket. Under this bucket each app will have its own folder where the backup files are stored.
- The PostgreSQL database backups are scheduled to run daily at 3AM and will be stored on S3.
  - This backup is scheduled via the Postgres Dokku plugin and runs via cron.
- The application's storage folder (`/var/lib/dokku/data/storage/<app-name>`) is scheduled to run daily at 3AM and will be stored on S3.
  - This backup is scheduled via the root users cron in `/etc/cron.d/storage-backup-<app-name>`
  - This folder is mapped to the application’s container and currently stores:
    - population_submission_attachments

## DevOps

All commands should be run as the root user unless stated otherwise.

- SSH into the server: `ssh root@africanelephantdatabase.org`
  - Note: You must have a certificate key installed on your system and on the Droplet to gain access.
    - See [User Management](http://dokku.viewdocs.io/dokku~v0.12.13/deployment/user-management/) for more information.
- List running instances: `dokku apps:list`
- Restart an app: `dokku ps:restart <app-name>`
  - Example: `dokku ps:restart production`
  - Note: Each application will be automatically restarted every day at midnight.
- Restart a database: `dokku postgres:restart <app-name>`
  - Example: `dokku postgres:restart production`
- List Docker containers: `docker container ls`
- Manually Backup Postgresql: `dokku postgres:backup <app-name> aed-server-backups/<app-name>`
  - Example: `dokku postgres:backup production aed-server-backups/production`
  - Note: You should never have to do this since the backups happen automatically every night.
- Manually Backup the `storage` directory:
  - `/home/dokku/<app-name>/backup.sh`
    - Example: `/home/dokku/production/backup.sh`
    - Note: You should never have to do this since the backups happen automatically every night.
- Database information `dokku postgres:info <production|staging|dev>`
- Expose a database connection `dokku postgres:expose <production|staging|dev> <ports...>`
- Un-expose a database connection (recommended after done accessing) `dokku postgres:unexpose <production|staging|dev>`
- Tail application logs `dokku logs <production|staging|dev> --tail`

File Paths
- `/home/dokku/<app-name>`
  - Root directory for each application.
- `/home/dokku/<app-name>/backups`
  - Backups directory (per application). The "storage" backups will be created in this directory then uploaded to S3. This directory cleans itself out every time it syncs with S3.
- `/home/dokku/<app-name>/storage_backup.sh`
  - Script that backs up the "storage" directory. 
- `/var/lib/dokku/data/storage/<app-name>`
  - Mounted storage location (per application).
  - `/var/lib/dokku/data/storage/<app-name>/volumes/public/system/population_submission_attachments`
    - Holds all the "Population Submission Attachments". This is mapped to `/app/public/system` in the container.
- `/etc/cron.d`
  - Cron jobs for each app:
    - `restart-<app-name>`
      - Cron job for nightly application restarts.
    - `storate-backup-<app-name>`
      - Cron job for nightly "storage" backups.
    - `dokku-postgres-<app-name>`
      - Cron job for nightly PostgreSQL database backups.
- `/etc/nginx/conf.d/00-default-vhost.conf`
  - Nginx custom configuration.
