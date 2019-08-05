1-download:
	mkdir -p edo-png
	python 1-dl.py

2-warp:
	mkdir -p warped
	@cat 2-warp.sh | zsh

3-hist:
	python -u 3-hist.py >> europe-stats.csv

4-crop:
	mkdir -p cropped
	@cat 4-crop.sh | zsh

5-resize:
	mkdir -p resized
	@cat 5-resize.sh | zsh

6-label:
	mkdir -p labeled
	python -u 6-label.py

7-video: output/video.webm output/video.mp4

output/video.webm:
	mkdir -p output
	ffmpeg -y -r 12 -i labeled/frame-%03d.png -c:v libvpx -b:v 500k -crf 24 -c:a none -pix_fmt yuv420p -speed 8 -deadline realtime -cpu-used -8 output/video.webm

output/video.mp4:
	mkdir -p output
	ffmpeg -y -r 12 -i labeled/frame-%03d.png -vf "scale=-2:720:flags=lanczos" -f mp4  -vcodec libx264 -profile:v main -level 3.1 -preset medium -crf 29 -x264-params ref=4 -c:a none -pix_fmt yuv420p -movflags +faststart output/video.mp4
