; IDL Version 5.2.1 (Win32 x86)
; Journal File for mdsumner@ANTARCTIQUE
; Working directory: C:\Program Files\RSI\IDL52
; Date: Sat Sep 29 11:30:25 2001

SWfiles = findfile(filepath('*CHLO', subdirectory = '/resource/datafile/satdata'))
sstfiles = findfile(filepath('*hdf', subdirectory = '/resource/datafile/satdata'))
tfile = sstfiles(0)
cfile = SWfiles(0)
sstext, tfile, temps, tlons, tlats, /intp, mask = tm, /noconv
;returned array contains interpolated MCSST
swext, cfile, chla, lons, lats, mask = cm, /noconv
;.continue
;.continue
imdisp, temps
imdisp, chla
data = where(chla LT 255)
no_data = where(chla EQ 255)
col = chla
col = chla*1.0
col(no_data) = !values.F_NAN
col(data) = chla(data)*1.0
conts = rebin(temps, 4096, 2048)
conts(data) = !values.f_nan
; % Program caused arithmetic error: Floating illegal operand
;.COMPILE "C:\Program Files\RSI\IDL52\lib\programs\globe_2map.pro"
globe_2map, col, conts, lons, lats


END