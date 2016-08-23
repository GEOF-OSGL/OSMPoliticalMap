#!/bin/bash

echo "Creating temporary GRASS location and batch job."
mkdir grassdata
mkdir grassdata/wgs84
mkdir grassdata/wgs84/PERMANENT
mkdir grassdata/wgs84/data
echo "name: Lat/Lon 
proj: ll 
datum: wgs84 
ellps: wgs84 
no_defs: defined 
towgs84: 0.000,0.000,0.000" >grassdata/wgs84/PERMANENT/PROJ_INFO
echo "unit: degree 
units: degrees 
meters: 1.0" >grassdata/wgs84/PERMANENT/PROJ_UNITS
echo "proj:       3 
zone:       0 
north:      90N 
south:      90S 
east:       180E 
west:       180W 
cols:       360 
rows:       180 
e-w resol:  1 
n-s resol:  1 
top:        1.000000000000000 
bottom:     0.000000000000000 
cols3:      1 
rows3:      1 
depths:     1 
e-w resol3: 1 
n-s resol3: 1 
t-b resol:  1" >grassdata/wgs84/PERMANENT/DEFAULT_WIND
echo "wgs84" >grassdata/wgs84/PERMANENT/MYNAME
cp grassdata/wgs84/PERMANENT/DEFAULT_WIND grassdata/wgs84/PERMANENT/WIND
cp grassdata/wgs84/PERMANENT/DEFAULT_WIND grassdata/wgs84/data/WIND
