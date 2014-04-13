subroutine Atmosphere
    use CharybdisGlobals
	implicit doubleprecision (a-h,l-z)
	
    Atmospheric%gasconstant = 287.0d0
    
	if (altitude <= 11000.0d0*3.281d0) Atmospheric%Temperature = 15.04d0 - 0.00649d0*Flight%altitude + 273.16d0
    if (altitude <= 25000.0d0*3.281d0) Atmospheric%Temperature = -56.46d0 + 273.16d0
	if (altitude >= 25000.0d0*3.281d0) Atmospheric%Temperature = -131.21d0 + 0.00299*Flight%altitude + 273.16d0
    
    if (altitude <= 11000.0d0*3.281d0) Atmospheric%Pressure = (101.29d0*((Atmospheric%Temperature/288.08d0)**5.256d0))*1000.0d0
    if (altitude <= 25000.0d0*3.281d0) Atmospheric%Pressure = (22.65d0*dexp(1.73d0 - 0.000157d0*Flight%altitude))*1000.0d0
	if (altitude >= 25000.0d0*3.281d0) Atmospheric%Pressure = (2.488d0*((Atmospheric%Temperature/216.66d0)**-11.388d0))*1000.0d0
    
	Atmospheric%density   = pa/(gasconstant*ta)
	Atmospheric%viscosity = 0.00001827 + (0.0000250d0 - 0.00001827d0)*(ta-273.16d0)/(175.0d0)
	Atmospheric%cpgas     = 949.32d0*dexp(0.000097247d0*1.8d0*ta)
	Atmospheric%gamma     = cpgas/(cpgas - gasconstant)
	Atmospheric%sonic     = dsqrt(gamma*gasconstant*ta)
	Atmospheric%velocity  = Flight%mach*sonicvel
	Atmospheric%dynpres   = 0.5d0*density*(ua**2.0d0)
	!**************************************************************
end