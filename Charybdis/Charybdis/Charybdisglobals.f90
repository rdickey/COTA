!****************************************************************************
!  Global data, parameters, and structures 
!****************************************************************************
module CharybdisGlobals
    use GDI32
	use ifwinty
    use ifwin
    use ifwbase
    use user32
	use comctl32
	use comdlg32
    use dfopngl
    use omp_lib
    use kernel32
    use DFWIN
    
    implicit doubleprecision(a-h,l-z)
    
    ! Parameters
    DOUBLEPRECISION, PARAMETER, PUBLIC :: pi = 3.14159265358793d0, g  = 9.807d0
	DOUBLEPRECISION, PARAMETER, PUBLIC :: gxviewer = 0.0d0, gyviewer = -1000000.0d0, gzviewer = -1000000.0d0
    INTEGER*4, PARAMETER, PUBLIC :: SIZEOFAPPNAME = 100
    
    ! Global data
    INTEGER(HANDLE) :: ghInstance,ghModule,ghwndMain,ghMenu,ghwndClient,ghWindow,ghdcVisual,ghdcPlot,ghrcVisual,ghrcPlot
    INTEGER(HANDLE) :: ghPlotWindow,ghDlgModless,ghAccelerators
    INTEGER(HANDLE) :: ghThread
    INTEGER(HANDLE) :: OBJECT_DL
    INTEGER(HANDLE) :: ghcursorCROSS,ghcursorARROW,ghcursorHAND
    INTEGER*4 :: pBits
    
    INTEGER :: gVersion
    INTEGER :: gvar,gxl,gyl,GlobalOriginX,GlobalOriginY
    INTEGER :: gCursorValue
    INTEGER :: gk
    INTEGER :: gParallelProcs,gPrecision_Digits
    INTEGER :: gAbort
    
    DOUBLEPRECISION :: gPrecision_Minimum,gPrecision_Maximum
    DOUBLEPRECISION :: gscalespeed,gpanspeed
	DOUBLEPRECISION :: gscaleX,gscaleY
    DOUBLEPRECISION	:: grotx,groty,grotz
	DOUBLEPRECISION :: gxprev,gyprev
	DOUBLEPRECISION :: gnumRED,gnumGREEN,gnumBLUE
    DOUBLEPRECISION :: gconvfactor
    DOUBLEPRECISION :: gxd,gyd,gzd,gxproj,gyproj
    DOUBLEPRECISION :: gMaxValue,gMinValue
    DOUBLEPRECISION :: gXdrag,gYdrag
    
    CHARACTER(900) szFileName,StringBufGlobal,szFilter

    TYPE MESH_GLOBAL_DATA
        INTEGER :: Faces
        INTEGER :: Asteriod_Faces
        INTEGER :: MinAreaFacet
        INTEGER :: MaxAreaFacet
        INTEGER :: WorstQualityFacet
        INTEGER :: Bodies
        DOUBLEPRECISION :: Xcg
        DOUBLEPRECISION :: Ycg
        DOUBLEPRECISION :: Zcg
    ENDTYPE
    TYPE MESH_DATA
        INTEGER :: nodes
        DOUBLEPRECISION :: Xcg
        DOUBLEPRECISION :: Ycg
        DOUBLEPRECISION :: Zcg
        DOUBLEPRECISION :: nx
        DOUBLEPRECISION :: ny
        DOUBLEPRECISION :: nz
        DOUBLEPRECISION :: Area
    ENDTYPE
    TYPE VECTOR_DATA
        DOUBLEPRECISION :: nx
        DOUBLEPRECISION :: ny
        DOUBLEPRECISION :: nz
    ENDTYPE
    TYPE GRAPHICS_DATA
        LOGICAL :: Show_Logo
        LOGICAL :: Show_Axes
        LOGICAL :: Show_Mirror
        LOGICAL :: Show_Trefftz
        LOGICAL :: Show_Streamlines
        LOGICAL :: Show_NonSolver
        LOGICAL :: Show_Transparent
        LOGICAL :: Show_Wireframe
        REAL(4) :: Intensity_Ambient(4)
        REAL(4) :: Intensity_Diffuse(4)
        REAL(4) :: Intensity_Specular(4)
        REAL(4) :: Position_Specular(4)
        REAL(4) :: Position_Diffuse(4)
        INTEGER(HANDLE) :: font_Logo
        TYPE (T_LOGFONT) :: lf_logo
    ENDTYPE
    TYPE POSITION_VECTOR
        DOUBLEPRECISION :: X
        DOUBLEPRECISION :: Y
        DOUBLEPRECISION :: Z
    ENDTYPE
    TYPE MOTION_DATA
        DOUBLEPRECISION :: omega
        DOUBLEPRECISION :: time
        DOUBLEPRECISION :: dt
        DOUBLEPRECISION :: angle
        DOUBLEPRECISION :: A1
        DOUBLEPRECISION :: A2
        DOUBLEPRECISION :: Stop_time
    ENDTYPE
    TYPE GUIDANCE
        DOUBLEPRECISION :: omega
        DOUBLEPRECISION :: time
        DOUBLEPRECISION :: dt
        DOUBLEPRECISION :: angle
        DOUBLEPRECISION :: A1
        DOUBLEPRECISION :: A2
    ENDTYPE
    TYPE VERTEX_POINT
        LOGICAL :: Selection
        DOUBLEPRECISION :: X
        DOUBLEPRECISION :: Y
        DOUBLEPRECISION :: Z
    ENDTYPE
    TYPE FACE_FROM_POINTS
        LOGICAL :: Selection
        INTEGER :: Vertex1
        INTEGER :: Vertex2
        INTEGER :: Vertex3
        INTEGER :: Vertex4
    ENDTYPE
    TYPE GRAPHICAL_SHAPES_DATA
        INTEGER :: Vertices
        INTEGER :: Faces
        TYPE (VERTEX_POINT), ALLOCATABLE :: Vertex(:)
        TYPE (FACE_FROM_POINTS), ALLOCATABLE :: Face(:)
        DOUBLEPRECISION, ALLOCATABLE :: nx(:)
        DOUBLEPRECISION, ALLOCATABLE :: ny(:)
        DOUBLEPRECISION, ALLOCATABLE :: nz(:)
    ENDTYPE
    TYPE VEHICLE_DATA
        DOUBLEPRECISION :: Tether
        DOUBLEPRECISION :: Length
        DOUBLEPRECISION :: Mass
        DOUBLEPRECISION :: Isp
        DOUBLEPRECISION :: thrust
        DOUBLEPRECISION :: fuel
    ENDTYPE
    TYPE ASTERIOD_DATA
        DOUBLEPRECISION :: Mass
        DOUBLEPRECISION :: inertia
        DOUBLEPRECISION :: density
    ENDTYPE
    
    TYPE (GRAPHICS_DATA)            SceneGraph
    TYPE (MESH_GLOBAL_DATA)         MeshGlobal
    TYPE (MESH_DATA)                MeshData(250000)
    TYPE (MOTION_DATA)              Motion
    TYPE (GRAPHICAL_SHAPES_DATA)    GraphSphere
    TYPE (VEHICLE_DATA)             Vehicle
    TYPE (ASTERIOD_DATA)            Asteriod
    
    TYPE (T_OPENFILENAME)     OFN
	TYPE (T_LOGFONT)          lf 
    TYPE (T_RECT)             rcClient
    TYPE (T_BITMAPFILEHEADER) pbmfh
    TYPE (T_BITMAPINFO)       bits
    
    POINTER(lpTV,lptreeview)
    POINTER(lpLV,lplistview)
    POINTER(lpLV_Dialog,lplistview_Dialog)
    POINTER(lptabm,TabMessage)
    POINTER(lpBits,bits)
    
    !*********************** MESHES *******************************************
    DOUBLEPRECISION meshX(5,250000),meshY(5,250000),meshZ(5,250000)
    
    !*********************** GRAPHICAL OBJECT MESHES **************************
    DOUBLEPRECISION :: GlobalContour(250000)
    DOUBLEPRECISION :: arrowX(5,20),arrowY(5,20),arrowZ(5,20),arrowNormals(76,3)
    
