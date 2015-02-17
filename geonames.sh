#!/bin/bash

# Default values for database variables.
dbhost="localhost"
dbport=3306
dbname="geonames"
dbusername="root"
dbpassword="root"


download_folder="dump"
zip_folder="zip"
dir_sql="sql"

#--------- S. TÉLÉCHARGEMENT 
download_geonames_data() {
	echo '=> Lancement du script'

	if [ ! -d "$download_folder" ];then 
		echo "=> Création du répertoire '$download_folder'"
		mkdir $download_folder 
	fi 

	if [ ! -d "$zip_folder" ];then 
		echo "=> Création du répertoire '$zip_folder'"
		mkdir -p $zip_folder 
	fi 

	echo "=> Downloading GeoNames.org data..." 

	dumps="allCountries.zip alternateNames.zip hierarchy.zip admin1CodesASCII.txt admin2Codes.txt featureCodes_en.txt timeZones.txt countryInfo.txt"
	dump_postal_codes="allCountries.zip"
	for dump in $dumps; do
		echo "=> Téléchargement de http://download.geonames.org/export/dump/$dump"
		wget -c -P $download_folder http://download.geonames.org/export/dump/$dump
		if [ ${dump: -4} == ".zip" ]; then
			echo "=> Décompresser $dump dans download_folder"
			unzip -j "$download_folder/$dump" -d $download_folder
			echo "=> Supprimer $dump dans download_folder"
			rm "$download_folder/$dump"
		fi
	done

	for dump in $dump_postal_codes; do
		echo "=> Téléchargement de http://download.geonames.org/export/zip/$dump"
		wget -c -P $zip_folder http://download.geonames.org/export/zip/$dump
		echo "=> Décompresser $dump dans zip_folder"
		unzip -j "$zip_folder/$dump" -d $zip_folder
		echo "=> Supprimer $dump dans zip_folder"
		rm "$zip_folder/$dump"
	done
}
#--------- F. TÉLÉCHARGEMENT 

db_create() {
	echo "Creating database $dbname..."
	mysql -h $dbhost -P $dbport -u $dbusername -p$dbpassword -Bse "DROP DATABASE IF EXISTS $dbname;"
	mysql -h $dbhost -P $dbport -u $dbusername -p$dbpassword -Bse "CREATE DATABASE $dbname DEFAULT CHARACTER SET utf8;" 
	mysql -h $dbhost -P $dbport -u $dbusername -p$dbpassword -Bse "USE $dbname;" 
}

db_tables_create() {
	echo "Creating tables for database $dbname..."
	mysql -h $dbhost -P $dbport -u $dbusername -p$dbpassword -Bse "USE $dbname;" 
	mysql -h $dbhost -P $dbport -u $dbusername -p$dbpassword $dbname < $dir_sql/geonames_db_struct.sql
}

db_import_dumps() {
	echo "Importing geonames dumps into database $dbname"
	mysql -h $dbhost -P $dbport -u $dbusername -p$dbpassword --local-infile=1 $dbname < $dir_sql/geonames_import_data.sql
}

db_create
db_tables_create
db_import_dumps


if [ $? == 0 ]; then 
	echo "[OK]"
else
	echo "[FAILED]"
fi

exit 0