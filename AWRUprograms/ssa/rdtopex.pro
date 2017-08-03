pro rdtopex, filnam, ssh, count, lon, lat, day90, yyyymmdd
;
; IDL routine to read topex 0.5 degree grids in WOCE SAT cd-roms
;
; INPUT
;	filnam: (string) with file name of data file
; OUTPUT
;   ssh:   (intarr(720,360)), with sea level in mm
;   count: (bytarr(720,360)), number of points averaged in each bin
;   lon:   (fltarr(720)), longitude in degrees, 0-360
;   lat:   (fltarr(360)), latitude in degrees, -90 to 90.
;   ssh(i,j) is at lon(i), lat(j)
;   day90: (long) days since 1/1/90 + 1
;   yyyymmdd: (long) year*1e4 + month*1e2 + day_of_month
;
; MACHINE DEPENDENCIES
;   the line that contains 'swap_endian' should only execute for
;   Windows 3.1/95/NT or DEC machines. Comment out otherwise.
;
; V. Zlotnicki, 19980120.
; Copyright 1998, California Institute of Technology
;----------------------------------------------------------------
i1= strpos(filnam,'.dat')-4        ; '/dir1/dir2/dir3/ssh0566.dat'
day90 = long(strmid(filnam,i1,4))  ; 0566
caldat, (day90-1+julday(1,1,1990)), mm,dd,yy
yyyymmdd = dd + 100L*mm + 10000L*yy
;
ni=720 & nj=360
dum800 = bytarr(800)
ssh    = intarr (ni,nj)
count  = bytarr (ni,nj)
;
openr,1,filnam
readu,1,dum800
readu,1,ssh
readu,1,count
close,1
;
;ssh = swap_endian(ssh) ; uncomment for MS Windows or DEC
;
lon=findgen(ni)*0.5 +  0.25
lat=findgen(nj)*0.5 - 89.75
;
return
end
;-------------------------------------------------------------
pro driver
; Test program for rdtopex. Check output against 'rdtopex.out'
;
filnam='../data/ssh1006.dat'
rdtopex, filnam, ssh, count, lon, lat, day90, yyyymmdd
;
i1=340 & i2=345 & j1=160 & j2=161
print, 'i=',i1, i2, '; j=',j1,j2, ' ', filnam
for j=j1-1, j2-1 do begin
  for i=i1-1, i2-1 do begin
    print, yyyymmdd, day90, lat(j), lon(i), ssh(i,j), count(i,j)
  endfor
endfor
return
end