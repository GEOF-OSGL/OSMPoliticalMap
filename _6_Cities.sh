#!/bin/bash

#Copyright (C) 2016, 2017 Drazen Tutic, Tomislav Jogun, Ana Kuvezdic Divjak
#This file is part of OSMPoliticalMap software.
#
#OSMPoliticalMap is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#OSMPoliticalMap is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with OSMPoliticalMap.  If not, see <http://www.gnu.org/licenses/>.

cd $OSM_DIR
echo
echo "--------------------------------------------------------------------------------------------------------"
echo "Creating cities ..."
echo "RESULTING FILE FOR CAPITALS: 06_cities/capitals_final.shp"
echo "RESULTING FILE FOR CITIES: 06_cities/cities_final.shp"
echo "--------------------------------------------------------------------------------------------------------"

echo "Filtering cities from OSM planet file ..."
osmfilter planet.osm.o5m --keep= --keep-nodes="place=city" -o=osm_cities.osm

echo "Converting cities to shapefile ..."
ogr2ogr --config OSM_CONFIG_FILE ../osmconf.ini -f "ESRI Shapefile" -sql "SELECT * FROM points" -overwrite -skipfailures -lco ENCODING=UTF-8 06_cities osm_cities.osm

echo "Extracting ids and filtering nodes in osm_countries.osm with admin_centre role ..."
# Capitals are filtered from countries admin relations as nodes with role "admin_centre" 
python ../_6_1_admin_centers.py osm_countries.osm >capitals.sh
chmod +x capitals.sh
./capitals.sh
ogr2ogr --config OSM_CONFIG_FILE ../osmconf.ini -f "ESRI Shapefile" -sql "SELECT * FROM points" -overwrite -skipfailures -lco ENCODING=UTF-8 06_capitals osm_capitals.osm

echo "Reprojecting cities to map projection ..."
python ../reproject.py 06_cities/points.shp 06_cities/cities_final.shp
python ../reproject.py 06_capitals/points.shp 06_cities/capitals_final.shp

echo "Cleaning and filtering cities ..."
# Last argument filters cities with population less then this, it can be set even to 0, but then filtering should be done in QGIS, resulting in bigger data
# By cleaning we avoid the same cities in both files
python ../_6_2_clean_cities.py 06_cities/capitals_final.shp 06_cities/cities_final.shp 500000

echo "Cleaning unnecessary files: OGR shapefiles, filtered data in osm ..."
rm capitals.sh 
rm 06_capitals -rf
rm 06_cities/points.* -f
rm osm_cities.osm -f
rm osm_capitals.osm -f
rm osm_countries.osm -f

echo "Setting attribute fields ..."
python ../set_fields.py osm_id,name,name_$OSM_LANG,population labels=yes 06_cities/cities_final.shp
python ../set_fields.py osm_id,name,name_$OSM_LANG,population labels=yes 06_cities/capitals_final.shp

echo "Cities ... Done!"
echo "--------------------------------------------------------------------------------------------------------"
echo

cd ..


