import ogr,sys,urllib2,csv


#create filter for missing ISO codes found in COUNTRY_ERRORS.log
file = open(sys.argv[1], 'rb')
reader = csv.reader(file)
data = list(reader)
print "#!/bin/bash"

print "osmfilter planet.osm.o5m --keep-nodes= --keep-ways= --keep-relations=\"",
for c in data:
  if ((c[0] != data[-1][0])):
    print "ISO3166-1:alpha2="+c[0]+" OR ISO3166-1="+c[0]+" OR ",
  else:
    print "ISO3166-1:alpha2="+c[0]+" OR ISO3166-1="+c[0]+"\"",
    print " -o=osm_countries_add.osm"


