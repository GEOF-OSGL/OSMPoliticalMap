#!/bin/bash

echo "Creating temporary GRASS location and batch job."
mkdir grassdata
mkdir grassdata/winkel
mkdir grassdata/winkel/PERMANENT
mkdir grassdata/winkel/data
echo "name: Fake Winkel Tripel
proj: eqc
lat_0: 0
lon_0: 0
lat_ts: 0
x_0: 0
y_0: 0
no_defs: defined
datum: wgs84
ellps: wgs84
towgs84: 0.000,0.000,0.000" >grassdata/winkel/PERMANENT/PROJ_INFO
echo "unit: meter
units: meters
meters: 1.0" >grassdata/winkel/PERMANENT/PROJ_UNITS
echo "proj:       99
zone:       0
north:      1
south:      0
east:       1
west:       0
cols:       1
rows:       1
e-w resol:  1
n-s resol:  1
top:        1.000000000000000
bottom:     0.000000000000000
cols3:      1
rows3:      1
depths:     1
e-w resol3: 1
n-s resol3: 1
t-b resol:  1" >grassdata/winkel/PERMANENT/DEFAULT_WIND
echo "fake winkel" >grassdata/winkel/PERMANENT/MYNAME
cp grassdata/winkel/PERMANENT/DEFAULT_WIND grassdata/winkel/PERMANENT/WIND
cp grassdata/winkel/PERMANENT/DEFAULT_WIND grassdata/winkel/data/WIND

