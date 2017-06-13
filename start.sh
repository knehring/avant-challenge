#!/bin/bash

# This scripts purpose is to build and start up the docker containers for the
# application, it will also perform the creation of the database for the app
# and migrate any tables. It will also seed data into the database for testing purposes
# This would not be used in production and many of these would be handled inside
# of the CI system such as Jenkins or the container orchestrator/scheduler (ECS).

# If any of the following commands fail then don't run subsequent commands
set -e

sudo docker-compose build
sudo docker-compose up -d
sudo docker-compose run web rake db:create
sudo docker-compose run web rake db:migrate RAILS_ENV=development
sudo docker-compose run web rake db:seed
