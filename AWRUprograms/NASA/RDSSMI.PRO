pro rdssmi, filnam, uu, vv, ss, uus, vvs, nn, lon, lat, day90, yyyymmdd
;
; IDL routine to read SSM/I 0.5 degree grids in WOCE SAT cd-roms
;
; INPUT
;       filnam: (string) with file name of data file
;		'SSMI0001.DAT'
; OUTPUT
;   uu:   (bytarr(720,360)), east component data array in m/s
;   vv:   (bytarr(720,360)), north component data array in m/s
;   ss:   (bytarr(720,360)), wind speed data array in m/s
;   uus:  (intarr(720,360)), east pseudostress data array in (m/s)^2
;   vvs:  (intarr(720,360)), north pseudostress data array in (m/s)^2
;   nn:   (bytarr(720,360)), number of points averaged in each bin
;   lon:   (fltarr(720)), longitude in degrees, 0-360
;   lat:   (fltarr(360)), latitude in degrees, -90 to 90.
;   uu(i,j) is at lon(i), lat(j)
;   day90: (long) days since 1/1/90 + 1
;   yyyymmdd: (long) year*1e4 + month*1e2 + day_of_month
;
; MACHINE DEPENDENCIES
;   the line that contains 'swap_endian' should only execute for
;   Windows 3.1/95/NT or DEC machines. Comment out otherwise.
;
; V. Zlotnicki, 19980420.
; Copyright 1998, California Institute of Technology
;----------------------------------------------------------------
i1= strpos(filnam,'.dat')-4        ; '/dir1/dir2/dir3/sst0566.dat'
day90 = long(strmid(filnam,i1,4))  ; 0566
caldat, (day90-1+julday(1,1,1990)), mm,dd,yy
yyyymmdd = dd + 100L*mm + 10000L*yy
;
ni=720 & nj=360
dum1360 = bytarr(1360)
uubyt   = bytarr (ni,nj)
vvbyt   = bytarr (ni,nj)
ssbyt   = bytarr (ni,nj)
uusint  = intarr (ni,nj)
vvsint  = intarr (ni,nj)
nn      = bytarr (ni,nj)
;
uu      = fltarr (ni,nj)
vv      = fltarr (ni,nj)
ss      = fltarr (ni,nj)
uus     = fltarr (ni,nj)
vvs     = fltarr (ni,nj)
;
openr,1,filnam
readu,1,dum1360
readu,1,uubyt
readu,1,vvbyt
readu,1,ssbyt
readu,1,uusint
readu,1,vvsint
readu,1,nn
close,1
;
;uusint = swap_endian(uusint) ; uncomment for MS Windows or DEC
;vvsint = swap_endian(vvsint) ; uncomment for MS Windows or DEC
;
uu=uubyt/4.0-30.0
vv=vvbyt/4.0-30.0
ss=ssbyt/8.0
uus=float(uusint)*abs(uusint)/10000.
vvs=float(vvsint)*abs(vvsint)/10000.
land=where(uubyt eq 254)
miss=where(uubyt eq 255)
if (n_elements(land) gt 0) then begin
  uu(land)=32766.
  vv(land)=32766.
  ss(land)=32766.
  uus(land)=32766.
  vvs(land)=32766.
endif
if (n_elements(miss) gt 0) then begin
  uu(miss)=32767.
  vv(miss)=32767.
  ss(miss)=32767.
  uus(miss)=32767.
  vvs(miss)=32767.
endif
;
lon=findgen(ni)*0.5 +  0.25
lat=findgen(nj)*0.5 - 89.75
;
return
end
;
pro driver
; Test program for rdssmi. Check output against 'rdssmi.out'
;
filnam='../data/ssmi1006.dat'
rdssmi, filnam, uu, vv, ss, uus, vvs, nn, lon, lat, day90, yyyymmdd
;
i1=340 & i2=345 & j1=160 & j2=161
print, 'i=',i1, i2, '; j=',j1,j2, ' ', filnam
for j=j1-1, j2-1 do begin
  for i=i1-1, i2-1 do begin
    print, ' '
    print, yyyymmdd, day90, lat(j), lon(i)
    print, uu(i,j), vv(i,j), ss(i,j)
    print, uus(i,j), vvs(i,j), nn(i,j)
  endfor
endfor
return
end
