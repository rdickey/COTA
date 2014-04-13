integer(4) function InitializeOpen()
	use CharybdisGlobals
	implicit doubleprecision(a-h,l-z)	
		OFN%lstructSize		  = sizeof(OFN)
		OFN%hwndowner		  = ghWindow
		OFN%hinstance		  = ghInstance
		OFN%lpstrfilter		  = LOC(szfilter)
		OFN%lpstrcustomfilter = NULL
		OFN%NMAXcustfilter    = 0
		OFN%NfilterIndex      = 1
		OFN%LPstrFile         = LOC(szFileName)
		OFN%NMAXFile		  = LEN(szFileName)
		OFN%LPstrFileTitle    = NULL !LOC(szFileName)
		OFN%NMAXFileTitle     = NULL !LEN(szFileName)
		OFN%LPStrInitialDIR   = NULL
		OFN%LPstrTitle		  = NULL
		OFN%FLAGS			  = IOR(OFN_PATHMUSTEXIST,OFN_FILEMUSTEXIST)
		OFN%NFileOffset		  = NULL
		OFN%NFileExtension    = NULL
		OFN%LPstrDefExt		  = NULL !LOC("txt"C)
		OFN%LCustData		  = NULL
		OFN%LPfnHook		  = NULL
		OFN%LPTemplateName	  = NULL
	InitializeOpen = 1
	return
end function