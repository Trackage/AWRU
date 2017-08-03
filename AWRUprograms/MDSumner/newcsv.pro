


openw, lun, 'NEWc699-031001-0080463.csv', /get_lun
for n = 0L, n_elements(a) - 1 do begin

	bits = str_sep(a(n), '/')

	IF n_elements(bits) EQ	2 THEN printf, lun, a(n)

endfor
free_lun, lun
end

