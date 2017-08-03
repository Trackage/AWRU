PRO sat_time, folder

files = findfile(folder + '\*.*')
nfiles =  n_elements(files)
start = strlen(folder) + 1

for n = 0,nfiles -1 do begin
	fl = files(n)

	finish = strpos(fl,'.')
	diff = strlen(fl) - finish
	yearmth1 = strcompress(strmid(fl, start + 2,diff ), /remove_all);*1L
	;yearmth0 = string(yearmth1 - 7)


endfor
print, yearmth1*1L
help, yearmth1
; print, yearmth0
END