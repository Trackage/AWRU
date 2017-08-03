pro coltbl_load, colfile, linux = linux
;+
;NAME:  coltbl_load
;PURPOSE:
;       load a pseudo-colour colour table in CSIRO DO/DF Marine labs format
;CALLING SEQUENCE:
;       coltbl_load, colfile
;INPUTS:
;       file_name:
;OUTPUTS:
;       nil. A colour table is loaded into the device colour table
;-MODIFICATION HISTORY:  Added keyword linux to enable
;display on Ant CRC linux boxes field, frazil and floe, when called by
;seal and penguin track programs, MDS 8August01.


on_error, 2


common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
blue  = bytarr(256)
green = bytarr(256)
red   = bytarr(256)


if n_elements( colfile ) le 0 then $
        message,'Usage: coltbl_load, ML_format_colour_table_file_name'
suff = ''
if strpos(colfile,'.pse',strlen(colfile)-4) lt 0  then suff='*.pse'
ff = findfile(colfile+suff, count=count)
if count eq 0 then begin
        message, 'colfile '+colfile+' not found'
endif


openr, lun, colfile, /get_lun
coltbl_header = ' '
readf, lun, format='(a)', coltbl_header
IF keyword_set(linux) THEN BEGIN
	readf, lun, green, red, blue
ENDIF ELSE BEGIN
	readf, lun, blue, green, red
ENDELSE

close, lun
free_lun, lun


;print, 'coltbl_load before n_colors=',!d.n_colors
;IF keyword_set(linux) THEN BEGIN
;	blue[0] = 0
;	green[0] =0
;	red[0] = 0
;	blue[255] =255 
;	green[255] = 255
;	red[255] = 255
;ENDIF

tvlct, red, green, blue
r_curr = red
g_curr = green
b_curr = blue
r_orig = r_curr
g_orig = g_curr
b_orig = b_curr
;print, 'coltbl_load after n_colors=',!d.n_colors


return
end
