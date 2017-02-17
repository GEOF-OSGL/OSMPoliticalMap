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

file = open(sys.argv[1], 'rb')
reader = csv.reader(file)
data = list(reader)

iso = []
for c in data:
   iso.append(c[0])

driver = ogr.GetDriverByName('ESRI Shapefile')
dataSource = driver.Open(sys.argv[2], 1)

layer = dataSource.GetLayer()

for feature in layer:
    if (feature.GetField('ISO3166-1_') in iso) or (feature.GetField('ISO3166-1') in iso):
        layer.DeleteFeature(feature.GetFID())
    if feature.GetField('ISO3166-1_') is not None:
        if feature.GetField('ISO3166-1') is None:
            feature.SetField('ISO3166-1',feature.GetField('ISO3166-1_'))
            layer.SetFeature(feature)
    elif feature.GetField('ISO3166-1') is not None:
        if feature.GetField('ISO3166-1_') is None:
            feature.SetField('ISO3166-1_',feature.GetField('ISO3166-1'))
            layer.SetFeature(feature)
    else:
        pass

dataSource.Destroy()


driver = ogr.GetDriverByName('ESRI Shapefile')
dataSource = driver.Open(sys.argv[3], 1)

layer = dataSource.GetLayer()


for feature in layer:
    if feature.GetField('ISO3166-1_') is not None:
        if feature.GetField('ISO3166-1') is None:
            feature.SetField('ISO3166-1',feature.GetField('ISO3166-1_'))
            layer.SetFeature(feature)
    elif feature.GetField('ISO3166-1') is not None:
        if feature.GetField('ISO3166-1_') is None:
            feature.SetField('ISO3166-1_',feature.GetField('ISO3166-1'))
            layer.SetFeature(feature)
    else:
        pass
    if feature.GetField('ISO3166-1_') is None and feature.GetField('ISO3166-1') is None:
        layer.DeleteFeature(feature.GetFID())

dataSource.Destroy()

