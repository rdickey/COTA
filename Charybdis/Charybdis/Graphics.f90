Subroutine GlobalPlotting
    use CharybdisGlobals
    implicit doubleprecision (a-h,l-z)
    
    CHARACTER(1000) StringLoader
    INTEGER(HANDLE) hOldfont
    REAL(4) :: data_material(4)
    
    iret = GetClientRect(ghWindow,rcClient)
    
    cxWidth  = rcClient%right
    cyHeight = rcClient%bottom
    
    bret = fwglMakeCurrent(ghdcVisual,ghrcVisual)
    
    call fglMatrixMode(GL_PROJECTION)
    call fglLoadIdentity() 
    call fglShadeModel(GL_SMOOTH)
    call fglOrtho(0,DBLE(cxWidth),0,DBLE(cyHeight),-50000,50000)
    call fglViewport(0,0,INT(cxWidth),INT(cyHeight))
    call fglflush()
    
    call fglClearColor(0.0,0.0,0.0,1.0)
    call fglClear(IOR(GL_COLOR_BUFFER_BIT,GL_DEPTH_BUFFER_BIT))
    
    call fglLightfv(GL_LIGHT0,GL_AMBIENT  ,LOC(SceneGraph%Intensity_Ambient))
    call fglLightfv(GL_LIGHT0,GL_SPECULAR ,LOC(SceneGraph%Intensity_Specular))
    call fglLightfv(GL_LIGHT0,GL_POSITION ,LOC(SceneGraph%Position_Specular))
    
    call fglEnable(GL_DEPTH_TEST)
    call fglDepthFunc(GL_LESS)
    
    call fglPolygonOffset(1,1)
    call fglEnable(GL_POLYGON_OFFSET_FILL)
    
    !******************** CHARYBDIS LOGO  **********************
    if (SceneGraph%Show_Logo == .TRUE.) then
        call fglColor3f(1.0,1.0,1.0)
        call fglListBase(2000)
        call fglRasterPos3i(INT(rcClient%right - 290),INT(rcClient%Bottom - 50),-40000)
        StringLoader = "CHARYBDIS"
        call fglCallLists(LEN_TRIM(StringLoader),GL_UNSIGNED_BYTE,LOC(StringLoader))
    endif
    
    !******************** GRAPHICAL SCALER  *********************
    call fglLineWidth(1.0)
    call fglColor3f(0.0,1.0,0.0)
    call fglBegin(GL_LINES)
        call fglVertex3f(10,20,40000)
        call fglVertex3f(10,10,40000)
        call fglVertex3f(10,10,40000)
        call fglVertex3f(REAL(10 + 1.0d0*gscalex),10,40000)
        call fglVertex3f(REAL(10 + 1.0d0*gscalex),10,40000)
        call fglVertex3f(REAL(10 + 1.0d0*gscalex),20,40000)
    call fglEnd()
    
    call fglColor3f(0.0,1.0,0.0)
    call fglListBase(1000)
    call fglRasterPos3i(INT(5 + 1.0d0*gscalex),25,40000)
    StringLoader = "1.0 meters"
    call fglCallLists(LEN_TRIM(StringLoader),GL_UNSIGNED_BYTE,LOC(StringLoader))
    
    !********************** MOTION DATA ************************
    call fglRasterPos3i(5,INT(rcClient%bottom - 50),40000)
    write(StringLoader,'("Base angular rate (Deg/sec): ",F15.5)') Motion%omega*180.0d0/pi 
    call fglCallLists(LEN_TRIM(StringLoader),GL_UNSIGNED_BYTE,LOC(StringLoader))
    call fglRasterPos3i(5,INT(rcClient%bottom - 70),40000)
    write(StringLoader,'("Simulation time (min): ",F15.5)') Motion%time/60.0d0 
    call fglCallLists(LEN_TRIM(StringLoader),GL_UNSIGNED_BYTE,LOC(StringLoader))
    call fglRasterPos3i(5,INT(rcClient%bottom - 90),40000)
    write(StringLoader,'("Control time (min): ",F15.5)') Motion%stop_time/60.0d0 
    call fglCallLists(LEN_TRIM(StringLoader),GL_UNSIGNED_BYTE,LOC(StringLoader))
    
    !******************** CG RASTER  *********************
    call fglEnable(GL_LIGHTING)
    call fglEnable(GL_LIGHT0)
    data_material = [1.0,0.0,1.0,0.5]
    call fglMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,LOC(data_material))
    x0 = MeshGlobal%Xcg 
    y0 = MeshGlobal%Ycg 
    z0 = MeshGlobal%Zcg 	    
    ballradius = 5/gscalex
    call GetBallModel(ballradius,x0,y0,z0)
    call fglDisable(GL_LIGHTING)
    
    !********************** AXES RASTER ************************
    call fglTranslatef(REAL(GlobalOriginX),REAL(GlobalOriginY),0)
    call fglRotatef(REAL(grotx),1.0,0.0,0.0)
    call fglRotatef(REAL(groty),0.0,1.0,0.0)
    call fglRotatef(REAL(grotz),0.0,0.0,1.0)
    
    if (SceneGraph%Show_Axes == .TRUE.) then
        call fglColor3f(0.0,1.0,0.0)
        call fglBegin(GL_LINES)
            call fglVertex3f(REAL(x0 - Vehicle%Tether*gscalex),REAL(y0),REAL(z0))
            call fglVertex3f(REAL(x0 + Vehicle%Tether*gscalex),REAL(y0),REAL(z0))
            call fglVertex3f(REAL(x0),REAL(y0 - Vehicle%Tether*gscalex),REAL(z0))
            call fglVertex3f(REAL(x0),REAL(y0 + Vehicle%Tether*gscalex),REAL(z0))
            call fglVertex3f(REAL(x0),REAL(y0),REAL(z0 - Vehicle%Tether*gscalex))
            call fglVertex3f(REAL(x0),REAL(y0),REAL(z0 + Vehicle%Tether*gscalex))
        call fglEnd()
    endif
    
    !********************** GEOMETRY RASTER LIST *********************************************
    call fglScalef(REAL(gscalex),REAL(gscalex),REAL(gscalex))
    
    call fglCallList(INT(OBJECT_DL))
    
    call fglflush()
    bret = swapbuffers(ghdcVisual)
