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

# Usage: python _6_2_clean_cities.py [capitals.shp] [cities.shp] [population threshold]

driver = ogr.GetDriverByName('ESRI Shapefile')
capitalSource = driver.Open(sys.argv[1], 1)
capital = capitalSource.GetLayer()

citySource = driver.Open(sys.argv[2], 1)
city = citySource.GetLayer()

citySource2 = driver.Open(sys.argv[2], 1)
city2 = citySource2.GetLayer()

population = int(sys.argv[3])

# if the population thresh (default = 500000) is 0 then set the filter in QGIS layer that meets needs
for c in city:
    c_pop = c.GetField('population')
    try:
        pop = int(c_pop)
        if pop < population:
            city.DeleteFeature(c.GetFID())
    except ValueError:
        if c_pop != 'None':
            print 'Invalid value for population ',c.GetField('name'), c.GetField('name_en'), c_pop
        city.DeleteFeature(c.GetFID())

    
# delete cities that are already capitals to avoid duplicates
for cap in capital:
    cap_id = cap.GetField('osm_id')
    city.ResetReading() 
    for c in city:
        c_id = c.GetField('osm_id')
        if cap_id == c_id:
            city.DeleteFeature(c.GetFID())

# find very close cities (40 km) and keep one with larger population
#TODO: 40 km should be expressed with map scale and code needs optimization
 
city.ResetReading()
for c in city:
    point_c = c.GetGeometryRef()
    city2.ResetReading()   
    for c2 in city2:
        point_c2= c2.GetGeometryRef()
        if (point_c2.Distance(point_c) < 40000) and (c2.GetField('osm_id') != c.GetField('osm_id')):
            pop_c = int(c.GetField('population'))
            pop_c2 = int(c2.GetField('population'))
            if pop_c > pop_c2:
               city.DeleteFeature(c2.GetFID())
               city2.DeleteFeature(c2.GetFID())
            else:
               city.DeleteFeature(c.GetFID())
               city2.DeleteFeature(c.GetFID())



capitalSource.Destroy()
citySource.Destroy()
citySource2.Destroy()


