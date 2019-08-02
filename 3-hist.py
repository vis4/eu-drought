from PIL import Image
import os

try:
    done = [r.split(',')[0] for r in open('europe-stats.csv').read().split('\n')]
except:
    done = []
    print('date,wet3,wet2,wet1,dry1,dry2,dry3')

def run(file):
    date = file[11:-4]
    if date in done:
        return
    im = Image.open(file)
    total = im.height * im.width

    hist = im.histogram()[0:256]
    black = hist[0]
           # wet3     wet2       wet1       dry1       dry2       dry3
    data = [hist[33], hist[103], hist[209], hist[254], hist[241], hist[179]]
    land = total - black
    data_pct = [k/land for k in data]
    row = [file] + data_pct
    print(date + (',%.4f'*6) % tuple(data_pct))


for file in sorted(os.listdir('warped')):
    if file[-4:] == '.tif':
        run('warped/'+file)



#for pixel in im.getdata():
#    k = '%d-%d-%d-%d' % pixel
#    if k in counts:
#        counts[k] += 1
#    else:
#        counts[k] = 1
#    if k != '0-0-0-0':
#        opaque += 1

#print(counts)