end
        
subroutine Raster_List_Generator
    use CharybdisGlobals
    implicit doubleprecision (a-h,l-z)
    
    REAL(4) :: data_material(4)
    
    bret = fwglMakeCurrent(ghdcVisual,ghrcVisual)
    call fglNewList(INT(OBJECT_DL),GL_COMPILE)
    
    !***********************************************************
    !****************** GEOMETRY RASTER ************************
    !***********************************************************
    call fglEnable(GL_LIGHTING)
    call fglPolygonMode(GL_FRONT_AND_BACK,GL_FILL)
    call fglEnable(GL_LIGHT0)   
    data_material = [0.727,0.727,0.727,0.2]
    call fglMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE,LOC(data_material))
        
    do i = 1,MeshGlobal%Faces
        gxd = meshData(i)%nx
        gyd = meshData(i)%ny
	    gzd = meshData(i)%nz
        call fglNormal3f(REAL(gxd),REAL(gyd),REAL(gzd)) 
        call fglBegin(GL_TRIANGLES)
            call fglVertex3f(REAL(meshX(1,i)),REAL(meshY(1,i)),REAL(meshZ(1,i)))
            call fglVertex3f(REAL(meshX(2,i)),REAL(meshY(2,i)),REAL(meshZ(2,i)))
            call fglVertex3f(REAL(meshX(3,i)),REAL(meshY(3,i)),REAL(meshZ(3,i)))
        call fglEnd()
    enddo
    
    call fglDisable(GL_LIGHTING)
    call fglEndList()
end
    
