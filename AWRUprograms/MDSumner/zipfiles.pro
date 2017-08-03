PRO zipfiles, files

for n = 0, n_elements(files) -1 do begin

	command = 'gzip -f ' + files(n)
	spawn, command
endfor

end

