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

import urllib2, csv

iso_list = urllib2.urlopen('https://raw.githubusercontent.com/datasets/country-list/master/data.csv')
reader = csv.reader(iso_list)
data = list(reader)

#add Kosovo even though it is not in ISO3166
data.append(list(['Kosovo','XK']))

del data[0]

print "osmfilter planet.osm.o5m --keep-nodes= --keep-ways= --keep-relations=\"\\"
for c in data:
  if ((c[1] != data[-1][1])):
    print "ISO3166-1:alpha2="+c[1]+" or ISO3166-1="+c[1]+" or \\"
  else:
    print "ISO3166-1:alpha2="+c[1]+" or ISO3166-1="+c[1]+"\\"
    print "\" -o=osm_countries.osm"


