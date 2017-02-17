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

echo "Creating temporary GRASS location and batch job."
mkdir grassdata
mkdir grassdata/xy
mkdir grassdata/xy/PERMANENT
mkdir grassdata/xy/data
echo "name: Map projection location
proj: eqc
lat_0: 0
lon_0: 0
lat_ts: 0
x_0: 0
y_0: 0
no_defs: defined
datum: wgs84
ellps: wgs84
towgs84: 0.000,0.000,0.000" >grassdata/xy/PERMANENT/PROJ_INFO
echo "unit: meter
units: meters
meters: 1.0" >grassdata/xy/PERMANENT/PROJ_UNITS
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
t-b resol:  1" >grassdata/xy/PERMANENT/DEFAULT_WIND
echo "xy_location" >grassdata/xy/PERMANENT/MYNAME
cp grassdata/xy/PERMANENT/DEFAULT_WIND grassdata/xy/PERMANENT/WIND
cp grassdata/xy/PERMANENT/DEFAULT_WIND grassdata/xy/data/WIND

