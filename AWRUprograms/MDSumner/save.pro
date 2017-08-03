
	restore, 'filtdrift.xdr'
	restore, 'cellsdrift.xdr'
restore, 'propos'
restore, 'proneg'
restore,'propos_t'

cells.map_bins = propos

cell_out, filt_out, cells, to_file = 'propos.txt', title = 'propos'
cells.map_bins = proneg
cell_out, filt_out, cells, to_file = 'proneg.txt', title = 'proneg'
cells.map_bins = propos_t
cell_out, filt_out, cells, to_file = 'propos_t.txt', title = 'propos_t'


end