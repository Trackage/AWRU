restore, 'remaps.xdr'

info = size(remaps)
for n = 0, info(3) - 1 do begin

	imdisp, remaps(*, *, n)

endfor

end