subroutine GetBallModel(radius,x0,y0,z0)
    use CharybdisGlobals
    implicit doubleprecision (a-h,l-z)
    
    DOUBLEPRECISION :: radius,x0,y0,z0
    
    do i = 1,GraphSphere%Faces
        call fglBegin(GL_QUADS)
            xd  = GraphSphere%Vertex(GraphSphere%Face(i)%vertex1)%X*radius
            yd  = GraphSphere%Vertex(GraphSphere%Face(i)%vertex1)%Y*radius
            zd  = GraphSphere%Vertex(GraphSphere%Face(i)%vertex1)%Z*radius
            gxd = GraphSphere%nx(GraphSphere%Face(i)%vertex1)
	        gyd = GraphSphere%ny(GraphSphere%Face(i)%vertex1)
	        gzd = GraphSphere%nz(GraphSphere%Face(i)%vertex1)
            call Rotator3D
            call fglNormal3f(REAL(gxd),REAL(gyd),REAL(gzd)) 
            call fglVertex3f(REAL(xd+x0),REAL(yd+y0),REAL(zd+z0))
            xd  = GraphSphere%Vertex(GraphSphere%Face(i)%vertex2)%X*radius
            yd  = GraphSphere%Vertex(GraphSphere%Face(i)%vertex2)%Y*radius
            zd  = GraphSphere%Vertex(GraphSphere%Face(i)%vertex2)%Z*radius
            gxd = GraphSphere%nx(GraphSphere%Face(i)%vertex2)
	        gyd = GraphSphere%ny(GraphSphere%Face(i)%vertex2)
	        gzd = GraphSphere%nz(GraphSphere%Face(i)%vertex2)
            call Rotator3D
            call fglNormal3f(REAL(gxd),REAL(gyd),REAL(gzd)) 
            call fglVertex3f(REAL(xd+x0),REAL(yd+y0),REAL(zd+z0))
            xd  = GraphSphere%Vertex(GraphSphere%Face(i)%vertex3)%X*radius
            yd  = GraphSphere%Vertex(GraphSphere%Face(i)%vertex3)%Y*radius
            zd  = GraphSphere%Vertex(GraphSphere%Face(i)%vertex3)%Z*radius
            gxd = GraphSphere%nx(GraphSphere%Face(i)%vertex3)
	        gyd = GraphSphere%ny(GraphSphere%Face(i)%vertex3)
	        gzd = GraphSphere%nz(GraphSphere%Face(i)%vertex3)
            call Rotator3D
            call fglNormal3f(REAL(gxd),REAL(gyd),REAL(gzd)) 
            call fglVertex3f(REAL(xd+x0),REAL(yd+y0),REAL(zd+z0))
            xd  = GraphSphere%Vertex(GraphSphere%Face(i)%vertex4)%X*radius
            yd  = GraphSphere%Vertex(GraphSphere%Face(i)%vertex4)%Y*radius
            zd  = GraphSphere%Vertex(GraphSphere%Face(i)%vertex4)%Z*radius
            gxd = GraphSphere%nx(GraphSphere%Face(i)%vertex4)
	        gyd = GraphSphere%ny(GraphSphere%Face(i)%vertex4)
	        gzd = GraphSphere%nz(GraphSphere%Face(i)%vertex4)
            call Rotator3D
            call fglNormal3f(REAL(gxd),REAL(gyd),REAL(gzd)) 
            call fglVertex3f(REAL(xd+x0),REAL(yd+y0),REAL(zd+z0))
        call fglEnd()
    enddo
end
    
subroutine Rotator3D
	use CharybdisGlobals
    implicit doubleprecision (a-h,l-z)
	
	angrotx = grotx*pi/180.0d0
	angroty = groty*pi/180.0d0
	angrotz = grotz*pi/180.0d0

	xd = gxd
	yd = gyd
	zd = gzd
	
	xdy = xd*dcos(angroty) - zd*dsin(angroty) 
	ydy = yd 
	zdy = xd*dsin(angroty) + zd*dcos(angroty) 
	
	xdz = xdy*dcos(angrotz) - ydy*dsin(angrotz) 
	ydz = xdy*dsin(angrotz) + ydy*dcos(angrotz) 
	zdz = zdy
	
	gxd = xdz
	gyd = ydz*dcos(angrotx) - zdz*dsin(angrotx) 
	gzd = ydz*dsin(angrotx) + zdz*dcos(angrotx)
	!*********************************************************************************
end

    