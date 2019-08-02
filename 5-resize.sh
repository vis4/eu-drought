#!/bin/zsh
mkdir -p resized
for d in cropped/*.tif
do
	out="${${d/cropped/resized}/.tif/.png}"
	if [ ! -f $out ]
	then
		echo $d
		convert $d -interpolate Nearest -filter point -resize 2160x2160 -background white -flatten $out
	fi
done
