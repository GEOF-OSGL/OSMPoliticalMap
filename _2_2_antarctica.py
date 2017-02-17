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

import ogr,sys,math,random,os 
import numpy as np

# Usage: python _2_2_antarctica.py shapefile.shp

def Antarctica_Ring(g):
    p_len = g.GetPointCount()
    points = np.zeros((p_len,2))
    for i in range(0, p_len):
        p = g.GetPoint(i)
        points[i,0] = p[0]
        points[i,1] = p[1]

    #move southest points in WebMercator to South Pole
    a = 0
    for i in range(0, p_len):
        if points[i,1]<-85:
            points[i,1]=-90
            a = 1
        
    ring = ogr.Geometry(ogr.wkbLinearRing)    
    for i in range (0,p_len):
        ring.AddPoint(points[i,0], points[i,1])
    if a == 1: 
        ring.Segmentize(0.1)
    if ring is None:
        print "Fail to create valid geometry!"
    return ring

def Antarctica_Line(g):
    p_len = g.GetPointCount()
    points = np.zeros((p_len,2))
    for i in range(0, p_len):
        p = g.GetPoint(i)
        points[i,0] = p[0]
        points[i,1] = p[1]

    #move southest points in WebMercator to South Pole
    a = 0
    for i in range(0, p_len):
        if points[i,1]<-85:
            points[i,1]=-90
            a = 1
       
    ring = ogr.Geometry(ogr.wkbLineString)    
    for i in range (0,p_len):
        ring.AddPoint(points[i,0], points[i,1])
    if a == 1: 
        ring.Segmentize(0.1)

    if ring is None:
        print "Fail to create valid geometry!"
    return ring

#start of main program
driver = ogr.GetDriverByName('ESRI Shapefile')
inDataSet = driver.Open(sys.argv[1], 1)

inLayer = inDataSet.GetLayer()

for inFeature in inLayer:
  geom = inFeature.GetGeometryRef()
  if geom is not None:
    if geom.GetGeometryName() == 'MULTIPOLYGON':
        out_geom = ogr.Geometry(ogr.wkbMultiPolygon)
        for i in range(0, geom.GetGeometryCount()): #iterate over polygons
            poly = ogr.Geometry(ogr.wkbPolygon) 
            g = geom.GetGeometryRef(i) #polygon can have multiple rings
            for j in range(0, g.GetGeometryCount()): #iterate over rings
                ring = g.GetGeometryRef(j) #access to a ring (closed polyline)
                (minX, maxX, minY, maxY) = ring.GetEnvelope()
                if minY < -85: 
                    ring = Antarctica_Ring(ring) 
                poly.AddGeometry(ring)
            out_geom.AddGeometry(poly)                      
    elif geom.GetGeometryName() == 'POLYGON':
        out_geom = ogr.Geometry(ogr.wkbPolygon) 
        for i in range(0, geom.GetGeometryCount()): #iterate over rings
            g = geom.GetGeometryRef(i) #access to a ring (closed polyline)
            (minX, maxX, minY, maxY) = g.GetEnvelope()
            if minY < -85: 
                g = Antarctica_Ring(g)
            out_geom.AddGeometry(g)
    elif geom.GetGeometryName() == 'MULTILINESTRING':
        out_geom = ogr.Geometry(ogr.wkbMultiLineString)
        for i in range(0, geom.GetGeometryCount()): #iterate over lines
            g = geom.GetGeometryRef(i) 
            (minX, maxX, minY, maxY) = g.GetEnvelope()
            if minY < -85: 
                g = Antarctica_Line(g) 
            out_geom.AddGeometry(g)
    elif geom.GetGeometryName() == 'LINESTRING':
        out_geom = ogr.Geometry(ogr.wkbLineString) 
        (minX, maxX, minY, maxY) = geom.GetEnvelope()
        if minY < -85: 
            geom = Antarctica_Line(geom)
        out_geom = geom
    # set the geometry 
    inFeature.SetGeometry(out_geom)
    inLayer.SetFeature(inFeature)
    inFeature.Destroy()
 
inDataSet.Destroy()

