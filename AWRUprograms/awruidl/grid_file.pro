PRO grid_file, cells, gridfilnm

openw, wlun, gridfilnm, /get_lun
printf, wlun, 'Long ', ',', 'lat'
for n = 0, n_elements(cells.xgrid) - 1 do begin
	for m = 0, n_elements(cells.ygrid) - 1 do begin
			printf, wlun, cells.xgrid(n), ',', cells.ygrid(m)
	endfor
endfor
free_lun, wlun
END