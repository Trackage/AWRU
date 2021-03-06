PRO MCSSTclimout, infile, outfile, arrayname


checkfile = findfile(infile)
IF checkfile[0] EQ '' THEN message, 'Cannot find ' + infile
;create text files of MCSST climatology

arrnames = ['mean','sdev','sum','SSQ','nn','stderr','mle','lnsdev','lnmean','lnsum','lnSSQ','lnSE']
num = where(arrnames EQ arrayname)
num = num[0]
IF num LT - 1 THEN message, 'No array in ' + infile + ' with name ' + arrayname


zip, infile, /unzip

openr, lun, infile, /get_lun
readf, lun, x, y

IF  x LT 800 THEN BEGIN
	arrnames = [arrnames[0:5],arrnames[7:11]]
	num = where(arrnames EQ arrayname)
	num = num[0]
	IF num LT - 1 THEN message, 'No array in ' + infile + ' with name ' + arrayname
ENDIF
lons = fltarr(x)
lats = fltarr(y)
readf, lun, lons, lats


temp = fltarr(x,y)

for n = 0, n_elements(arrnames) -1 do begin

	readf, lun, temp
	;bad = where(temp EQ -99)
	;IF bad[0] NE -1 THEN temp(bad) = -9999
	;map_array, temp, lons, lats, title = arrnames[n]

	IF n EQ num THEN array = temp
endfor


FREE_LUN, lun

bad = where(array EQ -99)
IF bad[0] NE -1 THEN array(bad) = -9999
map_array, array, lons, lats, title = arrayname

sat_file, rotate(array,7), lons, lats, outfile, val = arrayname
zip, infile

END
