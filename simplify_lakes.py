import ogr,sys,urllib2,csv

# Usage: simplify_polygon.py threshold_distance threshold_area shapefile.shp
tol = float(sys.argv[1])
small = float(sys.argv[2])

driver = ogr.GetDriverByName('ESRI Shapefile')
fn = sys.argv[3]
dataSource = driver.Open(sys.argv[3], 1)

layer = dataSource.GetLayer()

for feature in layer:
    geom = feature.GetGeometryRef()
    try:
        if simpl.Area() < small:
            layer.DeleteFeature(feature.GetFID())
        else:
            simpl = geom.Simplify(tol)
            feature.SetGeometryDirectly(simpl)
            layer.SetFeature(feature)
    except:
        layer.DeleteFeature(feature.GetFID())     


dataSource.SyncToDisk()
dataSource.Destroy()

	

