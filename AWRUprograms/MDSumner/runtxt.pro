mean = mean42.mean
sd = mean42.oldsd

openw, lun, '1000042.csv', /get_lun
printf, lun, 10000, 'iterations', ',', 42, 'seals'
printf, lun, 'mean', ',', 'sd'
for n = 0, n_elements(mean) - 1 do begin
	printf, lun, mean(n), ',', sd(n)

endfor
free_lun, lun


mean = mean32.mean
sd = mean32.oldsd

openw, lun, '1000032.csv', /get_lun
printf, lun, 10000, 'iterations', ',', 32, 'seals'
printf, lun, 'mean', ',', 'sd'
for n = 0, n_elements(mean) - 1 do begin
	printf, lun, mean(n), ',', sd(n)

endfor
free_lun, lun

mean = mean22.mean
sd = mean22.oldsd

openw, lun, '1000022.csv', /get_lun
printf, lun, 10000, 'iterations', ',', 22, 'seals'
printf, lun, 'mean', ',', 'sd'
for n = 0, n_elements(mean) - 1 do begin
	printf, lun, mean(n), ',', sd(n)

endfor
free_lun, lun


mean = mean12.mean
sd = mean12.oldsd

openw, lun, '1000012.csv', /get_lun
printf, lun, 10000, 'iterations', ',', 12, 'seals'
printf, lun, 'mean', ',', 'sd'
for n = 0, n_elements(mean) - 1 do begin
	printf, lun, mean(n), ',', sd(n)

endfor
free_lun, lun



end
