#!/bin/bash

echo "--------------------------------------------------------------------------------------------------------"
echo "Creating coastlines ..."
echo "RESULTING FILE FOR COASTLINES - FOR CLIPPING COUNTRIES: 02_coastlines/coastlines_clip.shp"
echo "RESULTING FILE FOR COASTLINES: 02_coastlines/coastlines_final.shp"
echo "--------------------------------------------------------------------------------------------------------"
# TODO: After final countries are created, create additional coastlines of small islands and merge with coastlines_final.shp

cd ./PK


echo "Filtering coastlines from OSM planet file..."
osmfilter planet.osm.o5m --keep-nodes= --keep-relations= --keep-ways="natural=coastline" >osm_coastlines.osm

echo "Converting coastlines to shapefile ..."
ogr2ogr -f "ESRI Shapefile" -overwrite -skipfailures -nlt LINESTRING -lco ENCODING=UTF-8 02_coastlines osm_coastlines.osm

echo "Merging lines and polygons that contain coastlines..."
ogr2ogr -append -update ./02_coastlines/lines.shp ./02_coastlines/multipolygons.shp -f "Esri Shapefile"

echo "Building coastlines polygons in GRASS ... "
../grass_wgs84_location.sh
echo "v.in.ogr dsn=./02_coastlines/lines.shp layer=lines output=coastlines --overwrite -c -t 
v.build.polylines input=coastlines output=coastlines_polygons cats=no type=line 
v.out.ogr -p input=coastlines_polygons type=line dsn=./02_coastlines" >grass_coastlines.sh
chmod u+x grass_coastlines.sh
export GRASS_BATCH_JOB=./grass_coastlines.sh
grass -text $PWD/grassdata/wgs84/data
unset GRASS_BATCH_JOB


echo "Cleaning unnecessary files: grass_coastlines.sh, GRASS location files and OGR shapefiles ..."
rm grassdata -rf
rm grass_coastlines.sh -f
rm 02_coastlines/lines.* -f
rm 02_coastlines/multilinestrings.* -f
rm 02_coastlines/multipolygons.* -f
rm 02_coastlines/other_relations.* -f
rm 02_coastlines/points.* -f
rm osm_coastlines.osm
rm grass_coastlines.sh

echo "Making a hole in Euroasia where Caspian Sea is for cliping country borders to coastline also in Caspian Sea..."
python ../_2_1_caspian_sea.py ./02_coastlines/coastlines_polygons.shp


# simplify coastline polygon boundaries with tolerance 0.005 degrees, which is close to 500 meters on globe or 1/60 mm on map at scale 1:30 000 000
# remove small areas less than 500x500 m
echo "Simplifiying coastlines ..."
ogr2ogr -f "ESRI Shapefile" -lco ENCODING=UTF-8 ./02_coastlines/for_simplification.shp ./02_coastlines/coastlines_polygons.shp
python ../simplify_polygon.py 0.005 0 ./02_coastlines/for_simplification.shp
ogr2ogr -f "ESRI Shapefile" -lco ENCODING=UTF-8 ./02_coastlines/coastlines_simplified.shp ./02_coastlines/for_simplification.shp

echo "Extending Antarctica to South pole ..."
python ../_2_2_antarctica.py ./02_coastlines/coastlines_simplified.shp

echo "Reprojecting coastlines to Winkel Tripel projection..."
python ../reproject_to_winkel.py ./02_coastlines/coastlines_simplified.shp ./02_coastlines/coastlines_winkel.shp

echo "Performing generalisation of coastlines for clipping..."
python ../generalize.py 30000000 0 ./02_coastlines/coastlines_winkel.shp ./02_coastlines/coastlines_clip.shp

echo "Performing final generalisation of coastlines ..."
python ../generalize.py 30000000 1 ./02_coastlines/coastlines_winkel.shp ./02_coastlines/coastlines_final.shp

echo "Cleaning temporary files ..."
rm ./02_coastlines/for_simplification.* -f
rm ./02_coastlines/coastlines_simplified.* -f
rm ./02_coastlines/coastlines_polygons.* -f


echo "Coastlines ... Done!"
echo "--------------------------------------------------------------------------------------------------------"

