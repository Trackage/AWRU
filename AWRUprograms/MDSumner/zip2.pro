PRO ZIP2, file, unzip = unzip
;on_error, 2
IF size(file, /n_dimensions) NE 0 AND n_elements(file) NE 1 THEN message, 'Need scalar input, i.e. only one file name, not an array'
;this will compress or uncompress a file, renaming the file appropriately
print, file
file = findfile(file, count = check)
;ok = ok[0]
IF check EQ 0 THEN MESSAGE, 'No such file: ' + file

gz_pos = strpos(strupcase(file), '.GZ')
Z_pos = strpos(strupcase(file), '.Z')

IF NOT keyword_set(unzip) THEN BEGIN

	IF  NOT gz_pos GT -1 OR  Z_pos GT -1 THEN BEGIN
	   ;recompress the file

		Print, 'preparing to compress ', file

		IF strupcase(!version.os) EQ 'WIN32' THEN BEGIN
			command = 'gzip -f '  + file
			spawn, command
		ENDIF
		IF strupcase(!version.os) EQ 'SUNOS' THEN BEGIN

			command = 'gzip ' + file
			Spawn, command

		ENDIF
		 ;rename the file
		file = file + '.gz'
		 ;check that it worked
		file = findfile(file, count = check)
		IF check EQ 0 THEN BEGIN
			PRINT, 'Compression failed '

			return
		ENDIF
		ok = 1
		Print, 'file compressed'
	ENDIF

ENDIF ELSE BEGIN

	   ;uncompress the file if needed

	IF  gz_pos GT -1 OR  Z_pos GT -1 THEN BEGIN
		Print, 'preparing to uncompress ', file
		IF strupcase(!version.os) EQ 'WIN32' THEN BEGIN
			command = 'gzip -d '  + file
			spawn, command
		ENDIF
		IF strupcase(!version.os) EQ 'SUNOS' THEN BEGIN

			command = 'gunzip ' + file
			Spawn, command

		ENDIF

		l = strlen(file)   ;rename the file
		IF gz_pos GT - 1 THEN strip = 3 ELSE strip = 2
		file = strmid(file,0,l-strip)

		 ;check that it worked
		check = findfile(file)
		IF strlen(check) EQ 0 THEN BEGIN
			PRINT, 'Compression failed '
			ok = -1
			return
		ENDIF
		ok = 1
		Print, 'file uncompressed'
	ENDIF

ENDELSE


END

