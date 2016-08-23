import ogr,sys,urllib2,csv

# Usage: simplify_line.py threshold_distance threshold_length shapefile.shp
tol = float(sys.argv[1])
short = float(sys.argv[2])

driver = ogr.GetDriverByName('ESRI Shapefile')
dataSource = driver.Open(sys.argv[3], 1)

layer = dataSource.GetLayer()

for feature in layer:
    geom = feature.GetGeometryRef()
    simpl = geom.SimplifyPreserveTopology(tol)
    if simpl.Length() < short:
        layer.DeleteFeature(feature.GetFID())
    else:
        feature.SetGeometryDirectly(simpl)
        layer.SetFeature(feature)
    
dataSource.SyncToDisk()
dataSource.Destroy()


