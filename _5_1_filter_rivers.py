import ogr,sys,csv

# Usage: python _5_1_filter_rivers.py [rivers_names_list_file] >[name_of_script.sh]
# Creates shell script for filtering the rivers from OSM planet file by name in given names list

rivers_list = open(sys.argv[1])
reader = csv.reader(rivers_list)
data = list(reader)
print "osmfilter planet.osm.o5m --keep-nodes= --keep-ways= --keep-relations=\"waterway=river and (\\"
for c in data:
  if (c != data[-1]):
    print "name=*"+str(c[0])+"* or name:en=*"+str(c[0])+"* or \\"
  else:
    print "name=*"+str(c[0])+"* or name:en=*"+str(c[0])+"*)\\"
    print "\" -o=osm_rivers.osm"
