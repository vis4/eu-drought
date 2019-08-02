import requests
import os.path

last = (2019, 7, 11)

world = '''0.013695219123505976
0.00000
0.00000
-0.013695219123505976
-35.3
72.99315239043824
'''

for year in range(1995, last[0]+1):
    for month in range(1,13):
        for tendays in [1,11,21]:
            if year == last[0] and ((month > last[1]) or (month == last[1] and tendays>last[2])):
                break
            url = 'http://edo.jrc.ec.europa.eu/edov2/php/gis/mswms.php?map=edo_w_mf&LAYERS=smi_anom_xtnd_img%%2Csmi_anom_xtnd_5km&FORMAT=image%%2Fpng&TRANSPARENT=TRUE&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&STYLES=&SELECTED_YEAR=%d&SELECTED_MONTH=%02d&SELECTED_TENDAYS=%02d&SRS=EPSG%%3A4326&BANDS=7&BBOX=-31,18,56,73&WIDTH=6984&HEIGHT=4016' % (year, month, tendays)
            # print(url)
            out = 'edo-png/smi-%d-%02d-%02d.png'% (year, month, tendays)
            if not os.path.isfile(out):
                r = requests.get(url, stream=True)
                print(out)
                with open(out, 'wb') as fd:
                    for chunk in r.iter_content(chunk_size=128):
                        fd.write(chunk)
                outw = 'edo-png/smi-%d-%02d-%02d.pngw'% (year, month, tendays)
                open(outw, 'w').write(world)

