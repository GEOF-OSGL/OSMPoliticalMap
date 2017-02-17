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

# Usage: simplify_line.py threshold_distance threshold_length shapefile.shp
tol = float(sys.argv[1])
short = float(sys.argv[2])

driver = ogr.GetDriverByName('ESRI Shapefile')
dataSource = driver.Open(sys.argv[3], 1)

layer = dataSource.GetLayer()

if tol>0:
    for feature in layer:
        geom = feature.GetGeometryRef()
        simpl = geom.SimplifyPreserveTopology(tol)
        if simpl.Length() < short:
            layer.DeleteFeature(feature.GetFID())
        else:
            feature.SetGeometryDirectly(simpl)
            layer.SetFeature(feature)
else:
    for feature in layer:
        geom = feature.GetGeometryRef()
        if geom.Length() < short:
            layer.DeleteFeature(feature.GetFID())
    
dataSource.SyncToDisk()
dataSource.Destroy()


