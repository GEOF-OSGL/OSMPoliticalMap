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

import ogr,sys,csv

copy_fields = sys.argv[1].split(',')

print copy_fields

driver = ogr.GetDriverByName('ESRI Shapefile')

inDataSet = driver.Open(sys.argv[2], 0)
inLayer = inDataSet.GetLayer()

outDataSet = driver.Open(sys.argv[3], 1)
outLayer = outDataSet.GetLayer()

for inFeature in inLayer:
    osm_id = inFeature.GetField('osm_id')
    outLayer.SetAttributeFilter("osm_id = '"+str(osm_id)+"'")
    for outFeature in outLayer:
        for field in copy_fields:
            if inFeature.GetField(field) != None:
                outFeature.SetField(field,inFeature.GetField(field))
        outLayer.SetFeature(outFeature)

inDataSet.SyncToDisk()
inDataSet.Destroy()
outDataSet.SyncToDisk()
outDataSet.Destroy()

