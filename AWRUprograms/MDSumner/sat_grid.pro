;+
; NAME:
;    sat_grid
;
;    ripped off map_cell, thrown away display stuff , just to output data to file
;
; Input: sat array with lons and lats of cell centres, converts lons and lats to corners
;
;-

pro sat_grid, lons, lats, filename

nx = n_elements(lons)
ny = n_elements(lats)

cell_x = lons(1) - lons(0)
cell_y = lats(1) - lats(0)

clons = [lons(0) - cell_x/2.0,  lons + cell_x/2.0]

clats = [lats(0) - cell_y/2.0,  lats + cell_y/2.0]

IF n_elements(filename) EQ 0 THEN filename = 'Corner_grid.txt'

openw, wlun, filename, /get_lun
	print, 'Writing grid corners file ', filename
	printf, wlun, 'lons', ',', 'lats'
	for n = 0, n_elements(clons) - 1 do begin
		for m = 0, n_elements(clats) - 1 do begin

			printf, wlun, clons(n), ',', clats(m)
		endfor
	endfor

free_lun, wlun


end



