pro rdtopex05_ncdf, filename, woce_date, julian_day_1990, latitude, longitude, sea_level, bin_count
 
; IDL routine to read TOPEX 0.5 degree grids in WOCE SAT CD-ROMs.
;
; INPUT
;       filename: (string) with file name of data file
; OUTPUT
;   woce_date:  (long) yyyymmdd
;   woce_time_of_day:  (float) hhmmss.dd
;   julian_day_1990:  (short) days since 1/1/1990 + 1
;   depth:  (float), in meters
;   latitude:  (fltarr(360)), in degrees, -90 to 90.
;   longitude:  (fltarr(720)), in degrees, -180 to 180
;   sea_level:  (intarr(720,360)), in millimeters
;   bin_count:  (bytarr(720,360)), number of points averaged in each bin
;
; K. Case 20000615
; Copyright 2000, California Institute of Technology
;----------------------------------------------------------------

; open NetCDF file
id=NCDF_OPEN(filename)

; read the data
  NCDF_VARGET, id, 0, woce_date
  NCDF_VARGET, id, 1, woce_time_of_day
  NCDF_VARGET, id, 2, julian_day_1990
  NCDF_VARGET, id, 3, depth
  NCDF_VARGET, id, 4, latitude
  NCDF_VARGET, id, 5, longitude
  NCDF_VARGET, id, 6, sea_level
  NCDF_VARGET, id, 7, bin_count

; close NetCDF file
NCDF_CLOSE, id
 
return
end

;----------------------------------------------------------------
;----------------------------------------------------------------

pro ncdf_dump, filename

; IDL routine to get variables and attributes from NetCDF file.
;
; INPUT
;       filename: (string) with file name of data file
;
; K. Case 20000327
; Copyright 2000, California Institute of Technology
;----------------------------------------------------------------

; open NetCDF file
id=NCDF_OPEN(filename)

file_inq=NCDF_INQUIRE(id)
;HELP, file_inq, /STRUCTURE

; retrieve and print global attributes
for attnum=0,file_inq.ngatts-1 do begin
  attr=NCDF_ATTNAME(id, /GLOBAL, attnum)
  NCDF_ATTGET, id, /GLOBAL, attr, value
  print, string(attr), ':  ', string(value)
endfor

; retrieve variables
for varnum=0,file_inq.nvars-1 do begin
  inq_vid = NCDF_VARINQ(id, varnum)
  print, ' '
  print,inq_vid.name
;HELP, inq_vid, /STRUCTURE

; retrieve and print attributes
  for attnum=0,inq_vid.natts-1 do begin
    attr=NCDF_ATTNAME(id, varnum, attnum)
    NCDF_ATTGET, id, varnum, attr, value
    print, string(attr), ':  ', string(value)
  endfor
endfor

; close NetCDF file
NCDF_CLOSE, id
 
return
end

;----------------------------------------------------------------
;----------------------------------------------------------------

pro driver

; Test program for rdtopex. Check output against 'rdtopex05.out'
 
filename='../data/05_deg/ssh05d19921006.nc'
rdtopex05_ncdf, filename, woce_date, julian_day_1990, latitude, longitude, sea_level, bin_count
 
;Get NetCDF variables and attributes.
ncdf_dump,filename
 
i1=340 & i2=345 & j1=160 & j2=161
print,' '
print, 'i=',i1, i2, '; j=',j1,j2, ' ', filename
for j=j1-1, j2-1 do begin
  for i=i1-1, i2-1 do begin
    print, woce_date, julian_day_1990, latitude(j), longitude(i), $
           sea_level(i,j), bin_count(i,j)
  endfor
endfor
 
return
end
