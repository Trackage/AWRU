pro mapssmi

dx = 360.0d00/4096.0d00
dy = dx

;spawn, 'gunzip t26599.dat.gz'
openr, lun, 't26599.dat', /get_lun

readf, lun, tx, ty

lats = fltarr(ty)
lons = fltarr(tx)

readf, lun, lons, lats

xgrid = fltarr(tx,ty)
ygrid = fltarr(tx,ty)

free_lun, lun

for lat = 0, ty-1 do begin
	for lon = 0, tx-1 do begin

		cells = passive_f_map_loc(lats[lat],lons[lon],/to_grid, source='spsg')
		xgrid[lon,lat] = cells[0]
		ygrid[lon,lat] = cells[1]

	endfor
endfor

openw, lun, 'ssmigrid.dat', /get_lun

printf, lun, tx, ty
printf, lun, xgrid
printf, lun, ygrid

free_lun, lun

end