EXTRACT = bin/extract
TOPOJSON = node_modules/.bin/topojson
TOPOMERGE = node_modules/.bin/topojson-merge

CDN=http://static.quattroshapes.com
NATURAL_EARTH_CDN = http://naciscdn.org/naturalearth
#COUNTRY_GENONAME = http://download.geonames.org/export/dump/countryInfo.txt

ADM0=qs_adm0_region.zip
ADM1=qs_adm1_region.zip
SHP0=shp/qs_adm0_region.shp
SHP1=shp/qs_adm1_region.shp

GEOS = $(wildcard geojson/*.geojson)
TOPOS = $(patsubst geojson/%.geojson,topojson/%.topojson,$(GEOS))

topojson.tar.gz: $(TOPOS) geojson
	@tar -zcvf $< topojson

topojson/WORLD.topojson: geojson/WORLD.geojson
	mkdir -p $(dir $@)
	$(TOPOJSON) \
    --simplify-proportion=.1 \
	  --quantization 1e5 \
	  --id-property=+id \
	  -- regions=$< \
	  | $(TOPOMERGE) \
	    -o $@ \
	    --io=regions \
	    --oo=land \
	    --no-key
topojson/%.topojson: geojson/%.geojson
	mkdir -p $(dir $@)
	$(TOPOJSON) \
	  --quantization 1e5 \
	  --id-property=+id \
	  -- regions=$< \
	  | $(TOPOMERGE) \
	    -o $@ \
	    --io=regions \
	    --oo=land \
	    --no-key

geojson: shp/ne_10m_admin_0_countries.shp tsv/country_info.tsv shp/ne_10m_admin_1_states_provinces.shp
	@mkdir -p $@
	@$(EXTRACT) $@ shp/ne_10m_admin_0_countries.shp tsv/country_info.tsv shp/ne_10m_admin_1_states_provinces.shp

shp/qs_%.shp: zip/qs_%.zip
	@mkdir -p $(dir $@)
	@unzip -d shp $<
	@touch $@
shp/ne_%_admin_0_countries.shp: zip/ne_%_admin_0_countries.zip
	@mkdir -p $(dir $@)
	@unzip -d shp $<
	@touch $@
shp/ne_%_admin_1_states_provinces.shp: zip/ne_%_admin_1_states_provinces.zip
	@mkdir -p $(dir $@)
	@unzip -d shp $<
	@touch $@

zip/$(ADM0):
	@mkdir -p $(dir $@)
	@curl $(CDN)/$(ADM0) -o $@
zip/$(ADM1):
	@mkdir -p $(dir $@)
	@curl $(CDN)/$(ADM1) -o $@

## TODO remove the comments at the top of the file
tsv/country_info.tsv:
	@mkdir -p $(dir $@)
	@curl $(COUNTRY_GENONAME) -o $@

zip/ne_10m_%.zip:
	@mkdir -p $(dir $@)
	@curl "$(NATURAL_EARTH_CDN)/10m/cultural/ne_10m_$*.zip" -o $@.download
	@mv $@.download $@

.PHONY: topojson
