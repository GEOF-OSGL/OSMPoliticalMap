import urllib2, csv

iso_list = urllib2.urlopen('https://raw.githubusercontent.com/datasets/country-list/master/data.csv')
reader = csv.reader(iso_list)
data = list(reader)

#add Kosovo eventhough it is not in ISO3166
data.append(list(['Kosovo','XK']))

del data[0]

print "osmfilter planet.osm.o5m --keep-nodes= --keep-ways= --keep-relations=\"\\"
for c in data:
  if ((c[1] != data[-1][1])):
    print "ISO3166-1:alpha2="+c[1]+" or ISO3166-1="+c[1]+" or \\"
  else:
    print "ISO3166-1:alpha2="+c[1]+" or ISO3166-1="+c[1]+"\\"
    print "\" -o=osm_countries.osm"

