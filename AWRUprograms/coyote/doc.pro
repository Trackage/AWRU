        filename = FILEPATH(SUBDIR=['examples','data'], 'worldelv.dat')
        image = BYTARR(360,360)
        OPENR, lun, filename, /GET_LUN
        READU, lun, image
        FREE_LUN, lun
	data = image
	x0 = 90
	x1 = 220
	y0 = 40
	y1 = 120
	image = image[x0:x1, y0:y1]
	erase
        thisPosition = [0.1, 0.1, 0.9, 0.9]
        TVSCALE, image, POSITION=thisPosition, /KEEP_ASPECT_RATIO
        CONTOUR, image, POSITION=thisPosition, /NOERASE, XSTYLE=1, $
            YSTYLE=1, levels = [0,  20 , 30,  40,  60, 80, 100, 120];$;, XRANGE=[x0,x1], YRANGE=[y0,y1]
	;NLEVELS=10
;

end