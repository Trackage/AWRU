pro showpres

restore, 'pres_cells.xdr'
stru = prcells

for n = 0, n_tags(stru) -1 do begin

	IF n EQ 0 THEN sum = stru.(n) ELSE sum = sum + stru.(n)

endfor

window, !d.window + 1
imdisp, sum

end