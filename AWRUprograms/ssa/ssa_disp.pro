PRO ssa_disp

files = findfile(filepath('*.nc', subdirectory = '/resource/datafile'))

;!p.multi = [0, 4, 5]

for p = 0, 50 do begin
for n = 0, n_elements(files) - 1 do begin

	ssa_ext, files(n), area, lons, lats, woce_date, /nolimit

	bad = where(area GE 32766)
	;area = area + abs(min(area))
	;area(bad) = !values.f_nan

	imdisp, rebin(area, 48, 20), /axis, title = files(n)

endfor
endfor


end