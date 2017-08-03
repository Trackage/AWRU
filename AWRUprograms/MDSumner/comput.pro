
b = strarr(n_elements(a))
for n= 0L, 752908 - 1 do begin


	line = a(n)
	strput, line, ',', 5
	strput, line, ',', 14
	strput, line, ',', 16
	strput, line, ',', 20
	strput, line, ',', 26
	b(n) = line
	undefine, line

endfor

end