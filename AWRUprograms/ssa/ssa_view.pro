;==============================================================================
; NAME:
;       SSA_EXT.PRO
; PURPOSE:
;       To extract sea surface anomaly (ssa) data from WOCE Global Data files
;	in a specified region.
;
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
;	File name.
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:  Written by MD Sumner May 2001.
;==============================================================================


PRO ssa_view

files = findfile('*.nc')

for a = 0, n_elements(files) - 1 DO BEGIN

filename = files(a)

  ;this file open section is from K.Case's rdtopex05_NCDF.pro

;rdtopex05_ncdf, file_name
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


  ;define limits of seal area of interest

;limits = [-30.0, -80.0, 100.0, 220.0]
limits = [-30.0, -80.0, 90.0, 240.0]
  ;use these to limit the arrays of lat/lons, note this is much neater than the
  ;ixy method - create all lat/lons off global grid at required res, then delimit
  ;these arrays by the limits

latlims = where(latitude LE limits[0] and latitude GE limits[1])
lonlims = where(longitude GE limits[2] and longitude LE limits[3])

  ;extract desired area

area = sea_level(min(lonlims):max(lonlims), min(latlims):max(latlims))

window, a, xsize = 250, ysize = 110
tv, area

valid = where(area LT 32766, good)

jd1990 = ymd2jd(1990,1,1)

julday = jd1990 + julian_day_1990

jd2ymd, julday, year, month, day


print, filename, ' ', day, month, year, ' valid data = ', good


endfor

stop


END

