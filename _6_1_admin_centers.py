import ogr,sys,urllib2,csv

print "#!/bin/bash"

iso_list = urllib2.urlopen('https://raw.githubusercontent.com/datasets/country-list/master/data.csv')
reader = csv.reader(iso_list)
data = list(reader)

#add Kosovo eventhough it is not in ISO3166
data.append(list(['Kosovo','XK']))

del data[0]

iso_list =  []
for i in data:
   iso_list.append(i[1])
counter = 0

print "osmfilter "+sys.argv[1]+" --keep-relations= --keep-ways= --keep-nodes=\"",

ref_list = []

iso = ''
relation = False
capital = False
ref_found = False
candidate = False
with open(sys.argv[1]) as data:
  for c in data:
    d = c.lstrip(' \t')
    if d.startswith("<relation"):
         relation = True
    if d.endswith("relation>\n"):
         relation = False
         candidate = False 
         ref_found = False
    if d.startswith("<tag k=\"ISO3166-1\"") and relation:
         a=c.split()
         for i in a:
            if i.startswith("v="):
                b = i.split("\"")
                iso = b[1]
                if iso in iso_list:
                    candidate = True  
    if d.startswith("<tag k=\"ISO3166-1:alpha2\"") and relation:
         a=c.split()
         for  i in a:
            if i.startswith("v="):
                b = i.split("\"")
                iso = b[1]
                #print "alpha2: ",iso
                if iso in iso_list:
                    candidate = True  

    if d.endswith("role=\"admin_centre\"/>\n") and relation:
      a = c.split()
      for  i in a:
         if i.startswith("ref="):
             b = i.split("\"")
             ref = b[1]
             #print ref
             ref_found = True

    if ref_found and candidate and relation: 
         if ref not in ref_list:
           if counter != 0:
               print " OR ",
           ref_list.append(ref)
           print "@id="+ref,
           counter = counter + 1

print "\" -o=osm_capitals.osm"



