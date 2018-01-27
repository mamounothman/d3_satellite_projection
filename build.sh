#!/usr/bin/env bash


####
# Setup
mkdir -p tmp zip geojson

####
# Download data and convert to GeoJSON

# States
if [ ! -e zip/states.zip ]; then
    curl -L -o zip/states.zip 'http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_1_states_provinces.zip'
fi

if [ ! -e geojson/states.json ]; then
    unzip -o -d tmp zip/states.zip
    mapshaper tmp/ne_10m_admin_1_states_provinces.shp -o geojson/states.json
fi

# Populated places
if [ ! -e zip/populated-places.zip ]; then
    curl -L -o zip/populated-places.zip 'http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places.zip'
fi

if [ ! -e geojson/populated-places.json ]; then
    unzip -o -d tmp zip/populated-places.zip
    mapshaper tmp/ne_10m_populated_places.shp -o geojson/populated-places.json force
fi

# Urban areas
if [ ! -e zip/urban-areas.zip ]; then
    curl -L -o zip/urban-areas.zip 'http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_urban_areas.zip'
fi

if [ ! -e geojson/urban-areas.json ]; then
    unzip -o -d tmp zip/urban-areas.zip
    mapshaper tmp/ne_10m_urban_areas.shp -o geojson/urban-areas.json force
fi

####
# Combine data into TopoJSON\

mapshaper \
    -i  geojson/states.json \
        geojson/populated-places.json \
        geojson/urban-areas.json \
        combine-files \
    -filter 'ADM0NAME == "Algeria" || ADM0NAME == "Bahrain" || ADM0NAME == "Egypt" || ADM0NAME == "Iraq" || ADM0NAME == "Kuwait" || ADM0NAME == "Lebanon" || ADM0NAME == "Libya" || ADM0NAME == "Mauritania" || ADM0NAME == "Morocco" || ADM0NAME == "Oman" || ADM0NAME == "Palestine" || ADM0NAME == "Qatar" || ADM0NAME == "Saudi Arabia" || ADM0NAME == "Sudan" || ADM0NAME == "Syria" || ADM0NAME == "Tunisia" || ADM0NAME == "United Arab Emirates (UAE)" || ADM0NAME == "Yemen" || ADM0NAME == "Israel"  || ADM0NAME == "Palestine" || ADM0NAME == "Somalia" || ADM0NAME == "Pakistan" || ADM0NAME == "Afghanistan" || ADM0NAME == "Djibouti" && SCALERANK < 4' target=populated-places \
    -filter 'admin == "Jordan" || admin == "Algeria" || admin == "Bahrain" || admin == "Egypt" || admin == "Iraq" || admin == "Kuwait" || admin == "Lebanon" || admin == "Libya" || admin == "Mauritania" || admin == "Morocco" || admin == "Oman" || admin == "Palestine" || admin == "Qatar" || admin == "Saudi Arabia" || admin == "Sudan" || admin == "Syria" || admin == "Tunisia" || admin == "United Arab Emirates (UAE)" || admin == "Yemen" || admin == "Israel"  || admin == "Palestine" || admin == "Somalia" || admin == "Pakistan" || admin == "Afghanistan" || admin == "Djibouti"' target=states \
    -clip states target=urban-areas \
    -o topo.json format=topojson target=* force

####
# Clean up
rm -rf tmp
