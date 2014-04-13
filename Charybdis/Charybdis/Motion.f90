subroutine SetMotion
    !DEC$ IF DEFINED(_X64_)
	!DEC$ ATTRIBUTES STDCALL, ALIAS : '_SetMotion@16' :: SetMotion
	!DEC$ ELSE
	!DEC$ ATTRIBUTES STDCALL, ALIAS : 'SetMotion' :: SetMotion
	!DEC$ ENDIF
    use CharybdisGlobals
	implicit doubleprecision (a-h,l-z)
    
    include 'resource.fd'
    
    Motion%time  = 0.0d0
    Motion%dt    = 0.1d0
    Motion%A1    = 0.0d0
    Motion%A2    = 0.0d0
    
    acceleration = (Vehicle%Thrust/(Asteriod%Inertia + Vehicle%mass*(Vehicle%Tether**2.0d0)))
    
    Motion%Stop_time = Motion%omega/acceleration
    
    krun = INT(Motion%Stop_time/Motion%dt)
    
    do k = 1,0 !krun
        
        rotation = Motion%omega*(1.0d0 + Motion%A1*dsin(Motion%omega*Motion%time))*Motion%dt
        if (rotation >= 2.0d0*pi) rotation = rotation - 2.0d0*pi
        
        do i = 1,MeshGlobal%Asteriod_Faces
            do j = 1,3
                gxd = meshX(j,i)
                gyd = meshY(j,i)
                gzd = meshZ(j,i)
                call Rotator3D_Vector(rotation)
                meshX(j,i) = gxd
                meshY(j,i) = gyd
                meshZ(j,i) = gzd
            enddo       
        enddo
        iret = SendMessage(ghWindow,WM_COMMAND,MAKEWPARAM(IDM_UPDATE_SCENE,0),0)
        
        Motion%angle = rotation
        Motion%time  = Motion%time + Motion%dt
        Motion%Omega = Motion%Omega - acceleration*Motion%dt
        
        if (gAbort == 1) then
            gAbort = 0
            exit
        endif
    enddo
    
    iret = CloseHandle(ghThread)
    ghThread = 0
end
    
subroutine Rotator3D_Vector(rotation)
	use CharybdisGlobals
    implicit doubleprecision (a-h,l-z)
    
    DOUBLEPRECISION :: rotation
	
    x0 = MeshGlobal%Xcg 
    y0 = MeshGlobal%Ycg 
    z0 = MeshGlobal%Zcg 
    
    nx = 0.0d0
    ny = 0.0d0
    nz = 1.0d0
    
    x1 = x0 + nx
    y1 = y0 + ny
    z1 = z0 + nz
    
	x2 = gxd - x0
	y2 = gyd - y0
	z2 = gzd - z0
    
    length = dsqrt(x2**2.0d0 + y2**2.0d0 + z2**2.0d0)
    if (length > 0.0d0) then
        nx1 = x2/length
        ny1 = y2/length
	    nz1 = z2/length
        
        dotproduct = (nx*nx1 + ny*ny1 + nz*nz1)
        if (dotproduct >  1.0d0) dotproduct =  1.0d0
        if (dotproduct < -1.0d0) dotproduct = -1.0d0
        theta = dacos(dotproduct)
        
        rad = dabs(length*dsin(theta))
        if (rad > 0.0d0) then
            nzx =  ny*nz1 - nz*ny1
            nzy = -nx*nz1 + nz*nx1
            nzz =  nx*ny1 - ny*nx1
            ntot = dsqrt(nzx**2.0d0 + nzy**2.0d0 + nzz**2.0d0)
            nzx = -nzx/ntot
            nzy = -nzy/ntot
            nzz = -nzz/ntot
        
            nyx =  ny*nzz - nz*nzy
            nyy = -nx*nzz + nz*nzx
            nyz =  nx*nzy - ny*nzx
            ntot = dsqrt(nyx**2.0d0 + nyy**2.0d0 + nyz**2.0d0)
            nyx = nyx/ntot
            nyy = nyy/ntot
            nyz = nyz/ntot
        
            xval = length*dcos(theta)
            yval = rad*dcos(rotation)
            zval = rad*dsin(rotation)
        
            gxd = xval*nx + yval*nyx + zval*nzx + x0
            gyd = xval*ny + yval*nyy + zval*nzy + y0
            gzd = xval*nz + yval*nyz + zval*nzz + z0
        endif
    endif
	!*********************************************************************************
end