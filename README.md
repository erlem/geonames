# GeoNames

[GeoNames](http://www.geonames.org/ "GeoNames") is a geographical database available and accessible through various web services, under a Creative Commons attribution license.

## Database and web services

The GeoNames database contains over 10,000,000 geographical names corresponding to over 7,500,000 unique features. All features are categorized into one out of nine feature classes and further subcategorized into one out of 645 feature codes. Beyond names of places in various languages, data stored include latitude, longitude, elevation, population, administrative subdivision and postal codes. All coordinates use the World Geodetic System 1984 (WGS84).

Those data are accessible free of charge through a number of Web services and a daily database export. The Web services include direct and reverse geocoding, finding places through postal codes, finding places next to a given place, and finding Wikipedia articles about neighbouring places.

## The project

The result is a Linux shell script that allows you to download the GeoNames data dumps from  the official site and create a MySQL database structure in which you can import that dumps. 

The script has two different operation modes 
- Downloading the Geonames data dumps
- Importing the data into a MySQL database

## Use

First, clone the project:

```shell
git clone https://github.com/erlem/geonames.git
```

Go in the project geonames:

```shell
cd geonames
```

Another recommend option is to set an executable permission using the chmod command as follows:

```shell
chmod +x geonames.sh
```

Finally launch:

```shell
./geonames.sh -a all
```