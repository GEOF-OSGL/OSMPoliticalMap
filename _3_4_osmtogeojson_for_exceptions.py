#Copyright (C) 2016, 2017 Drazen Tutic, Tomislav Jogun, Ana Kuvezdic Divjak
#This file is part of OSMPoliticalMap software.
#
#OSMPoliticalMap is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#OSMPoliticalMap is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with OSMPoliticalMap.  If not, see <http://www.gnu.org/licenses/>.

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


