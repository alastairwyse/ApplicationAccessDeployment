#!/bin/bash

#
# Copyright 2024 Alastair Wyse (https://github.com/alastairwyse/ApplicationAccessDeployment/)
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# ------------------------------------------------------------------------------
#
# Script: InitializePostreSqlDatabase.sh
# Description: Creates the default ApplicationAccess database and objects in a 
#   PostreSql instance.
#
# Platform: Alpine Linux
#
# Arguments:
#   $1 - The hostname or ip address of the PostgreSql server 
#   $2 - The PostgreSql port 
#   $3 - The PostgreSql user name 
#
# Usage Example:
#   ./InitializePostreSqlDatabase.sh 127.0.0.1 5432 postgres
#
# Required Environment Variables:
#   These must be setup via the 'export' statement if running through Linux, or 
#   via the -e parameter if passed to a docker container.
#     PGPASSWORD - e.g. 'PGPASSWORD=mypassword'
#
# ------------------------------------------------------------------------------

if [ -z "$PGPASSWORD" ]
then
    echo "ERROR: Required environment variable 'PGPASSWORD' not specified"
    exit 1
fi

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
    echo "ERROR: Required parameter not specified."
    echo "USAGE: InitializePostreSqlDatabase.sh [host/ip] [port] [username]"
    exit 1
fi

# Install psql
echo "installing psqk..."
apk --update add postgresql-client

# Create the database
echo "Creating ApplicationAccess database..."
psql -h $1 -p $2 -U $3 -c 'CREATE DATABASE applicationaccess'

# Retrieve and run the script to create the database objects
echo "Creating database schema..."
curl -O https://raw.githubusercontent.com/alastairwyse/ApplicationAccess/6facace2d08513d190c746295b6d45140a19e670/ApplicationAccess.Persistence.Sql.PostgreSql/Resources/CreateDatabase.sql
# Remove the top 8 lines (which create the database)
sed -i 1,8d CreateDatabase.sql
psql -h $1 -p $2 -U $3 -d applicationaccess -f CreateDatabase.sql
