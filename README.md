# eu-drought

Please have a look at [this related article with interactive graphics](https://vis4.net/drought) first :)

## pre-requisites

* Python 3 with PIL and requests
* GDAL
* ImageMagick
* ffmpeg
* R

## steps in the analysis

Download all map images from EDO:

```bash
make 1-download
```

Geo-reference PNG images as GeoTIFFs and project them to EPSG:3035

```bash
make 2-warp
```

Compute color histograms for each frame and store them in a CSV file with one line per frame

```bash
make 3-hist
```

Crop the images to the `bounds.geojson` file to remove empty white-space and make it easier to align a D3 map later

```bash
make 4-crop
```

Resize images to our target video size

```bash
make 5-resize
```

Label the images with the year and month

```bash
make 6-label
```

Generate the videos used in the article

```bash
make 7-video
```

To generate the data used in the last chart run the R script
