#!/bin/bash

cd ./PK

echo "--------------------------------------------------------------------------------------------------------"
echo "Creating lakes ..."
echo "RESULTING FILE FOR LAKES: 04_lakes/lakes_final.shp"
echo "--------------------------------------------------------------------------------------------------------"

echo "Filtering lakes from OSM planet file ..."
osmfilter planet.osm.o5m --keep= --keep="natural=water" -o=osm_lakes.osm

echo "Converting lakes to shapefile."
ogr2ogr -f "ESRI Shapefile" -overwrite -skipfailures -nlt PROMOTE_TO_MULTI -lco ENCODING=UTF-8 04_lakes osm_lakes.osm

echo "Cleaning unnecessary files: OGR shapefiles ...."
rm 04_lakes/lines.* -f
rm 04_lakes/multilinestrings.* -f
rm 04_lakes/points.* -f
rm 04_lakes/other_relations.* -f
rm osm_lakes.osm -f


echo "Handling exception: filtering lakes from OSM planet file for Lake Huron..."
osmfilter planet.osm.o5m --keep= --keep="natural=water and water=lake" -o=osm_lake_huron.osm

echo "Converting Lake Huron to shapefile."
ogr2ogr -f "ESRI Shapefile" -overwrite -skipfailures -nlt LINESTRING -lco ENCODING=UTF-8 04_lake_huron osm_lake_huron.osm

echo "Cleaning unnecessary files: OGR shapefiles, filtered data in osm ...."
rm 04_lake_huron/lines.* -f
rm 04_lake_huron/multilinestrings.* -f
rm 04_lake_huron/points.* -f
rm 04_lake_huron/multipolygons.* -f
rm osm_lake_huron.osm -f


echo "Converting Lake Huron to polygons in GRASS..."
../grass_wgs84_location.sh
echo "v.in.ogr dsn=./04_lake_huron/other_relations.shp output=huron_line --overwrite -o
 v.type --overwrite input=huron_line output=huron_boundary type=line,boundary 
 v.centroids input=huron_boundary output=huron_polygons option=add layer=1 cat=1 step=1 --overwrite 
 v.out.ogr -c input=huron_polygons type=area dsn=./04_lake_huron" >grass_huron.sh
chmod u+x grass_huron.sh
export GRASS_BATCH_JOB=./grass_huron.sh
grass -text $PWD/grassdata/wgs84/data
unset GRASS_BATCH_JOB

echo "Cleaning unnecessary files: GRASS location files, temporary scripts ...."
rm grassdata -rf

echo "Merging Lake Huron to lakes polygon file ..."
ogr2ogr -f "ESRI Shapefile" -update -append ./04_lakes/multipolygons.shp ./04_lake_huron/huron_polygons.shp

echo "Cleaning temp files for Lake Huron ..."
rm 04_lake_huron -rf
rm grass_huron.sh -f


echo "Reprojecting lakes to Winkel Tripel projection..."
python ../reproject_to_winkel.py 04_lakes/multipolygons.shp 04_lakes/lakes_winkel.shp

echo "Cleaning lakes polygons in GRASS ..."
../grass_fake_winkel_location.sh
# v.db.addtable map=lakes_clean table=new columns='cat integer, dissolve integer'
echo "v.in.ogr -o --overwrite dsn=./04_lakes/lakes_winkel.shp output=lakes_winkel min_area=200000 snap=1e-3
 v.centroids --overwrite input=lakes_winkel output=lakes_clean
 v.edit map=lakes_clean type=centroid tool=delete bbox=-6418000,5284000,-6415000,5282000 
 v.db.addcol map=lakes_clean columns='dissolve integer'
 v.db.update map=lakes_clean column=dissolve value=1
 v.dissolve --overwrite input=lakes_clean output=lakes_dissolved column=dissolve 
 v.out.ogr -c input=lakes_dissolved type=area dsn=./04_lakes lco=ENCODING=UTF-8" >grass_lakes.sh
chmod u+x grass_lakes.sh
export GRASS_BATCH_JOB=./grass_lakes.sh
grass -text $PWD/grassdata/winkel/data
unset GRASS_BATCH_JOB

echo "Cleaning unnecessary files: GRASS location files, temporary scripts ...."
rm grassdata -rf
rm grass_lakes.sh -f

echo "Performing final generalisation of lakes..."
python ../generalize.py 30000000 0.4 04_lakes/lakes_dissolved.shp 04_lakes/lakes_final.shp

echo "Cleaning unnecessary files: OGR shapefiles, filtered data in osm ...."
rm 04_lakes/lakes_dissolved.* -f
rm 04_lakes/lakes_winkel.* -f

echo "Setting attribute fields ..."
python ../set_fields.py osm_id,name,name_en,name_hr labels=yes 04_lakes/lakes_final.shp

echo "Lakes ... Done!"
echo "--------------------------------------------------------------------------------------------------------"

