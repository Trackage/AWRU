pro hdf_sd_readslice, file_name, sds_name, img, $
	start=start, count=count, stride=stride
;
; given a seadas HDF file and data set name return an array of the data
; Usage:
; hdf_sd_readslice, file_name, sds_name, img,
;               start=start, count=count, stride=stride
;       file_name : seadas HDF file
;       sds_name  : hdf sd data set name
;       img       : returned 2-d array of data
; KEYWORDS:
;       start : an array of the start index in each dimension (0)
;       count : an array of the number of elements to read in each dim (0)
;               (use zero to get all)
;       stride : an array of the sampling interval in each dimension (1)
;

if ( n_params() ne 3 ) then begin
	print,'usage: hdf_sd_readslice, file_name, sds_name, img, '
	print,'		start=start, count=count, stride=stride'
	print,'KEYWORDS:'
	print,'	start : an array of the start index in each dimension (0)'
	print,'	count : an array of the number of elements to read in each dimension (0)'
	print,'		(use zero to get all)'
	print,'	stride : an array of the sampling interval in each dimension (1)'
	return
endif
on_error, 2

f=hdf_sd_start(file_name)
index=hdf_sd_nametoindex(f,sds_name)
if ( index lt 0 ) then begin
	print,'no such sds as ',sds_name,' in ', file_name
	hdf_sd_end,f
	return
endif
sds_id=hdf_sd_select(f, index)
hdf_sd_getinfo, sds_id, dims=dims, type=type, ndims=ndims
;print,sds_name, ' type=',type,'  dims=',dims
case type of
    'BYTE':	ntype=1
    'INT':	ntype=2
    'LONG':	ntype=3
    'FLOAT':	ntype=4
endcase

if ( n_elements(start) ne 0 ) then begin
    ps = size(start)
    if ( ps(0) ne 1 ) then message,'start keyword not 1-d array'
    if ( ps(1) ne ndims  ) then message, $
	'start keyword does not have '+strtrim(string(ndims),2)+' dims'+ $
	'but '+string(ps(0))
    ww = where( start ge dims , nww )
    if ( nww gt 0 ) then begin
	print,'start is beyond end, set to last element ', $
		string(form='(9i6)',start),string(form='(9i6)',dims-1)
	start(ww) = dims(ww)-1
    endif
endif else $
    start=replicate(0,ndims)

if ( n_elements(stride) ne 0 ) then begin
    ps = size(stride)
    if ( ps(0) ne 1 ) then begin
	hdf_sd_end,f
	message,'stride keyword not 1-d array'
    endif
    if ( ps(1) ne ndims  ) then begin
	hdf_sd_end,f
	message, $
	    'stride keyword does not have '+ $
		strtrim(string(ndims),2)+' dims'
    endif
    ww = where( stride le 0, nww )
    if ( nww gt 0 ) then stride(ww)=1
endif else $
    stride=replicate(1,ndims)

maxcount = (dims-start)/stride
if ( n_elements(count) ne 0 ) then begin
    ps = size(count)
    if ( ps(0) ne 1 ) then begin
	hdf_sd_end,f
	message,'count keyword not 1-d array'
    endif
    if ( ps(1) ne ndims  ) then begin
	hdf_sd_end,f
	message, $
	    'count keyword does not have '+strtrim(string(ndims),2)+' dims'
    endif
    ww = where( count le 0 or count gt maxcount , nww )
    if ( nww gt 0 ) then begin
	ocount = count
	count(ww) = maxcount(ww)
	print,'count out of range: ', string(form='(9i6)',ocount), $
	', set to max: ', string(form='(9i6)',count)
    endif
endif else $
    count=maxcount

;print,'making array with dims:',count
img = make_array(dimension=count,type=ntype)
hdf_sd_getdata,sds_id,img, start=start, count=count, stride=stride
hdf_sd_end,f
return
end
