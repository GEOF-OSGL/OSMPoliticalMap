#!/bin/bash

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

export OSM_DIR=./NEW_MAP
#rm $OSM_DIR -rf
mkdir $OSM_DIR
echo
echo "WORLD POLITICAL MAP FROM OPENSTREETMAP DATA"
echo "More info: http://github.com/GEOF-OSGL/OSMPoliticalMap"
echo
echo "Map will be created in folder NEW_MAP." 
echo "When job finishes, open OSM_World_Political_Map.qgs in QGIS and edit it to your needs."
echo
read -p "Set map scale denominator [30000000]: " scale
if [ "$scale" = "" ] 
then
    export OSM_SCALE=30000000
else
    export OSM_SCALE=$scale
fi
read -p "Set map language with two letter code, e.g. hr for Croatian [en]: " lang
if [ "$lang" = "" ] 
then
    export OSM_LANG=en
else
    export OSM_LANG=$lang
fi
read -p "Set map projection using PROJ4 syntax [+proj=wintri +ellps=WGS84 +lat_1=50.4597762522]: " proj
if [ "$proj" = "" ]
then
    export OSM_PROJ="+proj=wintri +ellps=WGS84 +lat_1=50.4597762522"
else
    export OSM_PROJ="$proj"
fi
read -p "Set graticule density [20]: " graticule
if [ "$graticule" = "" ]
then
    export OSM_GRATICULE=20
else
    export OSM_GRATICULE="$graticule"
fi
echo
echo "You can run the whole process (it can take many hours!) or only a part of it."
echo "0 = only download and convert OSM planet file"
echo "1 = graticule"
echo "2 = coastlines"
echo "3 = countries (will first run 2)"
echo "4 = lakes"
echo "5 = rivers"
echo "6 = cities (will first run 3)"
echo "7 = oceans"
echo "10 = all"

read -p "Enter number for process [10]: " process

echo
echo "Done with setting map parameters."
echo "Map scale: 1 :" $OSM_SCALE
echo "Map language:" $OSM_LANG
echo "Map projection:" $OSM_PROJ
echo "Graticule density:" $OSM_GRATICULE
echo "Process to run:" $process
echo
read -p "Please check it again and confirm by typing 'start': " confirm
if [ "$confirm" = "start" ]
then
    echo "Done with setting the map. Real job starts and it can take many hours ..."
    echo
    echo "Creating osmconf.ini file for use with ogr2ogr ..."
    ./osmconf.sh >osmconf.ini
    if [ "$process" == "10" ]
    then 
        echo "Starting download of the OSM planet file ..."
        wget http://ftp5.gwdg.de/pub/misc/openstreetmap/planet.openstreetmap.org/pbf/planet-latest.osm.pbf --output-document=planet.osm.pbf
        echo
        echo "Starting conversion of pbf to o5m ..."
        osmconvert --drop-author planet.osm.pbf -o=planet.osm.o5m
        rm -f planet.osm.pbf
        echo
        echo "Conversion of pbf to o5m done."
        echo "-------------------------------------------------"
        ./_1_Graticule.sh
        ./_2_Coastlines.sh
        ./_3_Countries.sh
        ./_4_Lakes.sh
        ./_5_Rivers.sh
        ./_6_Cities.sh
        ./_7_Oceans.sh
        ./_8_Labels.sh    
        echo "Whole map creation process finished!"
        echo
        echo "Now open OSM_World_Political_Map.qgs in QGIS. Edit the map to suit your idea and needs."
        echo "Please send feedback or report a problem at http://github.com/GEOF-OSGL/OSMPoliticalMap"
        echo
    fi    
    if [ "$process" == "0" ]
    then 
        echo "Starting download of the OSM planet file ..."
        wget http://ftp5.gwdg.de/pub/misc/openstreetmap/planet.openstreetmap.org/pbf/planet-latest.osm.pbf --output-document=planet.osm.pbf
        echo
        echo "Starting conversion of pbf to o5m ..."
        osmconvert --drop-author planet.osm.pbf -o=planet.osm.o5m
        rm -f planet.osm.pbf
        echo
        echo "Conversion of pbf to o5m done."
        echo "-------------------------------------------------"        
    fi    
    if [ "$process" == "1" ]
    then 
        ./_1_Graticule.sh
    fi    
    if [ "$process" == "2" ]
    then 
        ./_2_Coastlines.sh
    fi    
    if [ "$process" == "3" ]
    then 
        ./_2_Coastlines.sh
        ./_3_Countries.sh
        ./_8_Labels.sh    
    fi    
    if [ "$process" == "4" ]
    then 
        ./_4_Lakes.sh
        ./_8_Labels.sh    
    fi    
    if [ "$process" == "5" ]
    then 
        ./_5_Rivers.sh
        ./_8_Labels.sh    
    fi    
    if [ "$process" == "6" ]
    then 
        ./_3_Countries.sh
        ./_6_Cities.sh
        ./_8_Labels.sh    
    fi    
    if [ "$process" == "7" ]
    then 
        ./_8_Labels.sh    
    fi    

    echo
    echo "Shapefiles are licensed under ODbL (http://opendatacommons.org/licenses/odbl/)"
    echo "Map is licenced under CC-BY-SA (http://creativecommons.org/licenses/by-sa/4.0/legalcode)"
    echo "Programs and scripts are licenced under GNU GPL (http://www.gnu.org/licenses/gpl-3.0.en.html)"
    echo
    echo "Copyright (C) 2016, 2017 Drazen Tutic, Tomislav Jogun, Ana Kuvezdic Divjak"
    echo "University of Zagreb, Faculty of Geodesy, Croatia"
    echo
else
    echo "Job canceled!"
    echo
fi

