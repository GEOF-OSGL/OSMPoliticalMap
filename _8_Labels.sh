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

echo
echo "--------------------------------------------------------------------------------------------------------"
echo "Copying colors and labels positions from reference map ..."
echo "--------------------------------------------------------------------------------------------------------"

python ./_8_copyfields.py cat,_label_x,_label_y,_label_r,wrap ./PK/03_countries/countries_final.shp ./$OSM_DIR/03_countries/countries_final.shp
python ./_8_copyfields.py _label_x,_label_y,_label_r,wrap ./PK/04_lakes/lakes_final.shp ./$OSM_DIR/04_lakes/lakes_final.shp
python ./_8_copyfields.py _label_x,_label_y,_label_r,wrap ./PK/05_rivers/rivers_final.shp ./$OSM_DIR/05_rivers/rivers_final.shp
python ./_8_copyfields.py _label_x,_label_y,_label_r,wrap ./PK/06_cities/cities_final.shp ./$OSM_DIR/06_cities/cities_final.shp
python ./_8_copyfields.py _label_x,_label_y,_label_r,wrap ./PK/06_cities/capitals_final.shp ./$OSM_DIR/06_cities/capitals_final.shp
python ./_8_copyfields.py _label_x,_label_y,_label_r,wrap ./PK/07_oceans/oceans_final.shp ./$OSM_DIR/07_oceans/oceans_final.shp

echo "Colors and labels ... Done!"
echo "--------------------------------------------------------------------------------------------------------"

