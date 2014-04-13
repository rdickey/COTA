!  Charybdis.f90 
!****************************************************************************
!  FUNCTION: WinMain( hInstance, hPrevInstance, lpszCmdLine, nCmdShow )
!  PURPOSE:  Entry point for the application
!  COMMENTS: Displays the main window and processes the message loop
!****************************************************************************
function WinMain( hInstance, hPrevInstance, lpszCmdLine, nCmdShow )
    !DEC$ IF DEFINED(_X86_)
    !DEC$ ATTRIBUTES STDCALL, ALIAS : '_WinMain@16' :: WinMain
    !DEC$ ELSE
    !DEC$ ATTRIBUTES STDCALL, ALIAS : 'WinMain' :: WinMain
    !DEC$ ENDIF
    use CharybdisGlobals
    implicit doubleprecision (a-h,l-z)

    integer(SINT) :: WinMain
    integer(HANDLE) :: hInstance,hPrevInstance,hfont,holdfont,hFile,pheader
    integer(LPWSTR) :: lpszCmdLine
    integer(SINT) :: nCmdShow

    include 'Charybdis.fi'
    include 'resource.fd'

    ! Variables
    TYPE (T_WNDCLASS)       wc
    TYPE (T_MSG)            mesg
    TYPE (T_PIXELFORMATDESCRIPTOR) pfd
    integer*4               ret
    integer(LRESULT)        lret
    integer(BOOL)           bret
    integer(SINT)           iret
    
    character(200) lpszClassName,lpszIconName,lpszAppName,lpszMenuName,lpszAccelName
    
    ghInstance = hInstance
    ghModule = GetModuleHandle(NULL)
    ghwndMain = NULL

    lpszClassName   = "Charybdis"C
    lpszAppName     = "Charybdis"C
    lpszIconName    = "Charybdis"C  
    lpszMenuName    = "Charybdis"C
    lpszAccelName   = "Charybdis"C

    !  If this is the first instance of the application, register the  window class(es)
    if (hPrevInstance .eq. 0) then
         wc%lpszClassName   = LOC(lpszClassName)
         wc%lpfnWndProc     = LOC(MainWndProc)
         wc%style           = IOR(CS_OWNDC,CS_DBLCLKS)
         wc%hInstance       = hInstance
         wc%hIcon           = LoadIcon( hInstance, LOC(lpszIconName))
         wc%hCursor         = NULL !LoadCursor( NULL, IDC_ARROW )
         wc%hbrBackground   = ( COLOR_WINDOW+1 )
         wc%lpszMenuName    = NULL
         wc%cbClsExtra      = 0
         wc%cbWndExtra      = 0
         if (RegisterClass(wc) == 0) goto 99999
    endif

    ! Load the window's menu and accelerators and create the window
    ghMenu = LoadMenu(hInstance, LOC(lpszMenuName))
    if (ghMenu == 0) goto 99999
        !hBitmap = LoadBitmap(ghInstance,MAKEINTRESOURCE(IDB_BI_OPEN))
        !iret = SetMenuItemBitmaps(ghMenu,INT(MAKEINTRESOURCE(IDM_OPEN)),MF_BYCOMMAND,hBitmap,hBitmap)
        
    gVersion = 1.0d0

    ghwndMain = CreateWindowEx(0,lpszClassName,lpszAppName,IOR(WS_OVERLAPPED,IOR(WS_CAPTION,IOR(WS_BORDER,IOR(WS_THICKFRAME,  &
                IOR(WS_MAXIMIZEBOX,IOR(WS_MINIMIZEBOX,IOR(WS_CLIPCHILDREN,IOR(WS_VISIBLE,WS_SYSMENU)))))))),CW_USEDEFAULT,0,CW_USEDEFAULT,0,NULL,ghMenu,hInstance,NULL)
    if (ghwndMain == 0) goto 99999
    
    lf%lfheight = 13
    hfont = CreateFontInDirect(lf)
                    
    DATA pfd / T_PIXELFORMATDESCRIPTOR (sizeof(PIXELFORMATDESCRIPTOR),1,IOR(PFD_DRAW_TO_WINDOW,IOR(PFD_SUPPORT_OPENGL,PFD_DOUBLEBUFFER)),PFD_TYPE_RGBA,24, &
                                        0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,PFD_MAIN_PLANE,0,0,0,0) / 
                        
    ghdcVisual = GetDC(ghwndMain)
                        
    inPixelFormat = ChoosePixelFormat(ghdcVisual,pfd)
    bret = SetPixelFormat(ghdcVisual,inPixelFormat,pfd)
    iret = DescribePixelFormat(ghdcVisual,inPixelFormat,40,pfd)
                        
    ghrcVisual = fwglCreateContext(ghdcVisual)
    bret = fwglMakeCurrent(ghdcVisual,ghrcVisual)
                        
    SceneGraph%lf_logo%lfheight    = 50
    SceneGraph%lf_logo%lfWeight    = FW_EXTRABOLD
    SceneGraph%lf_logo%lfItalic    = .TRUE.
    SceneGraph%lf_logo%lfCharSet   = ANSI_CHARSET
    SceneGraph%lf_logo%lfPitchAndFamily = IOR(DEFAULT_PITCH,FF_DECORATIVE)
    SceneGraph%Font_Logo = CreateFontInDirect(SceneGraph%lf_logo)
                        
    hOldfont = SelectObject(ghdcVisual,SceneGraph%Font_Logo)
    bret = fwglUseFontBitmaps(ghdcVisual,0,255,2000)
    iret = SelectObject(ghdcVisual,hOldfont)
        
    hOldfont = SelectObject(ghdcVisual,hfont)
    bret = fwglUseFontBitmaps(ghdcVisual,0,255,1000)
    iret = SelectObject(ghdcVisual,hOldfont)
    
    hFile = CreateFile("Background.bmp",GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_FLAG_SEQUENTIAL_SCAN,NULL)
    if (hFile /= 0) then
        nbytes = GetFileSize(hFile,NULL)
        iret = ReadFile(hFile,LOC(pbmfh),INT4(nbytes),LOC(dwBytesRead),NULL)
        bret = CloseHandle(hFile)
        hFile = CreateFile("Background.bmp",GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_FLAG_SEQUENTIAL_SCAN,NULL)
        nbytes = GetFileSize(hFile,NULL)
        pheader = malloc(INT4(nbytes))
        iret = ReadFile(hFile,pheader,INT4(nbytes),LOC(dwBytesRead),NULL)
        lpbits = pheader + SIZEOF(pbmfh) 
        pBits = pheader + pbmfh%bfOffbits
        !iret = SetDIBitsToDevice(ghdcVisual,0,rcClient%Bottom-220,image_width,image_height,0,0,0,image_height,INT8(pbits),bits,DIB_RGB_COLORS)
    endif
                    
    call GlobalRESET
    !iret = SendMessage(ghWindow,WM_COMMAND,MAKEWPARAM(IDM_ABOUT,0),0)
    lret = ShowWindow(ghwndMain,nCmdShow)
    lret = ShowWindow(ghwndMain,SW_MAXIMIZE)
    !iret = SendMessage(ghWindow,WM_COMMAND,MAKEWPARAM(IDM_RESTORE_VIEW,0),0)

    ! Read and process messsages
    do while( GetMessage (mesg, NULL, 0, 0) ) 
        if (INT8(ghDlgModeless) == 0 .OR. IsDialogMessage(INT8(ghDlgModless),mesg) == 0) then
            if ((TranslateAccelerator(ghwndMain,ghAccelerators,mesg) == 0).AND.(TranslateMDISysAccel(ghwndClient,mesg).EQV.FALSE)) then
                bret = TranslateMessage( mesg )
                lret = DispatchMessage( mesg )
            endif
        endif
    enddo

    WinMain = mesg.wParam
    return

