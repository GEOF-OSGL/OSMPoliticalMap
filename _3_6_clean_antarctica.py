import sys
from osgeo import ogr
import shapely

driver = ogr.GetDriverByName('ESRI Shapefile')
dataSource = driver.Open(sys.argv[1], 1)
layer = dataSource.GetLayer()
layerDefinition = layer.GetLayerDefn()

wkt = "POLYGON ((-12000000 -7670000, -7000000 -10200000, 7000000 -10200000, 12000000 -7670000, -12000000 -7670000))"
poligon = ogr.CreateGeometryFromWkt(wkt)
field_list = []

for i in range(layerDefinition.GetFieldCount()):
    fieldName = layerDefinition.GetFieldDefn(i).GetName()
    #print fieldName
    field_list.append(fieldName)

feature = layer.GetNextFeature()
while feature is not None:
    if 'ISO3166_1' in field_list:
        geom = feature.GetGeometryRef()
        if poligon.Intersects(geom) and feature.ISO3166_1 != 'AQ':
            layer.DeleteFeature(feature.GetFID())
        feature = layer.GetNextFeature()
    elif 'ISO3166_1' not in field_list:
        geom = feature.GetGeometryRef()
        if poligon.Intersects(geom):
            layer.DeleteFeature(feature.GetFID())
        feature = layer.GetNextFeature()


dataSource.SyncToDisk()
dataSource.Destroy()
