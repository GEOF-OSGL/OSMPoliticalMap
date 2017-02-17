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
echo "Creating oceans and seas labels ..."
echo "RESULTING FILE FOR COASTLINES: 07_oceans/oceans_final.shp"
echo "--------------------------------------------------------------------------------------------------------"

echo "Filtering: Oceans, Seas, Bays ..."
osmfilter planet.osm.o5m --keep= --keep-nodes="place=ocean or place=sea or natural=sea or place=bay" -o=osm_oceans.osm

echo "Converting oceans to shapefile ..."
ogr2ogr --config OSM_CONFIG_FILE ../osmconf.ini -f "ESRI Shapefile" -sql "SELECT * FROM points WHERE name != ''" -overwrite -skipfailures -nlt POINT -lco ENCODING=UTF-8 07_oceans osm_oceans.osm

echo "Reprojecting oceans to map projection ..."
python ../reproject.py 07_oceans/points.shp 07_oceans/oceans_final.shp

echo "Cleaning unnecessary files: OGR shapefiles, filtered data in osm"
rm osm_oceans.osm -f
rm 07_oceans/points.* -f

echo "Setting attribute fields ..."
python ../set_fields.py osm_id,name,name_$OSM_LANG labels=yes 07_oceans/oceans_final.shp

echo "Oceans and Seas ... Done!"
echo "------------------------------------------------------------------------------"
echo

cd ..
