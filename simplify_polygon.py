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

import ogr,sys,urllib2,csv

# Usage: simplify_polygon.py threshold_distance min_area shapefile.shp
# if threshold_distance equals 0 then only removal of features smaller then min_area is performed
tol = float(sys.argv[1])
small = float(sys.argv[2])

driver = ogr.GetDriverByName('ESRI Shapefile')
fn = sys.argv[3]
dataSource = driver.Open(sys.argv[3], 1)

layer = dataSource.GetLayer()

if tol>0:
    for feature in layer:
        geom = feature.GetGeometryRef()
        try:
            if geom.Area() < small:
                layer.DeleteFeature(feature.GetFID())
            else:
                feature.SetGeometryDirectly(geom.SimplifyPreserveTopology(tol))
                layer.SetFeature(feature)
        except:
            layer.DeleteFeature(feature.GetFID()) 
else:
    for feature in layer:
        geom = feature.GetGeometryRef()
        try:
            if geom.Area() < small:
                layer.DeleteFeature(feature.GetFID())
        except:
            layer.DeleteFeature(feature.GetFID()) 

dataSource.SyncToDisk()
dataSource.Destroy()

	
