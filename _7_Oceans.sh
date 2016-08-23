#!/bin/bash

cd ./PK

echo "--------------------------------------------------------------------------------------------------------"
echo "Creating oceans and seas labels ..."
echo "RESULTING FILE FOR COASTLINES: 07_oceans/oceans_final.shp"
echo "--------------------------------------------------------------------------------------------------------"

echo "Filtering: Oceans, Seas, Bays ..."
osmfilter planet.osm.o5m --keep= --keep-nodes="place=ocean or place=sea or natural=sea or place=bay" -o=osm_oceans.osm

#TODO: check config osmconf.ini to include tags: name,name:en,name:hr
echo "Converting oceans to shapefile ..."
ogr2ogr -f "ESRI Shapefile" -where "'name'!=''" -overwrite -skipfailures -nlt POINT -lco ENCODING=UTF-8 07_oceans osm_oceans.osm

echo "Reprojecting oceans to Winkel Tripel projection ..."
python ../reproject_to_winkel.py 07_oceans/points.shp 07_oceans/oceans_final.shp

echo "Cleaning unnecessary files: OGR shapefiles, filtered data in osm"
rm 07_oceans/multilinestrings.* -f
rm 07_oceans/multipolygons.* -f
rm 07_oceans/lines.* -f
rm 07_oceans/other_relations.* -f
rm osm_oceans.osm -f
rm 07_oceans/points.* -f

echo "Setting attribute fields ..."
python ../set_fields.py osm_id,name,name_en,name_hr labels=yes 07_oceans/oceans_final.shp

echo "Oceans and Seas ... Done!"
echo "------------------------------------------------------------------------------"

