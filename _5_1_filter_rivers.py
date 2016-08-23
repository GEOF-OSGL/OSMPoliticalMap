import ogr,sys,csv

iso_list = open(sys.argv[1])
reader = csv.reader(iso_list)
data = list(reader)
print "osmfilter planet.osm.o5m --keep-nodes= --keep-ways= --keep-relations=\"waterway=river and (\\"
for c in data:
  if (c != data[-1]):
    print "name=*"+str(c[0])+"* or name:en=*"+str(c[0])+"* or \\"
  else:
    print "name=*"+str(c[0])+"* or name:en=*"+str(c[0])+"*)\\"
    print "\" -o=osm_rivers.osm"
		

