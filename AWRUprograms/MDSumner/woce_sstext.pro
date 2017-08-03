PRO WOCE_SSTEXT, filename, arr, lons, lats, woce_date = woce_date, land = land, $
	nomask = nomask, noconv = noconv

ON_error, 2
zip, filename, /unzip

	;This section from RDAVHRR10_NCDF, MDS 2Nov01

; K. Case 20000612
; Copyright 2000, California Institute of Technology
;----------------------------------------------------------------

; open NetCDF filename
id=NCDF_OPEN(filename)

; read the data
  NCDF_VARGET, id, 0, woce_date
  NCDF_VARGET, id, 1, woce_time_of_day
  NCDF_VARGET, id, 2, julian_day_1990
  NCDF_VARGET, id, 3, depth
  NCDF_VARGET, id, 4, latitude
  NCDF_VARGET, id, 5, longitude
  NCDF_VARGET, id, 6, sea_surface_temperature

		;I don't know why the NASA programs aren't written to handle either file
		;it's not as if this bin_count is returned to user anyway!

  		half_deg = strpos(filename, '05')  ;only the 0.5 degree files have bin_count
  		IF half_deg GT 0 THEN  NCDF_VARGET, id, 7, bin_count

; close NetCDF file
NCDF_CLOSE, id
;----------------------------------------------------------------------------------


 zip, filename

arr = sea_surface_temperature
lons = longitude
lats = latitude


arr = rotate(arr, 7)
bad = where(arr GE 32766)
land = where(arr EQ 32766)

IF NOT keyword_set(noconv) THEN arr = arr/100.0

mask = arr*0.0 + 1
mask(bad) = 0


IF not keyword_set(nomask) THEN arr(bad) = -9999.0


END