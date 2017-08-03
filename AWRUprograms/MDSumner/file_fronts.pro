
tags = tag_names(fronts)

for n = 0, n_tags(fronts) -1 do begin


	openw, lun, tags(n) + '.txt', /get_lun
	printf, lun, 'lon',',','lat'
	for y = 0, n_elements(fronts.(n).lons) - 1 do begin
		printf, lun, fronts.(n).lons(y), ',', fronts.(n).lats(y)

	endfor

	free_lun, lun

endfor

end
