pro ssmiout, ssmi, seaice

openr, lun, 'ssmigrid.dat', /get_lun

readf, lun, tx, ty

xgrid = fltarr(tx,ty)
ygrid = fltarr(tx,ty)

readf, lun, xgrid
readf, lun, ygrid

close, lun

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

end