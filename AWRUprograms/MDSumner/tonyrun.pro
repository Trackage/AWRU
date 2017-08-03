 !p.multi = [0, 0, 0]
label = 'eguard'
beasts = ['1', '2', '3', '4', '5', '6', '8', '9', '10', '11', '12', '13', '14']

cell_track, beasts = beasts, /tony, /map_data, labl = labl, /trkonly

window, 1
labl = 'lguard'
beasts = ['15', '16',  '18', '19']

cell_track, beasts = beasts, /tony, /map_data, labl = labl, /trkonly

window, 2
labl = 'creche'
beasts = [ '20', '21', '22']

cell_track, beasts = beasts, /tony, /map_data, labl = labl, /trkonly
window, 3
labl = 'pmoult'
beasts = ['23']

cell_track, beasts = beasts, /tony, /map_data, labl = labl, /trkonly

pengs = ['1', '2', '3', '4', '5', '6', '8', '9', '10', '11', '12', '13', '14', $
	'15', '16',  '18', '19', '20', '21', '22', '23']
for n = 0, n_elements(pengs) - 1 do begin
	cell_track, beasts = pengs(n), /tony, labl = pengs(n), /trkonly

endfor
end