#!/bin/bash
#
# The result is a Linux shell script that allows you to download the GeoNames data dumps from 
# the official site and create a MySQL database structure in which you can import that dumps. 
#
# The script has two different operation modes 
#   Downloading the Geonames data dumps
#   Importing the data into a MySQL database

# Default values for database variables.
DB_HOST="localhost"
DB_PORT=3306
DB_NAME="geonames"
DB_USERNAME="root"
DB_PASSWORD="root"

# Default values for folders.
DMP_DIR="dump"
ZIP_DIR="zip"
SQL_DIR="sql"

#######################################
# Downloading the Geonames data dumps
# Globals:
#   DMP_DIR
#   ZIP_DIR
# Arguments:
#   None
# Returns:
#   None
#######################################
download_geonames_data() {
	echo "Downloading GeoNames data (http://www.geonames.org/)..." 

	# Create the directory DMP_DIR if not exists 
	if [ ! -d "$DMP_DIR" ];then 
		echo "Creating directory [$DMP_DIR]"
		mkdir $DMP_DIR 
	fi 

	# Create the directory ZIP_DIR if not exists 
	if [ ! -d "$ZIP_DIR" ];then 
		echo "Creating directory [$ZIP_DIR]"
		mkdir -p $ZIP_DIR 
	fi 

	dumps="allCountries.zip alternateNames.zip hierarchy.zip admin1CodesASCII.txt admin2Codes.txt featureCodes_en.txt timeZones.txt countryInfo.txt"
	dump_postal_codes="allCountries.zip"

	# Folder DMP_DIR
	for dump in $dumps; do
		echo "Downloading GeoNames data http://download.geonames.org/export/dump/$dump..."
		wget -c -P $DMP_DIR http://download.geonames.org/export/dump/$dump
		if [ ${dump: -4} == ".zip" ]; then
			echo "Unzip [$dump] in [$DMP_DIR]"
			unzip -j "$DMP_DIR/$dump" -d $DMP_DIR
			echo "Deleting [$dump] in [$DMP_DIR]"
			rm "$DMP_DIR/$dump"
		fi
	done

	# Folder ZIP_DIR
	for dump in $dump_postal_codes; do
		echo "Downloading GeoNames data http://download.geonames.org/export/zip/$dump..."
		wget -c -P $ZIP_DIR http://download.geonames.org/export/zip/$dump
		echo "Unzip [$dump] in [$ZIP_DIR]"
		unzip -j "$ZIP_DIR/$dump" -d $ZIP_DIR
		echo "Deleting [$dump] in [$ZIP_DIR]"
		rm "$ZIP_DIR/$dump"
	done
}

#######################################
# Deleting DMP_DIR and ZIP_DIR folders
# Globals:
#   DMP_DIR
#   ZIP_DIR
# Arguments:
#   None
# Returns:
#   None
#######################################
download_geonames_data_delete() {
	echo "Deleting [$DMP_DIR] folders" 
	rm -R $DMP_DIR

	echo "Deleting [$ZIP_DIR] folders" 
	rm -R $ZIP_DIR	
}

#######################################
# Creating $DB_NAME database
# Globals:
#   DB_HOST
#   DB_PORT
#   DB_USERNAME
#   DB_PASSWORD
# Arguments:
#   None
# Returns:
#   None
#######################################
mysql_db_create() {
	echo "Creating database [$DB_NAME]..."
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD -Bse "DROP DATABASE IF EXISTS $DB_NAME;"
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD -Bse "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8;" 
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD -Bse "USE $DB_NAME;" 
}

#######################################
# Creating tables for $DB_NAME database
# Globals:
#   DB_HOST
#   DB_PORT
#   DB_USERNAME
#   DB_PASSWORD
#   SQL_DIR
# Arguments:
#   None
# Returns:
#   None
#######################################
mysql_db_tables_create() {
	echo "Creating tables for database [$DB_NAME]..."
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD -Bse "USE $DB_NAME;" 
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD $DB_NAME < $SQL_DIR/geonames_mysql_db_tables_create.sql
}

#######################################
# Importing geonames dumps into database $DB_NAME
# Globals:
#   DB_HOST
#   DB_PORT
#   DB_USERNAME
#   DB_PASSWORD
#   SQL_DIR
# Arguments:
#   None
# Returns:
#   None
#######################################
mysql_db_import_dumps() {
	echo "Importing GeoNames dumps into database [$DB_NAME]. Please wait a moment..."
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD --local-infile=1 $DB_NAME < $SQL_DIR/geonames_mysql_db_import_dumps.sql
}

#######################################
# Dropping $DB_NAME database
# Globals:
#   DB_HOST
#   DB_PORT
#   DB_USERNAME
#   DB_PASSWORD
# Arguments:
#   None
# Returns:
#   None
#######################################
mysql_db_drop() {
	echo "Dropping [$DB_NAME] database"
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD -Bse "DROP DATABASE IF EXISTS $DB_NAME;"
}

#######################################
# Truncating $DB_NAME database
# Globals:
#   DB_HOST
#   DB_PORT
#   DB_USERNAME
#   DB_PASSWORD
#   SQL_DIR
# Arguments:
#   None
# Returns:
#   None
#######################################
mysql_db_truncate() {
	echo "Truncating [$DB_NAME] database"
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD $DB_NAME < $SQL_DIR/geonames_mysql_db_truncate.sql
}

# Deals with operation mode 2 (Database issues...)
# Parses command line parameters.
while getopts "a:u:p:h:r:n:" opt; 
do
    case $opt in
        a) action=$OPTARG ;;
        u) dbusername=$OPTARG ;;
        p) dbpassword=$OPTARG ;;
        h) dbhost=$OPTARG ;;
        r) dbport=$OPTARG ;;
        n) dbname=$OPTARG ;;
    esac
done

case "$action" in
    db-create)
		mysql_db_create
    ;;

	tables-create)
		mysql_db_tables_create
    ;;

 	download-data)
		download_geonames_data
    ;;    

 	download-delete)
		download_geonames_data_delete
    ;;        

	db-drop)
		mysql_db_drop
    ;;

	db-truncate)
		mysql_db_truncate
    ;;    

    all)
		download_geonames_data
		mysql_db_create
		mysql_db_tables_create
		mysql_db_import_dumps
    ;;
esac

if [ $? == 0 ]; then 
	echo "[OK]"
else
	echo "[FAILED]"
fi

exit 0