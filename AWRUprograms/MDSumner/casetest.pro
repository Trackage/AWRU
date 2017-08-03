file = files(n)
	len = strlen(file)
	type = strmid(file, len-4, len)

	CASE type OF
		'.csv':  loc_data = gl2ptt(file)
		'.dat':  loc_data = pen_gos(file)
	ELSE:  MESSAGE, type + ' not a supported file type '
	ENDCASE

end