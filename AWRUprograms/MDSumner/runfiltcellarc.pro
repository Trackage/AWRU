pro runfiltcellarc

locfile = 'sealgeo3.csv'
file_label = 'sum00'
field = 'time'
time0 = '20001016000000'
time1 = '20011231000000'
beasts_s9 = ['B362', 'B367', 'B568', 'B771', 'B889', 'B900', 'B927', 'C023', 'C041', 'C060', 'C162', 'C163', $
 'C790', 'C874', 'C899', 'C923', 'C933']
beasts_w0 = ['B533', 'B569', 'B889', 'B900', 'C064', 'C162', 'C217', 'C699', 'C790']
beasts_s0 = ['B362', 'B367', 'B568', 'B533', 'B889', 'B900', 'C217', 'C728', 'C790', 'C874', 'C899']
scale = [350.0, 350.0]
max_speed = 12.5
min_class = 3
limits = [-35.0, -85.0, 100.0, 230.0]

filtcellarc, locfile, filt_out, cells, time0=time0, time1=time1, beasts = beasts_s0, scale=scale, $
 max_speed=max_speed, min_class=min_class, limits=limits, /arc, labl = file_label

end
