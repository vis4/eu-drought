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

7-video:
	mkdir -p output
	ffmpeg -y -r 12 -i labeled/frame-%03d.png -f webm -speed 8 -deadline realtime -cpu-used -8 -pix_fmt yuv420p output/video.webm
	ffmpeg -y -r 12 -i labeled/frame-%03d.png -f mp4 -c:v libx264 -crf 36 -pix_fmt yuv420p output/video.mp4
