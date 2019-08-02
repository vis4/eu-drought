from PIL import Image
from PIL import ImageFont
from PIL import ImageDraw
import numpy as np
import os

months = 'January,February,March,April,May,June,July,August,September,October,November,December'.split(',')

font1 = ImageFont.truetype("fonts/Roboto-Light.ttf", 70)
font2 = ImageFont.truetype("fonts/Roboto-Light.ttf", 50)

index = 0

def run(file):
    global index
    im = Image.open(file).convert('RGB')
    draw = ImageDraw.Draw(im)
    date= file[12:-4]
    year=date[:4]
    month=int(date[5:7])
    print(year, month)
    draw.text((90, 90), year, (60,60,60), font=font1)
    draw.text((90, 170), months[month-1], (60,60,60), font=font2)
    im2 = im.convert('P')
    im2.save('labeled/frame-%03d.png' % index)
    index += 1
    # print( + (',%.4f'*6) % tuple(data_pct))


for file in sorted(os.listdir('resized')):
    if file[-4:] == '.png':
        run('resized/'+file)



#for pixel in im.getdata():
#    k = '%d-%d-%d-%d' % pixel
#    if k in counts:
#        counts[k] += 1
#    else:
#        counts[k] = 1
#    if k != '0-0-0-0':
#        opaque += 1

#print(counts)