endmodule
    
subroutine GlobalRESET
	use CharybdisGlobals
    implicit doubleprecision (a-h,l-z)
    
    SceneGraph%Show_Logo        = .TRUE.
    SceneGraph%Show_Axes        = .TRUE.
    SceneGraph%Show_Mirror      = .TRUE.
    SceneGraph%Show_Trefftz     = .FALSE.
    SceneGraph%Show_Streamlines = .FALSE.
    SceneGraph%Show_NonSolver   = .FALSE.
    SceneGraph%Show_Transparent = .FALSE.
    SceneGraph%Show_Wireframe   = .FALSE.
    SceneGraph%Intensity_Ambient  = [0.3, 0.3, 0.3, 1.0]
    SceneGraph%Intensity_Diffuse  = [0.9, 0.9, 0.9, 1.0]
    SceneGraph%Intensity_Specular = [0.1, 0.1, 0.1, 1.0]
    SceneGraph%Position_Specular  = [10000, 0, 100000, 1]
    SceneGraph%Position_Diffuse   = [10000, 0, 100000, 1]
    SceneGraph%lf_logo%lfheight   = 50
    SceneGraph%lf_logo%lfWeight   = FW_EXTRABOLD
    SceneGraph%lf_logo%lfItalic   = .TRUE.
    SceneGraph%lf_logo%lfCharSet  = ANSI_CHARSET
    SceneGraph%lf_logo%lfPitchAndFamily = IOR(DEFAULT_PITCH,FF_DECORATIVE)
    SceneGraph%Font_Logo = CreateFontInDirect(SceneGraph%lf_logo)
    
    gscalex = 50.0d0
	gscaley = gscalex
    grotx =  -62.0d0
    groty =    0.0d0
	grotz = -136.0d0
    gscalespeed = 0.1d0
    gPrecision_Digits = 12
    gPrecision_Minimum = 0.0000000000001d0
    gPrecision_Maximum = 0.9999999999999d0
    gvar = 0
    gconvfactor  = 3.0d0
    gCursorValue = 0
    
    ghcursorCROSS = LoadCursor(NULL,IDC_CROSS)
    ghcursorHAND  = LoadCursor(NULL,IDC_HAND)
	ghcursorARROW = LoadCursor(NULL,IDC_ARROW)
    
    ghThread = 0
    gParallelProcs = 2
    
    gk = 0
    
    MeshGlobal%faces             = 0
    MeshGlobal%Asteriod_Faces    = 0
    MeshGlobal%MinAreaFacet      = 1
    MeshGlobal%MaxAreaFacet      = 1
    MeshGlobal%WorstQualityFacet = 1
    MeshGlobal%Xcg              = 0.0d0
    MeshGlobal%Ycg              = 0.0d0
    MeshGlobal%Zcg              = 0.0d0
    
    Motion%omega = 0.0d0
    Motion%time  = 0.0d0
    Motion%dt    = 0.0d0
    Motion%angle = 0.0d0
    Motion%A1    = 1.0d0
    Motion%A2    = 1.0d0
    Motion%Stop_time = 0.0d0
    
    Vehicle%Tether = 10.0d0
    Vehicle%Mass   = 10000.0d0
    Vehicle%Isp    = 5000.0d0
    Vehicle%thrust = 1.0d0
    Vehicle%fuel   = 9000.0d0
    Vehicle%length = 10.0d0
    
    Asteriod%Mass    = 100000.0d0
    Asteriod%Inertia = 100000.0d0*0.5d0*100.0d0
    Asteriod%Density = 5000.0d0
    
    call GetNEA
    call GetSpaceShip
    call UnstructDataGen
    call GetCGlocation
    call Graphical_Object_Meshes
    
    OBJECT_DL = fglGenLists(5)
    call Raster_List_Generator
end
