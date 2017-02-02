import ogr,sys,csv

# Usage: python _5_2_clean_rivers.py [rivers_names_list_file] [rivers_shapefile.shp]
# Writes changes to rivers_shapefile.shp directly

# Current list of words for feature deletion: basin, watershed, syst, canal, kanal, carreteras, network, reservoir, pipeline
# TODO: put words in array and simplify code

rivers = open(sys.argv[1])
reader = csv.reader(rivers)
data = list(reader)

driver = ogr.GetDriverByName('ESRI Shapefile')
dataSource = driver.Open(sys.argv[2], 1)
layer = dataSource.GetLayer()

for feature in layer:
    name = feature.GetField('name')
    name_en = feature.GetField('name_en')
    if name is None and name_en is None:
        layer.DeleteFeature(feature.GetFID())
    if name is not None:
        if name.lower().find('basin') != -1 or name.lower().find('watershed') != -1 or name.lower().find('syst') != -1 or name.lower().find('canal') != -1 or name.lower().find('kanal') != -1 or name.lower().find('carreteras') != -1 or name.lower().find('network') != -1 or name.lower().find('reservoir') != -1 or name.lower().find('pipeline') != -1 or name.lower().find('off') != -1:   
            layer.DeleteFeature(feature.GetFID())
    if name_en is not None:
        if name_en.lower().find('basin') != -1 or name_en.lower().find('watershed') != -1 or name_en.lower().find('syst') != -1 or name_en.lower().find('canal') != -1 or name_en.lower().find('kanal') != -1 or name_en.lower().find('carreteras') != -1 or name_en.lower().find('network') != -1 or name_en.lower().find('reservoir') != -1 or name_en.lower().find('pipeline') != -1 or name_en.lower().find('off') != -1:   
            layer.DeleteFeature(feature.GetFID())
    river_found = False
    for river in data:
        if name is not None:
            if name.lower().find(str(river[0]).lower()) != -1:        
                river_found = True
        if name_en is not None:
            if name_en.lower().find(str(river[0]).lower()) != -1:        
                river_found = True
    if not river_found:
        layer.DeleteFeature(feature.GetFID())
   
dataSource.Destroy()


