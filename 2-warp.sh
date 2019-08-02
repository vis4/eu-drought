#!/bin/bash
for d in edo-png/*.png
do
	out="${${d/.png/.tif}/edo-png/warped}"
	if [ ! -f $out ]
	then
		gdalwarp -s_srs EPSG:4326 -t_srs EPSG:3035 $d $out
	fi
done
