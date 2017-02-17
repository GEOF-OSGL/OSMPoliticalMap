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

import ogr,sys,os

driver = ogr.GetDriverByName('ESRI Shapefile')

inDataSet1 = driver.Open(sys.argv[1], 0) #final coastlines polygons
inLayer1 = inDataSet1.GetLayer()


inDataSet2 = driver.Open(sys.argv[2], 0) #final countries polygons
inLayer2 = inDataSet2.GetLayer()

if os.path.exists(sys.argv[3]):
    driver.DeleteDataSource(sys.argv[3])
outDataSet = driver.CreateDataSource(sys.argv[3])
outLayer = outDataSet.CreateLayer(inLayer1.GetName(), geom_type=inLayer1.GetGeomType(),options=['ENCODING=UTF8'])

# add fields
inLayerDefn = inLayer1.GetLayerDefn()
for i in range(0, inLayerDefn.GetFieldCount()):
    fieldDefn = inLayerDefn.GetFieldDefn(i)
    outLayer.CreateField(fieldDefn)

# get the output layer's feature definition
outLayerDefn = outLayer.GetLayerDefn()
for inFeature2 in inLayer2: #for all countries
    geom2 = inFeature2.GetGeometryRef()
    if geom2.GetGeometryName() == 'MULTIPOLYGON': 
        for i in range(0, geom2.GetGeometryCount()): #iterate over parts of countries
            g2 = geom2.GetGeometryRef(i) #polygon 
            presjek = False
            inLayer1.ResetReading()
            for inFeature1 in inLayer1: #iterate over coastlines
                geom1 = inFeature1.GetGeometryRef()
                #if g2.IsSimple() and geom1.IsSimple() and g2.IsValid() and geom1.IsValid():
                if g2.Intersects(geom1): 
                     presjek = True
                inFeature1.Destroy()        
            if presjek == False:
                outFeature = ogr.Feature(outLayerDefn)
                outFeature.SetGeometry(g2)
                for i in range(0, outLayerDefn.GetFieldCount()):
                    outFeature.SetField(outLayerDefn.GetFieldDefn(i).GetNameRef(), inFeature1.GetField(i))
                outLayer.CreateFeature(outFeature)
                outFeature.Destroy()
    elif geom2.GetGeometryName() == 'POLYGON':
        presjek = False
        inLayer1.ResetReading()
        for inFeature1 in inLayer1: #iterate over coastlines
            geom1 = inFeature1.GetGeometryRef()
            #if geom2.IsSimple() and geom1.IsSimple() and geom2.IsValid() and geom1.IsValid():
            if geom2.Intersects(geom1):
                presjek = True
            inFeature1.Destroy()        
        if presjek == False: 
            outFeature = ogr.Feature(outLayerDefn)
            outFeature.SetGeometry(geom2)
            for i in range(0, outLayerDefn.GetFieldCount()):
                 outFeature.SetField(outLayerDefn.GetFieldDefn(i).GetNameRef(), inFeature1.GetField(i))
            outLayer.CreateFeature(outFeature)
            outFeature.Destroy()
    inFeature2.Destroy()

spatialRef = inLayer1.GetSpatialRef()
if spatialRef is not None:
    spatialRef.MorphToESRI()
    file = open(os.path.splitext(sys.argv[3])[0]+'.prj', 'w')
    file.write(spatialRef.ExportToWkt())
    file.close()

inDataSet1.Destroy()
inDataSet2.Destroy()
outDataSet.Destroy()
