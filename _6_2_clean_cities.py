import ogr,sys,urllib2,csv

# Usage: capitals.shp cities.shp population

driver = ogr.GetDriverByName('ESRI Shapefile')
capitalSource = driver.Open(sys.argv[1], 1)
capital = capitalSource.GetLayer()

citySource = driver.Open(sys.argv[2], 1)
city = citySource.GetLayer()

population = int(sys.argv[3])


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

for cap in capital:
    cap_id = cap.GetField('osm_id')
    city.ResetReading() 
    for c in city:
        c_id = c.GetField('osm_id')
        if cap_id == c_id:
            city.DeleteFeature(c.GetFID())

capitalSource.Destroy()
citySource.Destroy()


