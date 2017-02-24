POLITICAL WORLD MAP FROM OSM DATA Shapefile QGIS stylesheets
==============================

This repo contains QGIS stylesheets (QML) for use with OpenStreetMap (OSM) Political Map data in ESRI Shapefile format. 

==============================

##Background

The political map of the world created from the OpenStreetMap (OSM) data using automated procedure which results with map in an intermediate stage. Necessary manual interventions for this map included final placement of the labels, attribute editing, and print layout design. Software, documentation and map data are published on GitHub under the name "OSMPoliticalMap".

##Info

The map is compiled at scale 1 : 30 000 000 in Winkel Tripel Projection, standard parallel 50°28', datum WGS84. 
It is designed for printing on A0 format. 
It shows independent states, dependencies or areas of special sovereignty as is in the OSM dataset, without adaptation to certain diplomatic recognition. 

We recommend this layer order:
- capitals_final
- oceans_final
- cities_final
- graticule
- admin_final
- coastlines_final
- lakes_final
- rivers_final
- countries_final
- frame_final


##Credit & Licence

Copyright (C) 2016, 2017 Drazen Tutic, Tomislav Jogun, Ana Kuvezdic Divjak

This file is part of OSMPoliticalMap software.

OSMPoliticalMap is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
OSMPoliticalMap is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with OSMPoliticalMap.  If not, see <http://www.gnu.org/licenses/>.

The styles are licensed under [CC-BY-SA](http://creativecommons.org/licenses/by-sa/3.0/) so you are free to use these stylesheets under the same terms.