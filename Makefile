UCDP_GED_ZIP = ged231-csv.zip
UCDP_GED_CSV = GEDEvent_v23_1.csv
UCDP_GED_URL = https://ucdp.uu.se/downloads/ged/$(UCDP_GED_ZIP)

all: tmp/kanto-latest.osm.pbf osm2pgsql $(UCDP_GED_CSV) ogr2ogr-ucdp-ged

.PHONY: setup
setup:
	sudo apt install -y wget unzip osm2pgsql gdal-bin

tmp/kanto-latest.osm.pbf:
	wget https://download.geofabrik.de/asia/japan/kanto-latest.osm.pbf -O ./tmp/kanto-latest.osm.pbf

.PHONY: osm2pgsql
osm2pgsql:
	osm2pgsql --create --database=tileserv --slim --username=postgres --password --host=localhost --port 54321 ./tmp/kanto-latest.osm.pbf

GEDEvent_v23_1.csv:
	ls ./tmp/$(UCDP_GED_ZIP) || wget $(UCDP_GED_URL) -O ./tmp/$(UCDP_GED_ZIP)
	unzip ./tmp/$(UCDP_GED_ZIP) -d ./tmp

.PHONY: ogr2ogr-ucdp-ged
ogr2ogr-ucdp-ged:
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

.PHONY: ogr2ogr-japan-evacuation-site-de
ogr2ogr-japan-evacuation-site-de:
	ogr2ogr \
		-overwrite \
		-f "PostgreSQL" PG:"dbname=tileserv user=postgres password=postgres host=localhost port=54321" \
		-oo AUTODETECT_TYPE=YES \
		-nln "japan_evacuation_site_de" \
		--config PG_USE_COPY YES \
		--debug ON \
		./tmp/00_全国_指定緊急避難場所/all.shp

.PHONY: ogr2ogr-significant-earthquake
ogr2ogr-significant-earthquake:
	ogr2ogr \
		-overwrite \
		-f "PostgreSQL" PG:"dbname=tileserv user=postgres password=postgres host=localhost port=54321" \
		-oo AUTODETECT_TYPE=YES \
		-oo X_POSSIBLE_NAMES=Longitude \
		-oo Y_POSSIBLE_NAMES=Latitude \
		-a_srs EPSG:4326 \
		-nln "significant_earthquake" \
		--config PG_USE_COPY YES \
		--debug ON \
		./tmp/Significant\ Earthquake\ Dataset\ 1900-2023.csv

.PHONY: ogr2ogr-opt-health-facilities
ogr2ogr-opt-health-facilities:
	ogr2ogr \
		-overwrite \
		-f "PostgreSQL" PG:"dbname=tileserv user=postgres password=postgres host=localhost port=54321" \
		-oo AUTODETECT_TYPE=YES \
		-nln "palestine_health_facilities" \
		--config PG_USE_COPY YES \
		--debug ON \
		./tmp/oPt-healthfacilities/health_facilities_oPt.shp

.PHONY: ogr2ogr-noto-evacuation-site-2024
ogr2ogr-noto-evacuation-site-2024:
	nkf -w --cp932 tmp/all_hinanjyocsv_20240321180034.csv > tmp/all_hinanjyocsv_20240321180034-utf_8.csv
	ogr2ogr \
		-overwrite \
		-f "PostgreSQL" PG:"dbname=tileserv user=postgres password=postgres host=localhost port=54321" \
		-oo AUTODETECT_TYPE=YES \
		-oo X_POSSIBLE_NAMES=longitude \
		-oo Y_POSSIBLE_NAMES=latitude \
		-lco ENCODING=UTF-8 \
		-a_srs EPSG:4326 \
		-nln "noto_evacuation_site_2024" \
		--config PG_USE_COPY YES \
		--debug ON \
		./tmp/all_hinanjyocsv_20240321180034-utf_8.csv
