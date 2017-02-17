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
echo "Creating lakes ..."
echo "RESULTING FILE FOR LAKES: 04_lakes/lakes_final.shp"
echo "--------------------------------------------------------------------------------------------------------"

echo "Filtering lakes from OSM planet file ..."
osmfilter planet.osm.o5m --keep= --keep="natural=water" -o=osm_lakes.osm

echo "Converting lakes to shapefile."
ogr2ogr --config OSM_CONFIG_FILE ../osmconf.ini -f "ESRI Shapefile" -sql "SELECT osm_id,name,name_$OSM_LANG,intermittent FROM multipolygons" -overwrite -skipfailures -lco ENCODING=UTF-8 04_lakes osm_lakes.osm

echo "Deleting small polygons less than ~1 km2 on Earth..."
python ../simplify_polygon.py 0 0.01 04_lakes/multipolygons.shp

echo "Reprojecting lakes to Winkel Tripel projection..."
python ../reproject.py 04_lakes/multipolygons.shp 04_lakes/lakes_winkel.shp

echo "Performing final generalisation of lakes and deleting small ones <0.4 mm2 ..."
python ../generalize.py $OSM_SCALE 0.4 04_lakes/lakes_winkel.shp 04_lakes/lakes_final.shp

# this part is to handle exception of Lake Huron which does not extract correctly in previous Shapefile
echo "Handling exception: filtering Lake Huron from OSM planet ..."
osmfilter planet.osm.o5m --keep= --keep-relations="name=Lake\ Huron" -o=osm_lake_huron.osm

#echo "Using osmtogeojson as more robust tool to deal with complicated polygons ..."
nodejs --max_old_space_size=18000 `which osmtogeojson` osm_lake_huron.osm >osm_lake_huron.geojson
ogr2ogr -f "ESRI Shapefile" -sql "SELECT * from OGRGeoJSON WHERE name='Lake Huron'" -overwrite -skipfailures -nlt MULTIPOLYGON -lco ENCODING=UTF-8 04_lake_huron osm_lake_huron.geojson

python ../reproject.py 04_lake_huron/OGRGeoJSON.shp 04_lake_huron/lake_huron_winkel.shp

python ../generalize.py $OSM_SCALE 0.4 04_lake_huron/lake_huron_winkel.shp 04_lake_huron/lake_huron_final.shp

echo "Merging Lake Huron to lakes polygon file ..."
ogr2ogr -f "ESRI Shapefile" -update -append ./04_lakes/lakes_final.shp ./04_lake_huron/lake_huron_final.shp

echo "Cleaning unnecessary files: OGR shapefiles, filtered data in osm ...."
rm 04_lakes/lakes_winkel.* -f
rm 04_lake_huron -rf
rm osm_lake_huron.osm -f
rm osm_lake_huron.geojson -f
# end of exception for Lake Huron

echo "Cleaning unnecessary files: OGR shapefiles, filtered data in osm ...."
rm 04_lakes/multipolygons.* -f
rm osm_lakes.osm -f

echo "Setting attribute fields ..."
python ../set_fields.py osm_id,name,name_$OSM_LANG,intermitte labels=yes 04_lakes/lakes_final.shp

echo "Lakes ... Done!"
echo "--------------------------------------------------------------------------------------------------------"
echo

cd ..
