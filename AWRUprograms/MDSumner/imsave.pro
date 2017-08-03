PRO IMSAVE, imfile = imfile

IF keyword_set(imfile) THEN jpgname = imfile ELSE BEGIN
	jpgname = 'image.jpg'
	print, 'Image ', jpgname, ' saved in \IDL52'
ENDELSE
image = tvrd(true = 3)
write_jpeg, jpgname, image, true = 3

END