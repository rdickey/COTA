subroutine GetNEA
    use CharybdisGlobals
	implicit doubleprecision (a-h,l-z)
        
    character(100) FileBuf,Title
	doubleprecision, ALLOCATABLE :: ArrayTemp(:,:)
    
    ALLOCATE(ArrayTemp(10,150000))
    
    open(28,FILE='NEA.stl',ERR=190)
        read(28,'(A)',END=191,ERR=190) FileBuf
        Title = FileBuf(7:100)
        do i=1,2000000
            read(28,*,END=191,ERR=190) FileBuf,FileBuf,FileBuf,FileBuf,FileBuf
            read(28,*,END=191,ERR=190) FileBuf,FileBuf
            read(28,*,END=191,ERR=190) FileBuf,ArrayTemp(1,i),ArrayTemp(2,i),ArrayTemp(3,i)
            read(28,*,END=191,ERR=190) FileBuf,ArrayTemp(4,i),ArrayTemp(5,i),ArrayTemp(6,i)
            read(28,*,END=191,ERR=190) FileBuf,ArrayTemp(7,i),ArrayTemp(8,i),ArrayTemp(9,i)
            read(28,*,END=191,ERR=190) FileBuf
            read(28,*,END=191,ERR=190) FileBuf
        enddo
191     itot = i-1
    close(28)
    
    if (itot /= 0) then
        do i = 1,itot
            meshX(1,i) = ArrayTemp(1,i)*gconvfactor
            meshY(1,i) = ArrayTemp(2,i)*gconvfactor
            meshZ(1,i) = ArrayTemp(3,i)*gconvfactor
            meshX(2,i) = ArrayTemp(4,i)*gconvfactor
            meshY(2,i) = ArrayTemp(5,i)*gconvfactor
            meshZ(2,i) = ArrayTemp(6,i)*gconvfactor
            meshX(3,i) = ArrayTemp(7,i)*gconvfactor
            meshY(3,i) = ArrayTemp(8,i)*gconvfactor
            meshZ(3,i) = ArrayTemp(9,i)*gconvfactor
        enddo
    endif
    
    MeshGlobal%faces = itot
    MeshGlobal%Asteriod_Faces = itot
    
    DEALLOCATE(ArrayTemp)
    
190 continue
    !*********************************************************
end
    
subroutine GetSpaceShip
    use CharybdisGlobals
	implicit doubleprecision (a-h,l-z)
        
    character(100) FileBuf,Title
	doubleprecision, ALLOCATABLE :: ArrayTemp(:,:)
    
    ALLOCATE(ArrayTemp(10,150000))
    
    open(28,FILE='SpaceShip.stl',ERR=190)
        read(28,'(A)',END=191,ERR=190) FileBuf
        Title = FileBuf(7:100)
        do i=1,2000000
            read(28,*,END=191,ERR=190) FileBuf,FileBuf,FileBuf,FileBuf,FileBuf
            read(28,*,END=191,ERR=190) FileBuf,FileBuf
            read(28,*,END=191,ERR=190) FileBuf,ArrayTemp(1,i),ArrayTemp(2,i),ArrayTemp(3,i)
            read(28,*,END=191,ERR=190) FileBuf,ArrayTemp(4,i),ArrayTemp(5,i),ArrayTemp(6,i)
            read(28,*,END=191,ERR=190) FileBuf,ArrayTemp(7,i),ArrayTemp(8,i),ArrayTemp(9,i)
            read(28,*,END=191,ERR=190) FileBuf
            read(28,*,END=191,ERR=190) FileBuf
        enddo
191     itot = i-1
    close(28)
    
    ii = 1
    if (itot /= 0) then
        do i = MeshGlobal%faces+1,MeshGlobal%faces+itot
            meshX(1,i) = ArrayTemp(1,ii)*gconvfactor + 20.0d0
            meshY(1,i) = ArrayTemp(2,ii)*gconvfactor
            meshZ(1,i) = ArrayTemp(3,ii)*gconvfactor
            meshX(2,i) = ArrayTemp(4,ii)*gconvfactor + 20.0d0
            meshY(2,i) = ArrayTemp(5,ii)*gconvfactor
            meshZ(2,i) = ArrayTemp(6,ii)*gconvfactor
            meshX(3,i) = ArrayTemp(7,ii)*gconvfactor + 20.0d0
            meshY(3,i) = ArrayTemp(8,ii)*gconvfactor
            meshZ(3,i) = ArrayTemp(9,ii)*gconvfactor
            ii = ii + 1
        enddo
    endif
    
    MeshGlobal%faces = MeshGlobal%faces + itot
    
    DEALLOCATE(ArrayTemp)
    
