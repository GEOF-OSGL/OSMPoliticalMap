import ogr,sys,urllib2,csv

# Usage: missiong_iso_polygons.py shapefile.shp
# shapefile.shp should contain builded administrative polygons

#create list of ISO codes in second field of data record
iso_list = urllib2.urlopen('https://raw.githubusercontent.com/datasets/country-list/master/data.csv')
reader = csv.reader(iso_list)
data = list(reader)

#add Kosovo eventhough it is not in ISO3166
data.append(list(['Kosovo','XK']))

del data[0]

driver = ogr.GetDriverByName('ESRI Shapefile')
dataSource = driver.Open(sys.argv[1], 1)

layer = dataSource.GetLayer()

iso = []

for feature in layer:
    if feature.GetField('ISO3166-1_') is not None:
        iso.append(feature.GetField('ISO3166-1_'))
    elif feature.GetField('ISO3166-1') is not None:
        iso.append(feature.GetField('ISO3166-1'))
    else:
        layer.DeleteFeature(feature.GetFID())

dataSource.Destroy()

missing =  []

for c in data:
    if not (c[1] in iso):
        missing.append(c[1])
      
print "ogr2ogr -f \"ESRI Shapefile\" -where \"('boundary'='administrative' OR 'boundary'='territorial' OR 'boundary'='region') AND (",
for c in missing:
  if ((c != missing[-1])):
    print "'ISO3166-1:alpha2'='"+c+"' OR 'ISO3166-1'='"+c+"' OR ",
  else:
    print "'ISO3166-1:alpha2'='"+c+"' OR 'ISO3166-1'='"+c+"')\" ",
    print "-overwrite -skipfailures -nlt MULTIPOLYGON -lco ENCODING=UTF-8 03_countries_ex osm_countries.osm"


