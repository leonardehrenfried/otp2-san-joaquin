.PRECIOUS: %/streetGraph.obj
.PHONY: build-graph
WGET:=wget --show-progress

otp.jar:
	${WGET} https://otp.leonard.io/snapshots/2.2-SNAPSHOT/otp-2.2.0-SNAPSHOT-shaded-latest.jar -O $@

norcal.osm.pbf:
	${WGET} https://download.geofabrik.de/north-america/us/california/norcal-latest.osm.pbf -O $@

san-joaquin/osm.pbf: norcal.osm.pbf
	osmium extract norcal.osm.pbf --polygon san-joaquin/san-joaquin.geojson -o $@

download-gtfs:
	${WGET} -i input/gtfs-files.txt --no-clobber

san-joaquin/streetGraph.obj: otp.jar san-joaquin/osm.pbf
	java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044 -Xmx12G -jar otp.jar --buildStreet --save san-joaquin

build-graph: otp.jar download-gtfs san-joaquin/streetGraph.obj
	java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044 -Xmx12G -jar otp.jar --loadStreet --save san-joaquin

run-%: otp.jar
	java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044 -jar otp.jar --load --serve $*

clean:
	find . -name *gtfs.zip -printf '%p\n' -exec rm {} \;
	find . -name graph.obj -printf '%p\n' -exec rm {} \;
	find . -name streetGraph.obj -printf '%p\n' -exec rm {} \;
	find . -name *osm.pbf -printf '%p\n' -exec rm {} \;

