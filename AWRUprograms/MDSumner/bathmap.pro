PRO bathmap, cells, pos

file = filepath('worldelv.dat', subdir='examples/data')
openr, lun, file, /get_lun
data = bytarr(360, 360)
readu, lun, data
free_lun, lun
;- Reorganize array so it spans 180W to 180E
world = data
;world = data[127:219, 41:100]
;- Create remapped image
;map_set, /orthographic, /isotropic, /noborder
bthmap = map_image(world, x0, y0, xsize, ysize, compress=1, lonmin = min(cells.xgrid), $
	lonmax = max(cells.xgrid), latmin = min(cells.ygrid), latmax = max(cells.ygrid))


imdisp, bthmap, pos = pos , /usepos, color = 0, ncolors = !d.table_size - 1, $
	 background = !d.n_colors - 1, title = title

end