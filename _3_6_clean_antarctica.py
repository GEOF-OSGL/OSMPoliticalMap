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

import ogr,sys

driver = ogr.GetDriverByName('ESRI Shapefile')
dataSource = driver.Open(sys.argv[1], 1)
layer = dataSource.GetLayer()
layerDefinition = layer.GetLayerDefn()

#TODO: calculate polygon bbox in given projection from geographical coordinates since this is valid only for Winkel tripel projection
wkt = "POLYGON ((-12000000 -7670000, -7000000 -10200000, 7000000 -10200000, 12000000 -7670000, -12000000 -7670000))"
polygon = ogr.CreateGeometryFromWkt(wkt)
field_list = []

for i in range(layerDefinition.GetFieldCount()):
    fieldName = layerDefinition.GetFieldDefn(i).GetName()
    field_list.append(fieldName)

feature = layer.GetNextFeature()
while feature is not None:
    if 'ISO3166_1' in field_list:
        geom = feature.GetGeometryRef()
        if polygon.Intersects(geom) and feature.ISO3166_1 != 'AQ':
            layer.DeleteFeature(feature.GetFID())
        feature = layer.GetNextFeature()
    elif 'ISO3166_1' not in field_list:
        geom = feature.GetGeometryRef()
        if polygon.Intersects(geom):
            layer.DeleteFeature(feature.GetFID())
        feature = layer.GetNextFeature()

dataSource.SyncToDisk()
dataSource.Destroy()
