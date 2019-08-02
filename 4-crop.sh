#!/bin/zsh

for d in warped/*.tif
do
	out="${d/warped/cropped}"
	if [ ! -f $out ]
	then
		gdalwarp -cutline bounds.geojson -crop_to_cutline  $d $out
	fi
done
