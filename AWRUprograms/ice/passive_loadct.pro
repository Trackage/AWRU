function passive_loadct, temperature=temperature, $
		 concentration=concentration, bottom=bottom, table=table

if (n_elements(table) eq 0) then table = 1
if (n_elements(bottom) eq 0) then bottom = 0

if (keyword_set(concentration)) then begin
	case table of
	   1:	dfile = 'passive_colours_ic_nasa.dat'
	   2:	dfile = 'passive_colours_ic_grumbine.dat'
	endcase
	file = filepath (dfile, subdir='lib/local/passive')
endif else begin
	file = filepath ('passive_colours_bt.dat', subdir='lib/local/passive')
endelse

load_data, file, data, col=3

tvlct, data[0,*], data[1,*], data[2,*], bottom

return, n_elements(data[0,*])
end
