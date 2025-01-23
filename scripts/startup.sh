#!/bin/bash

# Create tiles directory
mkdir -p valhalla_tiles

# Generate valhalla config
valhalla_build_config \
    --mjolnir-tile-dir ${PWD}/valhalla_tiles \
    --mjolnir-tile-extract ${PWD}/valhalla_tiles.tar \
    --mjolnir-timezone ${PWD}/valhalla_tiles/timezones.sqlite \
    --mjolnir-admin ${PWD}/valhalla_tiles/admins.sqlite > valhalla.json

# Build supporting databases
valhalla_build_timezones > valhalla_tiles/timezones.sqlite
valhalla_build_admins -c valhalla.json odtu-latest.osm.pbf

# Ingest Transit Data
valhalla_ingest_transit -c valhalla.json 
valhalla_convert_transit -c valhalla.json

# Build routing tiles
valhalla_build_tiles -c valhalla.json odtu-latest.osm.pbf

# Build tile extract for faster loading
valhalla_build_extract -c valhalla.json -v

# Clone demos repository
git clone --depth=1 --recurse-submodules --single-branch --branch=gh-pages https://github.com/valhalla/demos.git

# Start the server
valhalla_service valhalla.json 1 