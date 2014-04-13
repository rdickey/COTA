from math import sqrt

mu = 1.327E20 # the mass of the sun times the gravitational constant
au = 1.496E11 # 1 AU in meters

def EnergyDiff(m,p,p1,p2):
    # Returns energy difference in Terajoules of changing aphelion or perihelion
    # m - mass of object
    # p - aphelion or perihelion of object, whichever is unchanged
    # p1 - initial aphelion or perihelion, whichever is changed
    # p2 - final aphelion or perihelion, whichever is chaned

    p,p1,p2 = [au*p,au*p1,au*p2] # convert to meters
    
    dE = m*mu*(p2-p1)/((p+p1)*(p+p2))/1E12 # convert energy to terajoules
    dE = abs(dE) # convert to absolute value

    ecc = abs(p-p2)/(p+p2)
    per = min(p,p2)
    ap = max(p,p2)
    vper = sqrt(mu*(1+ecc)/per)
    vap = sqrt(mu*(1-ecc)/ap)
    
    print('\n%.2f TJ\n\n' % dE)

def VelocityDiff(p,p1,p2):
    # Returns velocity difference to change aphelion or perihelion
    # p - aphelion or perihelion of object, whichever is unchanged
    # p1 - initial aphelion or perihelion, whichever is changed
    # p2 - final aphelion or perihelion, whichever is chaned
    
    p,p1,p2 = [au*p,au*p1,au*p2] # convert to meters
    
    ecc1 = abs(p-p1)/(p+p1)
    v1 = sqrt(((1-ecc1)*mu)/p)
    ecc2 = abs(p-p2)/(p+p2)
    v2 = sqrt(((1-ecc2)*mu)/p)
    dV = (v2 - v1)/1000

    per = min(p,p2)
    ap = max(p,p2)
    vper = sqrt(mu*(1+ecc2)/per)/1000
    vap = sqrt(mu*(1-ecc2)/ap)/1000
    
    print('\nChange in velocity at aphelion: %.2f km/s' % dV)
    print('New aphelion velocity: %.2f km/s\n\n' % vap)
    print('New perihelion velocity: %.2f km/s' % vper)


def GetChoice():
    print("1) Calculate Energy Difference")
    print("2) Calculate Velocity Difference")
    choice = input("Enter your option, or press enter to exit.\n")
    return(choice)
  
# Amun 3554
#EnergyDiff(1E13,1.247*au,0.701*au,1*au)
#EnergyDiff(1E13,0.701*au,1.247*au,1*au)

# Hypothetical

def main():
    # Propts user to calculate differences in velocity or energy
    choice = GetChoice()
    while choice in ["1","2"]:
        if choice == "1":
            m = float(input("Mass in kg: "))
            p = float(input("Aphelion of asteroid in AU: "))
            p1 = float(input("Current perihelion in AU: "))
            p2 = float(input("Desired perihelion in AU: "))
            EnergyDiff(m,p,p1,p2)
        
        if choice == "2":
            p = float(input("Aphelion of asteroid in AU: "))
            p1 = float(input("Current perihelion in AU: "))
            p2 = float(input("Desired perihelion in AU: "))
            VelocityDiff(p,p1,p2)
        
        choice = GetChoice()
        
        

if __name__ == "__main__":
    main()

