import ogr,sys

# Usage: caspian.py shapefile.shp
# shapefile.shp should contain builded land polygons from GRASS
# this will hopefully make a hole in Euroasia where Caspian Sea is
# in order to clip sea country borders to coastline also in Caspian Sea

driver = ogr.GetDriverByName('ESRI Shapefile')
fn = sys.argv[1]
dataSource = driver.Open(sys.argv[1], 1)

layer = dataSource.GetLayer()

#Spatial filter which should return only Caspian Sea and Euroasia polygon
wkt = "POLYGON ((50 36, 50 37, 52 37, 52 36, 50 36))"
layer.SetSpatialFilter(ogr.CreateGeometryFromWkt(wkt))

if layer.GetFeatureCount() == 2:
  f1 = layer.GetNextFeature()
  f2 = layer.GetNextFeature()
  g1 = f1.GetGeometryRef()
  g2 = f2.GetGeometryRef()
  r1 = g1.GetGeometryRef(0)
  r2 = g2.GetGeometryRef(0)
  if g1.Within(g2):
    poly = ogr.Geometry(ogr.wkbPolygon)
    poly.AddGeometry(r2)
    poly.AddGeometry(r1)
    f2.SetGeometry(poly)
    layer.SetFeature(f2)
    layer.DeleteFeature(f1.GetFID())
    print "Success. Caspian sea should now be hole in Euroasia!"
  elif g2.Within(g1):
    poly = ogr.Geometry(ogr.wkbPolygon)
    poly.AddGeometry(r1)
    poly.AddGeometry(r2)
    f1.SetGeometry(poly)
    layer.SetFeature(f1)
    layer.DeleteFeature(f2.GetFID())
    print "Success. Caspian sea should now be hole in Euroasia!"
  else:
    print "Polygons are not within each other! Data are not as expected!"
else:
  print "Two objects expected but more or less found! Data are not as expected!"

dataSource.Destroy()

