.PRECIOUS: %/streetGraph.obj
.PHONY: build-graph
CURL:=curl -\# --fail --location

otp.jar:
	${CURL} https://otp.leonard.io/snapshots/2.2-SNAPSHOT/otp-2.2.0-SNAPSHOT-shaded-latest.jar -o $@

norcal.osm.pbf:
	${CURL} https://download.geofabrik.de/north-america/us/california/norcal-latest.osm.pbf -o $@

san-joaquin/osm.pbf: norcal.osm.pbf
	osmium extract norcal.osm.pbf --polygon san-joaquin/san-joaquin.geojson -o $@

download-gtfs:
	${CURL} --config gtfs-feeds.txt

san-joaquin/streetGraph.obj: otp.jar san-joaquin/osm.pbf
	java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044 -Xmx12G -jar otp.jar --buildStreet --save san-joaquin

build-graph: otp.jar download-gtfs san-joaquin/streetGraph.obj
	java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044 -Xmx12G -jar otp.jar --loadStreet --save san-joaquin

run: otp.jar
	java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044 -jar otp.jar --load --serve san-joaquin

clean:
	find . -name *.zip -printf '%p\n' -exec rm {} \;
	find . -name *graph.obj -printf '%p\n' -exec rm {} \;
	find . -name *streetGraph.obj -printf '%p\n' -exec rm {} \;
	find . -name *osm.pbf -printf '%p\n' -exec rm {} \;
	find . -name osm.pbf -printf '%p\n' -exec rm {} \;

