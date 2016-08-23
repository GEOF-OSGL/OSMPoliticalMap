# OSMPoliticalMap
Automaticaly generate World Political Map in QGIS for printing from OpenStreetMap planet file (see the result in https://github.com/GEOF-OSGL/OSMPoliticalMap/blob/master/World_political_map_A0_Croatian.pdf) .

Set of bash and python scripts for automatic generation of wall world political map in scale 1:30 000 000, A0 size, in Winkel tripel map projection. Map created is as QGIS project, and all data are stored in shapefiles.

This project intents to investigate how OpenStreetMap (OSM) planet file can be used for generating small scale "classical" maps, with example of World Political Map.

Main challanges are automated cartographic generalisation, as well as getting appropriate data from OSM for desired map.

This is first attempt to do such task, it will be developed in number of aspects: choosing custom map projection, choosing map scale, choosing language, improving filtering and cartographic generalisation. Also, inconsistencies in or missing OSM data are detected when data is processed which then can lead to edits in OSM.

# Warning
Running these scripts require downloading OSM planet file (~50GB) and filtering data from it (extra ~100GB needed). Whole process of map generation can take many hours on standard PC.

# Tested environment:
Debian GNU/Linux 8 (jessie) 64-bit, 
Intel® Core™ i7-5500U CPU @ 2.40GHz × 4, 
256 GB SSD, 
16 GB RAM

# Required packages:
QGIS v.2.4 or higher, 
GRASS 6.4.3 or higher, 
ogr2og2, 
GDAL/OGR library, 
Python, 
osmfilter, 
osmconvert

# Running time: 
~6hrs, can take much longer with slow internet or processor, at lest 150GB of free disk is needed.

# Usage:
1. Download all scripts and data (*.sh, *.py, *.csv, *.qgs).
2. Delete folder PK if exists, all data will be created inside it.
3. Run main script: ./_0_PoliticalMap.sh
3. At one point you will be asked to enter ISO alpha2 codes of countries that were not correctly extraced.
4. When scripts finish, open QGIS project file "OSM World Political Map_for_print.qgs" and do all manual edits you want (e.g. label placement, change colours etc.). Print the map.

Send any problem or comment to dtutic@geof.hr. It will be much appreceated.


