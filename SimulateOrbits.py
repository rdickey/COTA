from math import cos,sin,pi

def RotZ(v, angle):
    #Takes a 3D vector v and an angle indegrees, and rotates about the Z axis
    
    rad = angle*pi/180
    newx = v[0]*cos(rad) - v[1]*sin(rad)
    newy = v[0]*sin(rad) + v[1]*cos(rad)
    return([newx, newy, v[2]])


def RotX(v, angle):
    #Takes a 3D vector v and an angle in degrees, and rotates about the X axis
    
    rad = angle*pi/180
    newy = v[1]*cos(rad) - v[2]*sin(rad)
    newz = v[1]*sin(rad) + v[2]*cos(rad)
    return([v[0], newy, newz])


def Radius(EC,TA,AD):
    # Computes the distance from a body to the sun
    # AD is the aphelion
    # EC is the eccentricity of the orbit
    # TA is the true anomaly
    
    radius = AD * (1 - EC ** 2) / (1 - EC * cos(TA))
    return(radius)


def Location(datarow):
    EC,IN,OM,TA,AD = datarow[1:]
    # Computes the location of a body relative to the sun
    # returns a length-3 vector in x,y,z coordinates
    # EC - eccentricity
    # IN - inclination of the orbit wrt the ecliptic
    # OM - longitude of ascending node
    # TA - true anomaly
    # AD - aphelion

    radius = Radius(EC,TA,AD)
    position = [radius,0,0]
    position = RotZ(position, TA)
    position = RotX(position, IN)
    position = RotZ(position, OM)

    return(position)


def ImportBody(name):
    # Imports the body specified - takes a string

    with open("Orbit Data\\"+name+".txt") as f:
        content = f.readlines()

    return(content)


def MakeDataArray(content):
    #Returns an array of time, EC,IN,OM,TA,AD
    
    rownum = 0
    numrows = len(content)
    while content[rownum] != "$$SOE\n" and rownum < numrows:
        rownum += 1
    rownum += 1
    lastrow = rownum
    while content[lastrow] != "$$EOE\n" and lastrow < numrows: lastrow += 1

    dataarray = []
    while rownum < lastrow:
        newrow = []
        newrow.append(content[rownum][25:-6])
        rownum += 1
        newrow.append(float(content[rownum][5:26]))
        newrow.append(float(content[rownum][57:78]))
        rownum += 1
        newrow.append(float(content[rownum][5:26]))
        rownum += 1
        newrow.append(float(content[rownum][57:78]))
        rownum += 1
        newrow.append(float(content[rownum][31:52]))
        rownum += 1
        dataarray.append(newrow)

    return(dataarray)

    
        
        
    

