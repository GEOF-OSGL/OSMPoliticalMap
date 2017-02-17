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
# create graticule for the whole world
echo
echo "--------------------------------------------------------------------------------------------------------"
echo "Creating graticule ..."
echo "RESULTING FILES FOR GRATICULE: 01_graticule/*.shp"
echo "--------------------------------------------------------------------------------------------------------"
echo
echo "Generating lines ..."
python ../_1_Graticule.py $OSM_GRATICULE 1 $OSM_LANG
echo "Reprojecting to map projection ..."
python ../reproject.py 01_graticule/meridians_wgs84.shp 01_graticule/meridians_final.shp 
python ../reproject.py 01_graticule/parallels_wgs84.shp 01_graticule/parallels_final.shp
python ../reproject.py 01_graticule/tropics_wgs84.shp 01_graticule/tropics_final.shp  
python ../reproject.py 01_graticule/frame_wgs84.shp 01_graticule/frame_final.shp    
echo "Cleaning unnecessary files ..."
rm 01_graticule/meridians_wgs84.*    
rm 01_graticule/parallels_wgs84.*    
rm 01_graticule/tropics_wgs84.*    
rm 01_graticule/frame_wgs84.*   
echo "Setting attribute fields ..."
python ../set_fields.py longitude labels=yes 01_graticule/meridians_final.shp
python ../set_fields.py latitude labels=yes 01_graticule/parallels_final.shp
python ../set_fields.py name_$OSM_LANG labels=yes 01_graticule/tropics_final.shp
echo 
echo "Graticule ... Done!"
echo "------------------------------------------------------------------------"
echo
cd ..
