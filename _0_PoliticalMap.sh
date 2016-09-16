#!/bin/bash

mkdir ./PK
cd ./PK
echo "Starting download of the OSM planet file ..."
wget http://ftp5.gwdg.de/pub/misc/openstreetmap/planet.openstreetmap.org/pbf/planet-latest.osm.pbf --output-document=planet.osm.pbf
echo "Starting conversion of pbf to o5m ..."
osmconvert --drop-author planet.osm.pbf -o=planet.osm.o5m
rm -f planet.osm.pbf
echo "Conversion of pbf to o5m done."
echo "-------------------------------------------------"
cd ..

./_1_Graticule.sh
./_2_Coastlines.sh
./_3_Countries.sh
./_4_Lakes.sh
./_5_Rivers.sh
./_6_Cities.sh
./_7_Oceans.sh


