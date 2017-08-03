;;- Read world elevation data
file = filepath('worldelv.dat', subdir='examples/data')
openr, lun, file, /get_lun
data = bytarr(360, 360)
readu, lun, data
free_lun, lun
;- Reorganize array so it spans 180W to 180E
world = data
;world[0:179, *] = data[180:*, *]
;world[180:*, *] = data[0:179, *]
;world = world(127:219, 42:98)
;- Create remapped image
map_set,  /cylindrical, /noborder
remap = map_image(world, x0, y0, xsize, ysize, compress=1)
;- Convert offset and size to position vector
pos = fltarr(4)
pos[0] = x0 / float(!d.x_vsize)
pos[1] = y0 / float(!d.y_vsize)
pos[2] = (x0 + xsize) / float(!d.x_vsize)
pos[3] = (y0 + ysize) / float(!d.y_vsize)
;- Display the image
loadct, 3
imdisp, remap, pos=pos, /usepos
map_continents
map_grid


end