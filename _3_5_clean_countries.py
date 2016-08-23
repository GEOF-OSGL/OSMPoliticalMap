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

