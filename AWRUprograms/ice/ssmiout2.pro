pro ssmiout2, year, jday, seaice

; call passive_get_data to obtain the SSM/I data
type = 3
root_dir = '/v/passive/data'
month = 0
status = passive_get_data(type, root_dir, jday, month, year, /julian, data=ssmi)

if status eq 0 then begin

	openr, lun, 'ssmigrid.dat', /get_lun

	readf, lun, tx, ty

	xgrid = fltarr(tx,ty)
	ygrid = fltarr(tx,ty)

	readf, lun, xgrid
	readf, lun, ygrid

	close, lun
stop
	a = size(ssmi)

	xmax = a[1]
	ymax = a[2]

	seaice = fltarr(tx,ty)

	for lat = 0, ty-1 do begin
		for lon = 0, tx-1 do begin

			xcoord = xgrid[lon,lat]
			ycoord = ygrid[lon,lat]

			if (xcoord ge 0.0) and (xcoord lt xmax) and (ycoord ge 0.0) and (ycoord lt ymax) then begin

				x = round(xcoord)
				y = round(ycoord)
				seaice[lon,lat] = ssmi[x,y]

			end else begin

				seaice[lon,lat] = -1.0

			endelse

		endfor
	endfor

	ylen = strlen(year)
	yy = strmid(year,ylen-1,2)

	filename = 'i' + day + yy + '.dat'

	openw, lun, filename, /get_lun
	printf, tx, ty
	printf, seaice
	close, lun

endif

end