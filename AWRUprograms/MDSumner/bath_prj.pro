PRO bath_prj, world


; Read world elevation data
file = filepath('worldelv.dat', subdir='examples/data')
openr, lun, file, /get_lun
data = bytarr(360, 360)
readu, lun, data
free_lun, lun
dx = 1.0
dy = 0.5
lons = findgen((360)) * dx + (dx/2.0)
 lats = findgen((360))*dy + (dy/2.0) - 90.0



 world = rotate(data, 7)

lim_area, world, lons, lats, area, alons, alats, limits = [-40.0, -90.0, 0, 360.0]

 map_array_ster, area, alons, alats, /nowin_conv
 oplot_fronts, /all

end