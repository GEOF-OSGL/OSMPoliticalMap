#!/bin/bash

cd ./PK

echo "--------------------------------------------------------------------------------------------------------"
echo "Creating rivers ..."
echo "RESULTING FILE FOR RIVERS: 05_rivers/rivers_final.shp"
echo "--------------------------------------------------------------------------------------------------------"

#TODO: Script uses list of names of world longest rivers for filtering, some simple query for rivers filtering should be found
echo "Filtering rivers from OSM planet file ..."
python ../_5_1_filter_rivers.py ../list_of_rivers.csv >filter_rivers.sh
chmod +x filter_rivers.sh
./filter_rivers.sh
rm filter_rivers.sh

#TODO: Check config osmconf.ini to include tags 'name' and 'name:en' together with tag for map language, e.g. 'name:hr' for Croatian
echo "Converting rivers to shapefile ..."
ogr2ogr --config OSM_CONFIG_FILE ../osmconf.ini -f "ESRI Shapefile" -overwrite -skipfailures -nlt MULTILINESTRING -lco ENCODING=UTF-8 05_rivers osm_rivers.osm

#TODO: Filtering by names give a lot of features that are not rivers centerlines, this should be avoided in filtering phase
echo "Cleaning rivers, there is a lot of mess in filtered data ..."
python ../_5_2_clean_rivers.py ../list_of_rivers.csv 05_rivers/other_relations.shp >clean_rivers.sh
chmod +x clean_rivers.sh
./clean_rivers.sh
rm clean_rivers.sh

echo "Reprojecting rivers to selected map projection ..."
#TODO: Check that parameters for selected map projection are given in reproject.py
python ../reproject.py 05_rivers/other_relations.shp 05_rivers/rivers_winkel.shp

echo "Deleting short rivers on map ..."
#TODO: Second parameter is to be calculated from map scale, current = 2 cm
python ../simplify_line.py 0 600000 05_rivers/rivers_winkel.shp    

