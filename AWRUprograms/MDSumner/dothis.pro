
file = 'G:\satdata\pathfinder\2001\200101h18ea-gdm.hdf.gz'
;pathext, file, arr, lons, lats, /orig, /noconv
array = arr

	;find the non-data values (missing or land)
bad = where(array LE -9998)

	;Not-a-Number out the non values
array(bad) = !values.f_nan
;you will get this error, don't worry:  "% Program caused arithmetic error: Floating illegal operand"

	;smooth the global array with a 5*5 boxcar average (this fills in the missing stuff
array = smooth(array, 5, /nan)

	;now assign this value to the land areas
;array(land) = -9999

;cut out the section you want
;lim_area, array, lons, lats, area, alons, alats, limits = limits

	;write this section to ARC file with the labels defined above
;sat_file, area, alons, alats, lab, val = val
map_array, array, lons, lats, /nwin

END