190 continue
    !*********************************************************
end
    
subroutine UnstructDataGen
	use CharybdisGlobals
    implicit doubleprecision (a-h,l-z)
    
    do i = 1,MeshGlobal%faces
        x1 = MeshX(1,i)
		y1 = MeshY(1,i)
		z1 = MeshZ(1,i)
		x2 = MeshX(2,i)
		y2 = MeshY(2,i)
		z2 = MeshZ(2,i)
		x3 = MeshX(3,i)
		y3 = MeshY(3,i)
		z3 = MeshZ(3,i)
        
        len12 = dsqrt((x1-x2)**2.0d0 + (y1-y2)**2.0d0 + (z1-z2)**2.0d0)
		len23 = dsqrt((x2-x3)**2.0d0 + (y2-y3)**2.0d0 + (z2-z3)**2.0d0)
		len31 = dsqrt((x3-x1)**2.0d0 + (y3-y1)**2.0d0 + (z3-z1)**2.0d0)
			
		slen = 0.5d0*(len12 + len23 + len31)
		Apan = dsqrt(slen*(slen-len12)*(slen-len23)*(slen-len31)) 
        
        maxlen = len12
        if (len23 >= maxlen) maxlen = len23
        if (len31 >= maxlen) maxlen = len31
    
        minlen = len12
        if (len23 <= minlen) minlen = len23
        if (len31 <= minlen) minlen = len31
                    
        if (maxlen == len12) jMax = 1
        if (maxlen == len23) jMax = 2
        if (maxlen == len31) jMax = 3
        
        if (minlen == len12) jMin = 1
        if (minlen == len23) jMin = 2
        if (minlen == len31) jMin = 3
					
		if (Apan > gPrecision_Minimum) then
		    DCnx  =  (y1-y2)*(z1-z3) - (y1-y3)*(z1-z2)
			DCny  = -(x1-x2)*(z1-z3) + (x1-x3)*(z1-z2)
			DCnz  =  (x1-x2)*(y1-y3) - (x1-x3)*(y1-y2)
			DCtot =  dsqrt(DCnx**2.0d0 + DCny**2.0d0 + DCnz**2.0d0)
            
            radius_circumscribed = 0.25d0*len12*len23*len31/Apan
            radius_inscribed     = dsqrt((slen-len12)*(slen-len23)*(slen-len31)/slen)
            Quality_ratio = radius_circumscribed/radius_inscribed
			
			meshData(i)%Xcg  = (x1 + x2 + x3)/3.0d0
		    meshData(i)%Ycg  = (y1 + y2 + y3)/3.0d0
		    meshData(i)%Zcg  = (z1 + z2 + z3)/3.0d0
		    meshData(i)%nx   = DCnx/DCtot 
		    meshData(i)%ny   = DCny/DCtot 
		    meshData(i)%nz   = DCnz/DCtot 
		    meshData(i)%Area = Apan
	    else
	        meshData(i)%Area = 0.0d0
        endif
    enddo
end
      
subroutine GetCGlocation
	use CharybdisGlobals
    implicit doubleprecision (a-h,l-z)
    
    xcg = 0.0d0 
    ycg = 0.0d0 
    zcg = 0.0d0 
    areatot = 0.0d0
    
    do i = 1,MeshGlobal%Faces
        xcg = xcg + meshData(i)%Xcg*meshData(i)%Area
        ycg = ycg + meshData(i)%Ycg*meshData(i)%Area
        zcg = zcg + meshData(i)%Zcg*meshData(i)%Area
        
        areatot = areatot + meshData(i)%Area
    enddo
    
    MeshGlobal%Xcg = xcg/areatot
    MeshGlobal%Ycg = ycg/areatot
    MeshGlobal%Zcg = zcg/areatot
end