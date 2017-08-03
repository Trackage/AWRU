PRO file_check, files

;this is to check if there are copies of sat files, some compressed some not

for n = 0, n_elements(files) - 1 do begin

	filenm = strupcase(files(n))
	comp1 = strpos(filenm, '.Z')
	comp2 = strpos(filenm, '.GZ')
	IF comp1 GT 0 THEN filenm = strmid(filenm, 0, strlen(filenm) - 2)
	IF comp2 GT 0 THEN filenm = strmid(filenm, 0, strlen(filenm) - 3)

	FOR p = 0, n_elements(files) - 1 do begin

		IF filenm = files(p) THEN message, 'There are un/compressed replicates of files:  delete the uncompressed ones '

ENDFOR

END