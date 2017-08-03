PRO sst_out, area, lons, lats, file

IF n_elements(file) EQ 0 THEN file = filepath('JANinterp', subdirectory = '/resource/datafile')
openr, lun, file, /get_lun
readf, lun, x, y
lons = fltarr(x)
lats = fltarr(y)
temp = fltarr(x,y)
readf, lun, lons, lats, temp
temp = rotate(temp, 7)
free_lun, lun

;bad = where(temp LT -90.0)
;bad = search2d(temp, 0, 0, -100,  -2)
;good = where(temp GT -2)
;area = temp + !values.f_nan
;area = temp
;area(bad) = !values.f_nan
;area(good) = 1
;area = area * temp
;area = bytscl(area)

area = temp
;stop


END