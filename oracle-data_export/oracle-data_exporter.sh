#!/bin/bash

# Load database connection info
source oracle-data_export/.env

# Read query into a variable
sql="$(cat oracle-data_export/oracle-query.sql)"

# If sqlplus is not installed, then exit
if ! command -v oracle-data_export/instantclient_19_6/sqlplus.exe > /dev/null; then
  echo "SQL*Plus est nécessaire pour exécuter ce script..."
  exit 1
fi

# Connect to the database, run the query, then disconnect
echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sql" | \
oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))" > csv/raw/raw-oracle-data.csv

#Put commas instead of spaces in CSV
sed -e 's/\s\+/,/g' csv/raw/raw-oracle-data.csv > csv/raw/temp-oracle-data
#Add "Etiquette" to each lines
sed 's/^/,Moy_Ram/' csv/raw/temp-oracle-data > csv/raw/raw-oracle-data.csv
#Add "Cible" to each lines
sed 's/^/,u3recu111/' csv/raw/raw-oracle-data.csv > csv/raw/temp-oracle-data
#Add dates to CSV
cat csv/raw/temp-oracle-data | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> csv/formatted/Capa-Oracle
#Removing the temp file
rm csv/raw/temp-oracle-data
echo "Oracle data correctly formatted to CSV normalisation."
