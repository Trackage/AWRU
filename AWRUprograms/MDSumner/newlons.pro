

restore, 'eachfn.xdr'
limits = [max(seal_cells.ygrid), min(seal_cells.ygrid), min(seal_cells.xgrid), max(seal_cells.xgrid)]

  ;use these to limit the arrays of lat/lons, note this is much neater than the
  ;ixy method - create all lat/lons off global grid at required res, then delimit
  ;these arrays by the limits

n_cells = 1024
dd = 360.0/n_cells
longitude = (findgen(n_cells)*dd + (dd/2.0))
latitude = 0.0 - (findgen(n_cells/4))*dd - (dd/2.0)
latlims = where(latitude LE limits[0] and latitude GE limits[1])
lonlims = where(longitude GE limits[2] and longitude LE limits[3])
lons = longitude(min(lonlims):max(lonlims))
lats = latitude(min(latlims):max(latlims))

openw, lun, 'newlons.txt', /get_lun
printf, lun, 'lons ', ',', ' lats'
for n = 0, n_elements(lons) - 1 do begin
	for m = 0, n_elements(lats) - 1 do begin
		printf, lun, lons(n), lats(m)
	endfor

endfor
free_lun, lun

end