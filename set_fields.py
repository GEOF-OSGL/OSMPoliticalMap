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

# Usage: set_fields.py comma_separated_lis_of_fields_to_keep labels=yes|labels=no shapefile.shp
keep = sys.argv[1]
label = sys.argv[2]

extra_fields = False
if label == 'labels=yes':
    extra_fields = True

fields = keep.split(',')

driver = ogr.GetDriverByName('ESRI Shapefile')
dataSource = driver.Open(sys.argv[3], 1)

layer = dataSource.GetLayer()
layerDefn = layer.GetLayerDefn()

delete = True

while delete:
    delete = False
    layerDefn = layer.GetLayerDefn()
    for i in range(layerDefn.GetFieldCount()):
        fieldName =  layerDefn.GetFieldDefn(i).GetName()
        if not fieldName in fields:
           layer.DeleteField(i)
           print "Deleted field: ",fieldName
           delete = True
           break

if extra_fields:
     label_xField = ogr.FieldDefn("_label_x", ogr.OFTReal)
     layer.CreateField(label_xField)
     label_yField = ogr.FieldDefn("_label_y", ogr.OFTReal)
     layer.CreateField(label_yField)
     label_rField = ogr.FieldDefn("_label_r", ogr.OFTReal)
     layer.CreateField(label_rField)
     label_wField = ogr.FieldDefn("wrap", ogr.OFTInteger)
     layer.CreateField(label_wField)
     print sys.argv[3],": created fields for label placement: _label_x, _label_y, _label_r, wrap"
    
dataSource.SyncToDisk()
dataSource.Destroy()


