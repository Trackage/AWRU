
openw, lun, 'oks', /get_lun
for sn = 0, n_elements(output_data.ok) -1 do begin
	printf, lun, output_data.ok(sn)

endfor
free_lun, lun

end