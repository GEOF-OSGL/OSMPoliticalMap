#!/bin/bash

cd ./PK

echo "--------------------------------------------------------------------------------------------------------"
echo "Creating cities ..."
echo "RESULTING FILE FOR CAPITALS: 06_cities/capitals_final.shp"
echo "RESULTING FILE FOR CITIES: 06_cities/cities_final.shp"
echo "--------------------------------------------------------------------------------------------------------"

echo "Filtering cities from OSM planet file ..."
osmfilter planet.osm.o5m --keep= --keep-nodes="place=city or place=town" -o=osm_cities.osm

#TODO: check config osmconf.ini to include tags: name,name:en,population,admin_level,place,capital
echo "Converting cities to shapefile ..."
ogr2ogr -f "ESRI Shapefile" -overwrite -skipfailures -nlt POINT -lco ENCODING=UTF-8 06_cities osm_cities.osm

echo "Extracting ids and filtering nodes in osm_countries.osm with admin_centre role ..."
python ../_6_1_admin_centers.py osm_countries.osm >capitals.sh
chmod +x capitals.sh
./capitals.sh
ogr2ogr -f "ESRI Shapefile" -overwrite -skipfailures -nlt POINT -lco ENCODING=UTF-8 06_capitals osm_capitals.osm


echo "Reprojecting cities to Winkel Tripel projection ..."
python ../reproject_to_winkel.py 06_cities/points.shp 06_cities/cities_final.shp
python ../reproject_to_winkel.py 06_capitals/points.shp 06_cities/capitals_final.shp

echo "Cleaning and filtering cities ..."
python ../_6_2_clean_cities.py 06_cities/capitals_final.shp 06_cities/cities_final.shp 500000

echo "Cleaning unnecessary files: OGR shapefiles, filtered data in osm ..."
rm capitals.sh 
rm 06_countries.osm -f
rm 06_capitals -rf
rm osm_capitals.osm -f
rm 06_cities/lines.* -f
rm 06_cities/multilinestrings.* -f
rm 06_cities/multipolygons.* -f
rm 06_cities/other_relations.* -f
rm osm_cities.osm -f
rm 06_cities/points.* -f
rm osm_countries.osm -f

echo "Setting attribute fields ..."
python ../set_fields.py osm_id,name,name_en,population,name_hr labels=yes 06_cities/cities_final.shp
python ../set_fields.py osm_id,name,name_en,population,name_hr labels=yes 06_cities/capitals_final.shp

echo "Cities ... Done!"
echo "--------------------------------------------------------------------------------------------------------"



