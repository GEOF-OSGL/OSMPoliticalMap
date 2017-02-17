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
echo "Creating rivers ..."
echo "RESULTING FILE FOR RIVERS: 05_rivers/rivers_final.shp"
echo "--------------------------------------------------------------------------------------------------------"

echo "Filtering rivers defined as relations in OSM planet file ..."
osmfilter planet.osm.o5m --keep= --keep-relations="waterway=river" -o=osm_rivers.osm

echo "Converting rivers to shapefile ..."
ogr2ogr --config OSM_CONFIG_FILE ../osmconf.ini -f "ESRI Shapefile" -sql "select * from other_relations where type='waterway'" -overwrite -skipfailures -nlt MULTILINESTRING -lco ENCODING=UTF-8 05_rivers osm_rivers.osm

echo "Reprojecting rivers to map projection ..."
python ../reproject.py 05_rivers/other_relations.shp 05_rivers/rivers_winkel.shp

echo "Deleting short rivers on map ..."
#Second parameter set threshold for short rivers, current = 3 cm
python ../simplify_line.py 0 $[$OSM_SCALE / 100 * 3] 05_rivers/rivers_winkel.shp    

echo "Dissolving and smoothing rivers using vector-raster-vector conversion in GRASS ..."
# 'res' parameter in g.region is set to 0.03 mm
# 'thresh' parameter in v.clean is to to 5 mm
# Rivers are rasterized, edge filtering is performed twice, raster is then thined and vectorised, and finally vectors are cleaned and attributes copied 
../grass_xy_location.sh
echo "v.in.ogr -o --overwrite dsn=./05_rivers/rivers_winkel.shp output=rivers_winkel 
 g.region vect=rivers_winkel res=$[$OSM_SCALE / 10000]
 v.db.addcol rivers_winkel column=\"length_km double precision\"
 v.to.db rivers_winkel type=line option=length units=k column=length_km
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
 r.thin --overwrite input=smooth output=thin iterations=200 
 r.to.vect -v --overwrite input=thin output=thin feature=line
 v.clean input=thin output=clean type=line tool=rmdangle,rmdangle thres=$[$OSM_SCALE / 1500],$[$OSM_SCALE / 500] --overwrite
 v.build.polylines --overwrite input=clean output=builded_rivers cats=first
 v.db.connect -o map=builded_rivers table=rivers_winkel
 v.out.ogr --overwrite -c input=builded_rivers type=line dsn=./05_rivers lco=ENCODING=UTF-8" >grass_rivers.sh
chmod u+x grass_rivers.sh
export GRASS_BATCH_JOB=./grass_rivers.sh
grass -text $PWD/grassdata/xy/data
unset GRASS_BATCH_JOB

echo "Cleaning unnecessary files: GRASS location files, temporary scripts ...."
rm grassdata -rf
rm grass_rivers.sh -f


echo "Performing final generalisation of rivers ..."
python ../generalize.py $OSM_SCALE 0 ./05_rivers/builded_rivers.shp ./05_rivers/rivers_final.shp


echo "Cleaning unnecessary files: OGR shapefiles ..."
rm 05_rivers/other_relations.* -f
rm 05_rivers/builded_rivers.* -f
rm 05_rivers/rivers_winkel.* -f
rm osm_rivers.osm -f

echo "Setting attribute fields ..."
python ../set_fields.py osm_id,name,name_$OSM_LANG labels=yes 05_rivers/rivers_final.shp

echo "Rivers ... Done!"
echo "--------------------------------------------------------------------------------------------------------"
echo 

cd ..
