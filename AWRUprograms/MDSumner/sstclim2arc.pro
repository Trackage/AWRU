;--------------------------------------------------------------------------------------------------
PRO sstclim2arc, area, lons, lats, file, filename, med = med

IF n_elements(file) EQ 0 THEN file = filepath('JANinterp', subdirectory = '/resource/datafile/satdata')
openr, lun, file, /get_lun
readf, lun, x, y
lons = fltarr(x)
lats = fltarr(y)
temp = fltarr(x,y)
readf, lun, lons, lats, temp

free_lun, lun


area = rotate(temp, 7)
IF keyword_set(med) THEN area = median(area, 5)

IF n_elements(filename) EQ 0 THEN filename = 'JANintpsst.txt'
sat_file, area, lons, lats, filename

END
;--------------------------------------------------------------------------------------------

