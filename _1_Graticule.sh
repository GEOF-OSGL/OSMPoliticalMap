#!/bin/bash

cd ./PK

# create graticule for the whole world
# USAGE: python _1_Graticule step density
# "step" is integer distance between meridians and parallels
# "density" is float distance between vertices in meridians and paralles
# output will be in directory PK/01_graticule with shapefiles frame_final.shp, meridians_final.shp, parallels_final.shp, tropics_final.shp

echo "--------------------------------------------------------------------------------------------------------"
echo "Creating graticule ..."
echo "RESULTING FILES FOR GRATICULE: 01_graticule/*.shp"
echo "--------------------------------------------------------------------------------------------------------"

echo "Generating lines ..."
python ../_1_Graticule.py 10 1

echo "Reprojecting to Winkel Tripel projection ..."
python ../reproject_to_winkel.py 01_graticule/meridians_wgs84.shp 01_graticule/meridians_final.shp 
python ../reproject_to_winkel.py 01_graticule/parallels_wgs84.shp 01_graticule/parallels_final.shp
python ../reproject_to_winkel.py 01_graticule/tropics_wgs84.shp 01_graticule/tropics_final.shp  
python ../reproject_to_winkel.py 01_graticule/frame_wgs84.shp 01_graticule/frame_final.shp    

echo "Cleaning unnecessary files ..."
rm 01_graticule/meridians_wgs84.*    
rm 01_graticule/parallels_wgs84.*    
rm 01_graticule/tropics_wgs84.*    
rm 01_graticule/frame_wgs84.*   

echo "Setting attribute fields ..."
python ../set_fields.py longitude labels=yes 01_graticule/meridians_final.shp
python ../set_fields.py latitude labels=yes 01_graticule/parallels_final.shp
python ../set_fields.py name_en,name_hr labels=yes 01_graticule/tropics_final.shp
 
echo "Graticule ... Done!"
echo "------------------------------------------------------------------------"

