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

echo
echo "--------------------------------------------------------------------------------------------------------"
echo "Creating coastlines ..."
echo "RESULTING FILE FOR CLIPPING ADMIN BOUNDARIES: 02_coastlines/coastlines_winkel.shp"
echo "RESULTING FILE FOR CLIPPING COUNTRIES POLYGONS: 02_coastlines/coastlines_clip.shp"
echo "RESULTING FILE FOR COASTLINES: 02_coastlines/coastlines_final.shp"
echo "--------------------------------------------------------------------------------------------------------"
echo

cd $OSM_DIR

echo "Filtering coastlines from OSM planet file ..."
osmfilter planet.osm.o5m --keep-nodes= --keep-relations= --keep-ways="natural=coastline" >osm_coastlines.osm

echo "Converting coastlines to shapefile ..."
ogr2ogr --config OSM_CONFIG_FILE ../osmconf.ini -f "ESRI Shapefile" -sql "SELECT osm_id FROM lines" -overwrite -skipfailures -nlt LINESTRING -lco ENCODING=UTF-8 02_coastlines osm_coastlines.osm
ogr2ogr --config OSM_CONFIG_FILE ../osmconf.ini -f "ESRI Shapefile" -sql "SELECT osm_id FROM multipolygons" -overwrite -skipfailures -nlt LINESTRING -lco ENCODING=UTF-8 02_coastlines osm_coastlines.osm

echo "Merging lines and polygons that contain coastlines ..."
ogr2ogr -f "ESRI Shapefile" -append -update ./02_coastlines/lines.shp ./02_coastlines/multipolygons.shp 

echo "Building coastlines polygons in GRASS GIS... "
../grass_wgs84_location.sh
echo "v.in.ogr dsn=./02_coastlines/lines.shp layer=lines output=coastlines --overwrite -c -t 
v.build.polylines input=coastlines output=coastlines_polygons cats=first type=line 
v.out.ogr -p input=coastlines_polygons type=line dsn=./02_coastlines" >grass_coastlines.sh
chmod u+x grass_coastlines.sh
export GRASS_BATCH_JOB=./grass_coastlines.sh
grass -text $PWD/grassdata/wgs84/data
unset GRASS_BATCH_JOB

echo "Cleaning unnecessary files: grass_coastlines.sh, GRASS location files and OGR shapefiles ..."
rm grassdata -rf
rm grass_coastlines.sh -f
rm 02_coastlines/lines.* -f
rm 02_coastlines/multipolygons.* -f
rm osm_coastlines.osm

echo "Making a hole in Euroasia where Caspian Sea is. This is for cliping country borders to coastline of Caspian Sea ..."
python ../_2_1_caspian_sea.py ./02_coastlines/coastlines_polygons.shp

# Simplify coastline polygon boundaries with tolerance of ~1/60 mm on map. 
# This is only for performance and resources optimization and it is expected not to influence the final result
echo "Simplifiying coastlines to reduce number of vertices, requires GDAL with GEOS support ..."
ogr2ogr -f "ESRI Shapefile" -lco ENCODING=UTF-8 -simplify $(echo "scale=6; $OSM_SCALE/1000/6370000" | bc) ./02_coastlines/coastlines_simplified.shp ./02_coastlines/coastlines_polygons.shp

echo "Extending Antarctica to South pole ..."
python ../_2_2_antarctica.py ./02_coastlines/coastlines_simplified.shp

echo "Reprojecting coastlines to map projection ..."
python ../reproject.py ./02_coastlines/coastlines_simplified.shp ./02_coastlines/coastlines_winkel.shp

echo "Performing generalisation of coastlines for clipping the countries ..."
python ../generalize.py $OSM_SCALE 0 ./02_coastlines/coastlines_winkel.shp ./02_coastlines/coastlines_clip.shp

echo "Preparing final coastlines by filtering small areas < 0.8 mm2 on the map ..."
ogr2ogr -f "ESRI Shapefile" -lco ENCODING=UTF-8 ./02_coastlines/coastlines_filtered.shp ./02_coastlines/coastlines_clip.shp
python ../simplify_polygon.py 0 $[$OSM_SCALE * $OSM_SCALE / 1000000 * 8 / 10] ./02_coastlines/coastlines_filtered.shp
ogr2ogr -f "ESRI Shapefile" -lco ENCODING=UTF-8 ./02_coastlines/coastlines_final.shp ./02_coastlines/coastlines_filtered.shp

echo "Cleaning temporary files ..."
rm ./02_coastlines/for_simplification.* -f
rm ./02_coastlines/coastlines_simplified.* -f
rm ./02_coastlines/coastlines_polygons.* -f
rm ./02_coastlines/coastlines_filtered.* -f

echo "Coastlines ... Done!"
echo "--------------------------------------------------------------------------------------------------------"
echo

cd ..

