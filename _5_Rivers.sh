#!/bin/bash

cd ./PK

echo "--------------------------------------------------------------------------------------------------------"
echo "Creating rivers ..."
echo "RESULTING FILE FOR RIVERS: 05_rivers/rivers_final.shp"
echo "--------------------------------------------------------------------------------------------------------"

echo "Filtering rivers from OSM planet file..."
python ../_5_1_filter_rivers.py ../list_of_rivers.csv >filter_rivers.sh
chmod +x filter_rivers.sh
./filter_rivers.sh
rm filter_rivers.sh

#TODO: check config osmconf.ini to include tags: name,name:en,name:hr,ISO3166-1:alpha2
echo "Converting rivers to shapefile..."
ogr2ogr -f "ESRI Shapefile" -overwrite -skipfailures -nlt MULTILINESTRING -lco ENCODING=UTF-8 05_rivers osm_rivers.osm


echo "Cleaning rivers..."
python ../_5_2_clean_rivers.py ../list_of_rivers.csv 05_rivers/other_relations.shp >clean_rivers.sh
chmod +x clean_rivers.sh
./clean_rivers.sh
rm clean_rivers.sh

echo "Reprojecting rivers to Winkel Tripel projection ..."
python ../reproject_to_winkel.py 05_rivers/other_relations.shp 05_rivers/rivers_winkel.shp

echo "Deleting short rivers < 2cm on map ..."
python ../simplify_line.py 0 600000 05_rivers/rivers_winkel.shp    

echo "Performing final generalisation of coastlines ..."
python ../generalize.py 30000000 0 ./05_rivers/rivers_winkel.shp ./05_rivers/rivers_final.shp

echo "Cleaning unnecessary files: OGR shapefiles ..."
rm 05_rivers/lines.* -f
rm 05_rivers/multilinestrings.* -f
rm 05_rivers/points.* -f
rm 05_rivers/multipolygons.* -f
rm 05_rivers/other_relations.* -f
# for cleaning? rm 05_rivers/rivers_winkel.* -f
rm osm_rivers.osm -f

#TODO: dissolve, clean and generalize rivers

echo "Setting attribute fields ..."
python ../set_fields.py osm_id,name,name_en,name_hr labels=yes 05_rivers/rivers_final.shp

echo "Rivers ... Done!"
echo "--------------------------------------------------------------------------------------------------------"

