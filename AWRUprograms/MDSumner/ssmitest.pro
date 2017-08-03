FUNCTION ssmitest, file




	openr, lun, file, /get_lun
	readf, lun,  tx, ty
	lons = fltarr(tx)

	lats = fltarr(ty)
	readf, lun, lons, lats
	seaice = fltarr(tx, ty)
	readf, lun, seaice
	close, lun

return, seaice

end