import ogr,sys,urllib2,csv

# Usage: python _6_2_clean_cities.py [capitals.shp] [cities.shp] [population threshold]

driver = ogr.GetDriverByName('ESRI Shapefile')
capitalSource = driver.Open(sys.argv[1], 1)
capital = capitalSource.GetLayer()

citySource = driver.Open(sys.argv[2], 1)
city = citySource.GetLayer()

population = int(sys.argv[3])

# if the population thresh (default = 500 000) is 0 then set the filter in QGIS layer that meets needs
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

capitalSource.Destroy()
citySource.Destroy()

