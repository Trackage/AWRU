PRO test
x = Replicate(5., 10)
      x1 = cos(findgen(36)*10.*!dtor)*2.+5.
       x=[x,x1,x]
       y = findgen(56)
       z = Replicate(5., 10)
       z1 =sin(findgen(36)*10.*!dtor)*2.+5.
       z=[z,z1,z]

;     ; Plot this data in a "plot box"

       Plot_3dbox, X, Y, Z, /XY_PLANE, /YZ_PLANE, /XZ_PLANE, $
                 /SOLID_WALLS, GRIDSTYLE=1, XYSTYLE=3, XZSTYLE=4, $
                 YZSTYLE=5, AZ=40, TITLE="Example Plot Box",      $
                 Xtitle="X Coodinate", Ytitle="Y Coodinate",      $
                 Ztitle="Z Coodinate", SubTitle="Sub Title",      $
                 /YSTYLE, ZRANGE=[0,10], XRANGE=[0,10],Charsize=1.6

;     ; Then to plot symbols on the locations of the above plot
;
       plots, X, Y, Z, /T3D, PSYM=4, COLOR=!p.background
;
end