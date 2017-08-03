PRO median_ssh, file, area

   ;extract the area of interest

ssa_ext, file, area
print, max(area)
print, min(area)

   ;find no data and land areas

nan = where(area EQ 32767)
land = where(area EQ 32766)
help, nan, land

   ;create a fl. pt. copy of the area, nan out the no data areas, find size of area
   ;and find the nan values

area_copy = area*1.0
help, area, area_copy
area_copy(nan) = !values.f_nan
info = size(area)
check = nan
help, check
good = size(check)
print, good

   ;while there are areas of no data that are not land, locally median filter the image

WHILE good(0) GT 0 DO BEGIN

	for i = 2, info(1) - 3 DO BEGIN
		for j = 2, info(2) -3 DO BEGIN

			IF area_copy(i, j) EQ !values.f_nan THEN BEGIN
		
				   ;take the surrounding pixels (5,5) and find the median
				   ;of these that are not land

				tot = area_copy(i-2:i+2, j-2:j+2)
				land_pix = where(tot EQ 32766, count)
				tot(land_pix) = !values.f_nan

				   ;assign the filter value to the copy

				area_copy(i, j) = median(tot) 
	
			ENDIF 
		ENDFOR
	ENDFOR
	print, tot
	check = where(area_copy EQ !values.f_nan)
	help, check
	good = size (check)
	print, good
ENDWHILE
area = area_copy
area(land) = !values.f_nan
END
					