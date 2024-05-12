UCDP_GED_ZIP = ged231-csv.zip
UCDP_GED_CSV = GEDEvent_v23_1.csv
UCDP_GED_URL = https://ucdp.uu.se/downloads/ged/$(UCDP_GED_ZIP)

all: $(UCDP_GED_CSV)

GEDEvent_v23_1.csv:
	ls ./tmp/$(UCDP_GED_ZIP) || wget $(UCDP_GED_URL) -O ./tmp/$(UCDP_GED_ZIP)
	unzip ./tmp/$(UCDP_GED_ZIP)

tmp/kanto-latest.osm.pbf:
	wget https://download.geofabrik.de/asia/japan/kanto-latest.osm.pbf -O ./tmp/kanto-latest.osm.pbf

.PHONY: osm2pgsql
osm2pgsql:
	osm2pgsql --create --database=tileserv --slim --username=postgres --password --host=localhost --port 54321 ./tmp/kanto-latest.osm.pbf

# -append -update
.PHONY: ogr2ogr
ogr2ogr:
	ogr2ogr \
		-overwrite \
		-f "PostgreSQL" PG:"dbname=tileserv user=postgres password=postgres host=localhost port=54321" \
		-oo AUTODETECT_TYPE=YES \
		-oo GEOM_POSSIBLE_NAMES=geom_wkt \
		-oo X_POSSIBLE_NAMES=longitude \
		-oo Y_POSSIBLE_NAMES=latitude \
		-a_srs EPSG:4326 \
		-lco FID=id \
		-nln "ucdp_ged" \
		--config PG_USE_COPY YES \
		--debug ON \
		./tmp/$(UCDP_GED_CSV)