99999 CONTINUE
    iret = MessageBox(ghwndMain, "Error initializing application Charybdis"C,"Error"C, MB_OK)
    WinMain = 0
end 

!****************************************************************************
!  FUNCTION: MainWndProc ( hWnd, mesg, wParam, lParam )
!  PURPOSE:  Processes messages for the main window
!****************************************************************************
integer(LRESULT) function MainWndProc ( hWnd, mesg, wParam, lParam )
    !DEC$ IF DEFINED(_X86_)
    !DEC$ ATTRIBUTES STDCALL, ALIAS : '_MainWndProc@16' :: MainWndProc
    !DEC$ ELSE
    !DEC$ ATTRIBUTES STDCALL, ALIAS : 'MainWndProc' :: MainWndProc
    !DEC$ ENDIF
    use CharybdisGlobals
    implicit doubleprecision (a-h,l-z)

    integer(HANDLE) hWnd
    integer(UINT) mesg
    integer(UINT_PTR) wParam
    integer(LONG_PTR) lParam 

    include 'resource.fd'

    interface 
        Subroutine SetMotion
            !DEC$ IF DEFINED(_X64_)
            !DEC$ ATTRIBUTES STDCALL, ALIAS : '_SetMotion@16' :: SetMotion
            !DEC$ ELSE
            !DEC$ ATTRIBUTES STDCALL, ALIAS : 'SetMotion' :: SetMotion
            !DEC$ ENDIF
        end Subroutine
        
        integer*4 function VehicleSetupProc( hwnd, mesg, wParam, lParam )
            !DEC$ IF DEFINED(_X64_)
            !DEC$ ATTRIBUTES STDCALL, ALIAS : '_VehicleSetupProc@16' :: VehicleSetupProc
            !DEC$ ELSE
            !DEC$ ATTRIBUTES STDCALL, ALIAS : 'VehicleSetupProc' :: VehicleSetupProc
            !DEC$ ENDIF
        end function
        
        integer*4 function AsteriodSetupProc( hwnd, mesg, wParam, lParam )
            !DEC$ IF DEFINED(_X64_)
            !DEC$ ATTRIBUTES STDCALL, ALIAS : '_AsteriodSetupProc@16' :: AsteriodSetupProc
            !DEC$ ELSE
            !DEC$ ATTRIBUTES STDCALL, ALIAS : 'AsteriodSetupProc' :: AsteriodSetupProc
            !DEC$ ENDIF
        end function
    end interface

    ! Variables
    integer(BOOL)       lret
    integer(LRESULT)    ret
    character(10)       FileExtCheck
    character(200)      lpszTitle,lpszName,lpszMessage,lpszHeader
    
    TYPE (T_PIXELFORMATDESCRIPTOR) pfd
    TYPE (T_STARTUPINFO)         sival
    TYPE (T_PROCESS_INFORMATION) pival
    TYPE (T_LVITEM) LVitem
    
    integer(HANDLE)  hdc,hrc,hfont,hOldfont,hFile,pheader,nbytes,hfontLogo,hbitmap
    integer(LPVOID)  pInfo
    
    ghWindow = hWnd

    select case (mesg)
        case (WM_DESTROY)
            call PostQuitMessage(0)
            MainWndProc = 0
            return

        case (WM_SETCURSOR)
            iret = SetCursor(ghcursorARROW)
            if (gCursorValue == 1) iret = SetCursor(ghcursorHAND)
            gCursorValue = 0
            MainWndProc = 0
            return
          
        case (WM_SIZE)
            iret = GetClientRect(ghWindow,rcClient)
            GlobalOriginX = 0.5d0*rcClient%Right
	        GlobalOriginY = 0.5d0*rcClient%Bottom
            MainWndProc = 0
            return
            
        case (WM_PAINT)
            call GlobalPlotting
            MainWndProc = 0
            return
         
        case (WM_MOUSEMOVE)
    		xval = INT4(LOWORD(INT(lParam)))
	    	yval = INT4(HIWORD(INT(lParam)))
            
            if (LOWORD(INT(wParam)) == MK_MBUTTON) then
                GlobalOriginX = GlobalOriginX + (xval-gxprev)
                GlobalOriginY = GlobalOriginY - (yval-gyprev)
                call GlobalPlotting
                gCursorValue = 1
                gxprev = xval
                gyprev = yval
            endif  
            
            if (LOWORD(INT(wParam)) == MK_LBUTTON) then
                if (yval >  gyprev) grotx = grotx + (dabs(yval-gyprev) - gYdrag)/10
                if (yval <= gyprev) grotx = grotx - (dabs(yval-gyprev) - gYdrag)/10
                if (xval >  gxprev) grotz = grotz + (dabs(xval-gxprev) - gXdrag)/10
                if (xval <= gxprev) grotz = grotz - (dabs(xval-gxprev) - gXdrag)/10
                gXdrag = dabs(xval-gxprev)
                gYdrag = dabs(yval-gyprev)
                call GlobalPlotting
            endif
            MainWndProc = 0
            Return
            
        case (WM_LBUTTONDOWN)
            gxprev = INT4(LOWORD(INT(lParam)))
            gyprev = INT4(HIWORD(INT(lParam)))
            gXdrag = 0.0d0
            gYdrag = 0.0d0
            MainWndProc = 0
            Return
            
        case (WM_MBUTTONDOWN)
            gxprev = INT4(LOWORD(INT(lParam)))
            gyprev = INT4(HIWORD(INT(lParam)))
            MainWndProc = 0
            Return
            
        case (WM_MOUSEWHEEL)
            xval = INT4(LOWORD(INT(lParam)))
            yval = INT4(HIWORD(INT(lParam)))
            
            iret = GetWindowRect(ghWindow,rcClient)
                
            xc = xval - rcClient%left
            yc = rcClient%bottom - rcClient%top - yval
                
            xlen = (xc - GlobalOriginX)/gscalex
            ylen = (yc - GlobalOriginY)/gscalex
                
            if (HIWORD(INT(wParam)) < 0) then
                GlobalOriginX = GlobalOriginX - xlen*gscalespeed*gscalex
                GlobalOriginY = GlobalOriginY - ylen*gscalespeed*gscalex
                gscalex = gscalex + gscalespeed*gscalex
            else 
                GlobalOriginX = GlobalOriginX + xlen*gscalespeed*gscalex
                GlobalOriginY = GlobalOriginY + ylen*gscalespeed*gscalex
                gscalex = gscalex - gscalespeed*gscalex
            endif
            gscaley = gscalex
            call GlobalPlotting
            
            MDIWndProc = 0
            return
            
            
            
        case (WM_COMMAND)
            select case ( IAND(wParam, 16#ffff ) )
                
                case (IDM_EXIT)
                    iret = SendMessage(hWnd,WM_CLOSE,0,0)
                    MainWndProc = 0
                    return
      
                case (IDM_MOTION_START)
                    ghThread = CreateThread(NULL_SECURITY_ATTRIBUTES,0,LOC(SetMotion),NULL,0,NULL)
                    MainWndProc = 0
                    return
                    
                case (IDM_MOTION_STOP)
                    if (ghThread /= 0) gAbort = 1
                    MainWndProc = 0
                    return
                    
                case (IDM_VEHICLE_SETUP)
                    iret = CreateDialogParam(ghInstance,MAKEINTRESOURCE(IDD_VEHICLE_SETUP),hWnd,LOC(VehicleSetupProc),0_LONG_PTR)
                    MainWndProc = 0
                    return
                    
                case (IDM_ASTERIOD_SETUP)
                    iret = CreateDialogParam(ghInstance,MAKEINTRESOURCE(IDD_ASTERIOD_SETUP),hWnd,LOC(AsteriodSetupProc),0_LONG_PTR)
                    MainWndProc = 0
                    return
                    
                case (IDM_UPDATE_SCENE)
                    call UnstructDataGen
                    call Raster_List_Generator
                    call GlobalPlotting
                    MainWndProc = 0
                    return

            case DEFAULT
                MainWndProc = DefWindowProc( hWnd, mesg, wParam, lParam )
                return
        end select

    ! Let the default window proc handle all other messages
        case default
            MainWndProc = DefWindowProc(hWnd,mesg,wParam,lParam)
    end select
end

!****************************************************************************
!  FUNCTION: CenterWindow (HWND, HWND)
!  PURPOSE:  Center one window over another
!  COMMENTS: Dialog boxes take on the screen position that they were designed
!            at, which is not always appropriate. Centering the dialog over a
!            particular window usually results in a better position.
!****************************************************************************
subroutine CenterWindow(hwndChild,hwndParent)
    use CharybdisGlobals
    implicit doubleprecision(a-h,l-z)
    
    integer(HANDLE) hwndChild,hwndParent,hdc
    type (T_RECT)   rChild,rParent
    integer         wChild,hChild,wParent,hParent,wScreen,hScreen,xNew,yNew

    !Get the Height and Width of the child window
    retval = GetWindowRect(hwndChild,rChild)
    wChild = rChild%right - rChild%left
    hChild = rChild%bottom - rChild%top
    
    !Get the Height and Width of the parent window
    iret    = GetWindowRect (hwndParent, rParent)
    wParent = rParent%right - rParent%left
    hParent = rParent%bottom - rParent%top
    
    ! Get the display limits
    hdc = GetDC(hwndChild)
    wScreen = GetDeviceCaps(hdc,HORZRES)
    hScreen = GetDeviceCaps(hdc,VERTRES)
    retval = ReleaseDC(hwndChild,hdc)
    
    !Calculate new X position, then adjust for screen
    xNew = rParent%left + (wParent-wChild)/2
    if (xNew < 0) xNew = 0
    if (xNew + wChild > wScreen) xNew = wScreen - wChild
    
    !Calculate new Y position, then adjust for screen
    yNew = rParent%top  + (hParent-hChild)/2
    if (yNew < 0) yNew = 0
    if (yNew + hChild > hScreen) yNew = hScreen - hChild
    
    iret = SetWindowPos(hwndChild,NULL,xNew,yNew,0,0,IOR(SWP_NOSIZE,SWP_NOZORDER))
end
    
subroutine Graphical_Object_Meshes
    use CharybdisGlobals
    implicit doubleprecision (a-h,l-z)
    
    !************ LOAD BALL MESH HERE ************
    GraphSphere%Vertices = 200
    GraphSphere%Faces    = 171
    allocate(GraphSphere%Vertex(GraphSphere%Vertices))
    allocate(GraphSphere%Face(GraphSphere%Faces))
    allocate(GraphSphere%nx(GraphSphere%Vertices))
    allocate(GraphSphere%ny(GraphSphere%Vertices))
    allocate(GraphSphere%nz(GraphSphere%Vertices))
    
    ivertex = 1
    dtheta = pi/9
    theta = 0.0d0
    do i = 1,10
        psi = 0.0d0
        dpsi = 2.0d0*pi/19
        do j = 1,20
            GraphSphere%Vertex(ivertex)%X = dcos(theta)
            GraphSphere%Vertex(ivertex)%Y = dsin(theta)*dcos(psi)
            GraphSphere%Vertex(ivertex)%Z = dsin(theta)*dsin(psi)
            GraphSphere%nx(ivertex) = dcos(theta)
            GraphSphere%ny(ivertex) = dsin(theta)*dcos(psi)
            GraphSphere%nz(ivertex) = dsin(theta)*dsin(psi)
            psi = psi + dpsi
            ivertex = ivertex + 1
        enddo
        theta = theta + dtheta
    enddo
    
    iface = 1
    do i = 1,9
        do j = 1,19
            GraphSphere%Face(iface)%vertex1 = j   + (i-1)*20
            GraphSphere%Face(iface)%vertex2 = j+1 + (i-1)*20
            GraphSphere%Face(iface)%vertex3 = j+1 + i*20
            GraphSphere%Face(iface)%vertex4 = j   + i*20
            iface = iface + 1
        enddo
    enddo
end
    
Integer(4) Function VehicleSetupProc( hDlg, message, uParam, lParam )
	!DEC$ IF DEFINED(_X64_)
	!DEC$ ATTRIBUTES STDCALL, ALIAS : '_VehicleSetupProc@16' :: VehicleSetupProc
	!DEC$ ELSE
	!DEC$ ATTRIBUTES STDCALL, ALIAS : 'VehicleSetupProc' :: VehicleSetupProc
	!DEC$ ENDIF
	use CharybdisGlobals
    implicit doubleprecision (a-h,l-z)

	include 'resource.fd'

	integer(HANDLE) hDlg  
    integer     message     ! type of message
    integer     uParam      ! message-specific information
    integer     lParam

	select case (message)
		case (WM_INITDIALOG)
			call CenterWindow (hDlg, GetWindow (hDlg,GW_OWNER))
            write(StringBufGlobal,'(F15.5)') Vehicle%Tether
			iret = SetDlgItemText(hDlg,IDC_EDIT1,TRIM(ADJUSTL(StringBufGlobal))//CHAR(0))
            write(StringBufGlobal,'(F15.5)') Vehicle%Mass
			iret = SetDlgItemText(hDlg,IDC_EDIT2,TRIM(ADJUSTL(StringBufGlobal))//CHAR(0))
            write(StringBufGlobal,'(F15.5)') Vehicle%Isp
			iret = SetDlgItemText(hDlg,IDC_EDIT3,TRIM(ADJUSTL(StringBufGlobal))//CHAR(0))
            write(StringBufGlobal,'(F15.5)') Vehicle%Thrust
			iret = SetDlgItemText(hDlg,IDC_EDIT4,TRIM(ADJUSTL(StringBufGlobal))//CHAR(0))
            
            VehicleSetupProc = 1
			return

		case (WM_COMMAND)                     
			if (LOWORD(uParam) == IDOK) then
                iret = GetDlgItemText(hDlg,IDC_EDIT1,StringBufGlobal,LEN(StringBufGlobal))
				read(StringBufGlobal,'(F15.0)',END=190,ERR=190) temp1
                iret = GetDlgItemText(hDlg,IDC_EDIT2,StringBufGlobal,LEN(StringBufGlobal))
				read(StringBufGlobal,'(F15.0)',END=190,ERR=190) temp2
                iret = GetDlgItemText(hDlg,IDC_EDIT3,StringBufGlobal,LEN(StringBufGlobal))
				read(StringBufGlobal,'(F15.0)',END=190,ERR=190) temp3
                iret = GetDlgItemText(hDlg,IDC_EDIT4,StringBufGlobal,LEN(StringBufGlobal))
				read(StringBufGlobal,'(F15.0)',END=190,ERR=190) temp4
                
                Vehicle%Tether = temp1
                Vehicle%Mass   = temp2
                Vehicle%Isp    = temp3
                Vehicle%Thrust = temp4
                
                call UnstructDataGen
                call GetCGlocation
                call Raster_List_Generator
                call GlobalPlotting
                
                iret = DestroyWindow(hDlg)
                
190             VehicleSetupProc = 1
				return
                
            elseif (LOWORD(uParam) == IDCANCEL) then
                iret = DestroyWindow(hDlg)
                VehicleSetupProc = 1
				return
            endif
	endselect 
	VehicleSetupProc = 0 ! Didn't process the message
    return
end   
    
Integer(4) Function AsteriodSetupProc( hDlg, message, uParam, lParam )
	!DEC$ IF DEFINED(_X64_)
	!DEC$ ATTRIBUTES STDCALL, ALIAS : '_AsteriodSetupProc@16' :: AsteriodSetupProc
	!DEC$ ELSE
	!DEC$ ATTRIBUTES STDCALL, ALIAS : 'AsteriodSetupProc' :: AsteriodSetupProc
	!DEC$ ENDIF
	use CharybdisGlobals
    implicit doubleprecision (a-h,l-z)

	include 'resource.fd'

	integer(HANDLE) hDlg  
    integer     message     ! type of message
    integer     uParam      ! message-specific information
    integer     lParam

	select case (message)
		case (WM_INITDIALOG)
			call CenterWindow (hDlg, GetWindow (hDlg,GW_OWNER))
            write(StringBufGlobal,'(F15.5)') Asteriod%Mass
			iret = SetDlgItemText(hDlg,IDC_EDIT1,TRIM(ADJUSTL(StringBufGlobal))//CHAR(0))
            write(StringBufGlobal,'(F15.5)') Asteriod%Inertia
			iret = SetDlgItemText(hDlg,IDC_EDIT2,TRIM(ADJUSTL(StringBufGlobal))//CHAR(0))
            write(StringBufGlobal,'(F15.5)') Asteriod%Density
			iret = SetDlgItemText(hDlg,IDC_EDIT3,TRIM(ADJUSTL(StringBufGlobal))//CHAR(0))
            write(StringBufGlobal,'(F15.5)') Motion%Omega*180/pi
			iret = SetDlgItemText(hDlg,IDC_EDIT4,TRIM(ADJUSTL(StringBufGlobal))//CHAR(0))
            
            AsteriodSetupProc = 1
			return

		case (WM_COMMAND)                     
			if (LOWORD(uParam) == IDOK) then
                iret = GetDlgItemText(hDlg,IDC_EDIT1,StringBufGlobal,LEN(StringBufGlobal))
				read(StringBufGlobal,'(F15.0)',END=190,ERR=190) temp1
                iret = GetDlgItemText(hDlg,IDC_EDIT2,StringBufGlobal,LEN(StringBufGlobal))
				read(StringBufGlobal,'(F15.0)',END=190,ERR=190) temp2
                iret = GetDlgItemText(hDlg,IDC_EDIT3,StringBufGlobal,LEN(StringBufGlobal))
				read(StringBufGlobal,'(F15.0)',END=190,ERR=190) temp3
                iret = GetDlgItemText(hDlg,IDC_EDIT4,StringBufGlobal,LEN(StringBufGlobal))
				read(StringBufGlobal,'(F15.0)',END=190,ERR=190) temp4
                
                Asteriod%Mass    = temp1
                Asteriod%Inertia = temp2
                Asteriod%Density = temp3
                Motion%Omega     = temp4*pi/180
                
                call UnstructDataGen
                call GetCGlocation
                call Raster_List_Generator
                call GlobalPlotting
                
                iret = DestroyWindow(hDlg)
                
190             AsteriodSetupProc = 1
				return
                
            elseif (LOWORD(uParam) == IDCANCEL) then
                iret = DestroyWindow(hDlg)
                AsteriodSetupProc = 1
				return
            endif
	endselect 
	AsteriodSetupProc = 0 ! Didn't process the message
    return
end 
    