echo "Dissolving and smoothing rivers using vector-raster-vector conversion in GRASS ..."
#TODO: 'res' parameter in g.region is to be calculated from map scale, current = 0.1 mm
#TODO: 'thresh' parameter in v.clean is to be calculated from map scale, current = 1 mm
# Rivers are rasterized, edge filtering and hole filling is performed twice, raster is then thined and vectorised, and finally vectors are cleaned and attributes copied 
../grass_fake_winkel_location.sh
echo "v.in.ogr -o --overwrite dsn=./05_rivers/rivers_winkel.shp output=rivers_winkel 
 g.region vect=rivers_winkel res=3000
 v.to.rast --overwrite input=rivers_winkel layer=1 type=point,line,area output=smooth use=cat 
 r.mapcalc \"smooth1=if(smooth[-1,0] &&& smooth[0,1] &&& smooth[1,0],smooth[0,1],null())\"
 r.mapcalc \"smooth=if(isnull(smooth1),smooth,smooth1)\"
 r.mapcalc \"smooth1=if(smooth[-1,0] &&& smooth[0,-1] &&& smooth[1,0],smooth[0,-1],null())\"
 r.mapcalc \"smooth=if(isnull(smooth1),smooth,smooth1)\"
 r.mapcalc \"smooth1=if(smooth[0,-1] &&& smooth[1,0] &&& smooth[0,1],smooth[1,0],null())\"
 r.mapcalc \"smooth=if(isnull(smooth1),smooth,smooth1)\"
 r.mapcalc \"smooth1=if(smooth[0,-1] &&& smooth[-1,0] &&& smooth[0,1],smooth[-1,0],null())\"
 r.mapcalc \"smooth=if(isnull(smooth1),smooth,smooth1)\"
 r.mapcalc \"smooth1=if(smooth[-1,0] &&& smooth[0,1] &&& smooth[1,0],smooth[0,1],null())\"
 r.mapcalc \"smooth=if(isnull(smooth1),smooth,smooth1)\"
 r.mapcalc \"smooth1=if(smooth[-1,0] &&& smooth[0,-1] &&& smooth[1,0],smooth[0,-1],null())\"
 r.mapcalc \"smooth=if(isnull(smooth1),smooth,smooth1)\"
 r.mapcalc \"smooth1=if(smooth[0,-1] &&& smooth[1,0] &&& smooth[0,1],smooth[1,0],null())\"
 r.mapcalc \"smooth=if(isnull(smooth1),smooth,smooth1)\"
 r.mapcalc \"smooth1=if(smooth[0,-1] &&& smooth[-1,0] &&& smooth[0,1],smooth[-1,0],null())\"
 r.mapcalc \"smooth=if(isnull(smooth1),smooth,smooth1)\"
 r.mapcalc \"smooth=if(isnull(smooth[0,-1]) && isnull(smooth[-1,-1]) && isnull(smooth[-1,0]) && isnull(smooth[-1,1]) && isnull(smooth[0,1]),null(),smooth)\"
 r.mapcalc \"smooth=if(isnull(smooth[0,-1]) && isnull(smooth[1,-1]) && isnull(smooth[1,0]) && isnull(smooth[1,1]) && isnull(smooth[0,1]),null(),smooth)\"
 r.mapcalc \"smooth=if(isnull(smooth[-1,0]) && isnull(smooth[-1,1]) && isnull(smooth[0,1]) && isnull(smooth[1,1]) && isnull(smooth[1,0]),null(),smooth)\"
 r.mapcalc \"smooth=if(isnull(smooth[-1,0]) && isnull(smooth[-1,-1]) && isnull(smooth[0,-1]) && isnull(smooth[1,-1]) && isnull(smooth[1,0]),null(),smooth)\"
 r.mapcalc \"smooth=if(isnull(smooth[0,-1]) && isnull(smooth[-1,-1]) && isnull(smooth[-1,0]) && isnull(smooth[-1,1]) && isnull(smooth[0,1]),null(),smooth)\"
 r.mapcalc \"smooth=if(isnull(smooth[0,-1]) && isnull(smooth[1,-1]) && isnull(smooth[1,0]) && isnull(smooth[1,1]) && isnull(smooth[0,1]),null(),smooth)\"
 r.mapcalc \"smooth=if(isnull(smooth[-1,0]) && isnull(smooth[-1,1]) && isnull(smooth[0,1]) && isnull(smooth[1,1]) && isnull(smooth[1,0]),null(),smooth)\"
 r.mapcalc \"smooth=if(isnull(smooth[-1,0]) && isnull(smooth[-1,-1]) && isnull(smooth[0,-1]) && isnull(smooth[1,-1]) && isnull(smooth[1,0]),null(),smooth)\" 
 r.thin input=smooth output=thin iterations=200 
 r.to.vect -v --overwrite input=thin output=thin feature=line
 v.clean input=thin output=clean type=line tool=rmdangle thres=30000 --overwrite
 v.build.polylines --overwrite input=clean output=builded_rivers cats=first
 v.db.connect -o map=builded_rivers table=rivers_winkel
 v.out.ogr -c input=builded_rivers type=line dsn=./05_rivers lco=ENCODING=UTF-8" >grass_rivers.sh
chmod u+x grass_rivers.sh
export GRASS_BATCH_JOB=./grass_rivers.sh
grass -text $PWD/grassdata/winkel/data
unset GRASS_BATCH_JOB

echo "Cleaning unnecessary files: GRASS location files, temporary scripts ...."
rm grassdata -rf
rm grass_rivers.sh -f

echo "Performing final generalisation of rivers ..."
#TODO: First argument is map scale denominator, current = 30 000 000
python ../generalize.py 30000000 0 ./05_rivers/builded_rivers.shp ./05_rivers/rivers_final.shp

echo "Cleaning unnecessary files: OGR shapefiles ..."
rm 05_rivers/lines.* -f
rm 05_rivers/multilinestrings.* -f
rm 05_rivers/points.* -f
rm 05_rivers/multipolygons.* -f
rm 05_rivers/other_relations.* -f
rm 05_rivers/builded_rivers.* -f
rm 05_rivers/rivers_winkel.* -f
rm osm_rivers.osm -f

echo "Setting attribute fields ..."
#TODO: Set appropriate tag for map language, e.g. name_hr for Croatian
python ../set_fields.py osm_id,name,name_en,name_hr labels=yes 05_rivers/rivers_final.shp

echo "Rivers ... Done!"
echo "--------------------------------------------------------------------------------------------------------"
