import ogr,sys,urllib2,csv

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
     print "Created fields of real type: _label_x, _label_y, _label_r"
    
dataSource.SyncToDisk()
dataSource.Destroy()


