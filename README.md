# OSMPoliticalMap
Automaticaly generate World Political Map in QGIS from OpenStreetMap planet file (see example map https://github.com/GEOF-OSGL/OSMPoliticalMap/blob/master/World_political_map_A0_Croatian.pdf) .

Set of bash and Python scripts for automatic generation of wall world political map in scale 1:30 000 000, A0 size. Map created is QGIS project, and all data are stored in ESRI shapefiles.

![alt tag](osm_political_map.png)

This project intents to investigate how OpenStreetMap (OSM) planet file can be used for generating small scale "classical" maps, with example of World Political Map.

Main challanges are automated cartographic generalisation, as well as getting appropriate data from OSM for desired map. Processes will be improved in order to achieve better final result and performance. Also, inconsistencies in or missing OSM data are detected when data is processed which then can lead to edits in OSM.

Resulting map is a very good starting point for creating final map, since program automate many tasks in map creation and reduce time to get desired final world political map.

User can set map projection, map scale and map language. 

# Warning
Running these scripts require downloading OSM planet file (~50GB) and filtering data from it (extra ~100GB needed). Whole process of map generation can take many hours (~6 hrs in tested environment) on standard PC.

# Tested environment:
Debian GNU/Linux 8 (jessie) 64-bit, 
Intel® Core™ i7-5500U CPU @ 2.40GHz × 4, 
256 GB SSD, 
16 GB RAM

# Required packages:
QGIS 2.4 or higher, 
GRASS 6.4.3 or higher, 
ogr2og2, 
GDAL/OGR library 2.1 or higher, 
Python, 
osmfilter, 
osmconvert,
nodejs,
osmtogeojson,
pyproj

# Usage:
1. Download zip of the project and extract it on partition with >150GB free space.
2. Run main script: ./_0_PoliticalMap.sh
3. Data for new map will be created in project subfolder NEW_MAP
4. When scripts finish, open QGIS project file "OSM_World_Political_Map.qgs" and do all manual edits you want (e.g. change label placement, change colours etc.). 

Send any problem or comment to dtutic@geof.hr. It will be much appreceated.


