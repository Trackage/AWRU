
file = findfile(filepath('APF87-99.csv', subdirectory = '/resource/datafile'))

openr, unit, file, /get_lun
maxlines = 100000

	   ;a will contain strings of each line from the file

a = strarr(maxlines)

   ;read the file into a, goto label if i/o error

on_ioerror, done_reading
readf, unit, a
done_reading: s = fstat(unit)		;Get # of lines actually read, null the error
a = a[0: (s.transfer_count-1) > 0]
on_ioerror, null
FREE_LUN, unit

lines = n_elements(a)
lons = fltarr(lines)
lats = fltarr(lines)

for n = 1, n_elements(a) -1 do begin

	bits = str_sep(a(n), ',')
	lons(n) = bits(0)
	lats(n) = bits(1)


endfor

llstru = {lons:lons, lats:lats}

end
