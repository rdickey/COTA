from math import sqrt

mu = 1.327E20 # the mass of the sun times the gravitational constant
au = 1.496E11 # 1 AU in meters

def EnergyDiff(m,p,p1,p2):
    # Returns energy difference in Joules of changin 
    # m - mass of object
    # ap - aphelion or perhelion of object, whichever is unchanged
    # p1 - initial aphelion or perhelion, whichever is changed
    # p2 - final aphelion or perhelion, whichever is chaned
    
    dE = m*mu*(p2-p1)/((p+p1)*(p+p2))/1E12 # convert energy to terajoules
    dE = abs(dE) # convert to absolute value

    ecc = abs(p-p2)/(p+p2)
    per = min(p,p2)
    ap = max(p,p2)
    vper = sqrt(mu*(1+ecc)/per)
    vap = sqrt(mu*(1-ecc)/ap)
    
    print('%.2f TJ' % dE)
    print('Perhelion velocity: %.2f' % vper)
    print('Aphelion velocity: %.2f' % vap)


# Amun 3554
#EnergyDiff(1E13,1.247*au,0.701*au,1*au)
#EnergyDiff(1E13,0.701*au,1.247*au,1*au)

# Hypothetical
EnergyDiff(1E
