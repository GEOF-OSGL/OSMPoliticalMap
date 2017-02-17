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

echo "closed_ways_are_polygons=aeroway,amenity,boundary,building,craft,geological,historic,landuse,leisure,military,natural,office,place,shop,sport,tourism
attribute_name_laundering=yes

[points]
osm_id=yes
osm_version=no
osm_timestamp=no
osm_uid=no
osm_user=no
osm_changeset=no
attributes=name,name:$OSM_LANG,population,type,place,ISO3166-1:alpha2,ISO3166-1,admin_level,boundary,capital,intermittent
unsignificant=created_by,converted_by,source,time,ele
ignore=created_by,converted_by,source,time,ele,note,openGeoDB:,fixme,FIXME
other_tags=no

[lines]
osm_id=yes
osm_version=no
osm_timestamp=no
osm_uid=no
osm_user=no
osm_changeset=no
attributes=name,name:$OSM_LANG,population,type,place,ISO3166-1:alpha2,ISO3166-1,admin_level,boundary,capital,intermittent
ignore=created_by,converted_by,source,time,ele,note,openGeoDB:,fixme,FIXME
other_tags=no

[multipolygons]
osm_id=yes
osm_version=no
osm_timestamp=no
osm_uid=no
osm_user=no
osm_changeset=no
attributes=name,name:$OSM_LANG,population,type,place,ISO3166-1:alpha2,ISO3166-1,admin_level,boundary,capital,intermittent
ignore=area,created_by,converted_by,source,time,ele,note,openGeoDB:,fixme,FIXME
other_tags=no

[multilinestrings]
osm_id=yes
osm_version=no
osm_timestamp=no
osm_uid=no
osm_user=no
osm_changeset=no
attributes=name,name:$OSM_LANG,population,type,place,ISO3166-1:alpha2,ISO3166-1,admin_level,boundary,capital,intermittent
ignore=area,created_by,converted_by,source,time,ele,note,openGeoDB:,fixme,FIXME
other_tags=no

[other_relations]
osm_id=yes
osm_version=no
osm_timestamp=no
osm_uid=no
osm_user=no
osm_changeset=no
attributes=name,name:$OSM_LANG,population,type,place,ISO3166-1:alpha2,ISO3166-1,admin_level,boundary,capital,intermittent
ignore=area,created_by,converted_by,source,time,ele,note,openGeoDB:,fixme,FIXME
other_tags=no"
