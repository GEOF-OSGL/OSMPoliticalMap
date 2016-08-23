import urllib2, csv, ogr,sys,os

iso_list = urllib2.urlopen('https://raw.githubusercontent.com/datasets/country-list/master/data.csv')
reader = csv.reader(iso_list)
data = list(reader)

#add Kosovo eventhough it is not in ISO3166
data.append(list(['Kosovo','XK']))

del data[0]

iso = [row[1] for row in data]

driver = ogr.GetDriverByName('ESRI Shapefile')
inDataSet = driver.Open(sys.argv[1], 1)

inLayer = inDataSet.GetLayer()

if os.path.exists(sys.argv[2]):
    driver.DeleteDataSource(sys.argv[2])
outDataSet = driver.CreateDataSource(sys.argv[2])
outLayer = outDataSet.CreateLayer(inLayer.GetName(), geom_type=inLayer.GetGeomType(),options=['ENCODING=UTF8'])

# add fields
inLayerDefn = inLayer.GetLayerDefn()
for i in range(0, inLayerDefn.GetFieldCount()):
    fieldDefn = inLayerDefn.GetFieldDefn(i)
    outLayer.CreateField(fieldDefn)

# get the output layer's feature definition
outLayerDefn = outLayer.GetLayerDefn()


mpoly = []
mfeat = []
iso_find = []
for c in data:
    mpoly.append(ogr.Geometry(ogr.wkbMultiPolygon))
    mfeat.append(ogr.Feature(outLayerDefn))
    iso_find.append(False)

for feature in inLayer:
    attr = feature.GetField('ISO3166_1')
    if attr != 'None':
        x = iso.index(attr)
        geom = feature.GetGeometryRef()
        if geom.Area() > 0:
            mpoly[x].AddGeometry(geom)
        if not iso_find[x]:
            for j in range(0, outLayerDefn.GetFieldCount()):
                mfeat[x].SetField(outLayerDefn.GetFieldDefn(j).GetNameRef(), feature.GetField(j))
        iso_find[x] = True
    feature.Destroy()

i = 0
for out_feat in mfeat:
    if iso_find[i]:
        out_feat.SetGeometry(mpoly[i])
        # add the feature to the shapefile
        outLayer.CreateFeature(out_feat)
        out_feat.Destroy()
    i = i+1

inDataSet.Destroy()
outDataSet.Destroy()


