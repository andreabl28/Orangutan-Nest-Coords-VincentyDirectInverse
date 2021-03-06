# -------------------------------------------------------------------------
# Vincenty Direct geodetic computation function (Andre Verville)
# generates latitude, longitude and inverse bearing
# from a given point in lat lon, bearing and distance
# Credits: Thaddeus Vincenty, Survey Review, Vol.XXIII, No. 176, April 1975
# https://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf
# -------------------------------------------------------------------------
# Test Camp Senang

#The coordinates of any pixel of interest was determined by calculating the bearing from the pixel of interest to the centre of each image,
import math
# The Python ATAN2 function is one of the Python Math function which is used to returns the angle (in radians) from the X -Axis to the specified point (y, x).
# myradians = math.atan2(targetY-startY, targetX-startX)
# start is the center of the image (3000,2000), image is 6000x4000pixels
# enter the y and x coordinates of the nest from R
myradians = math.atan2(1347.18-2000, 4934.718-3000)
# convert from radians to degrees
mydegrees = math.degrees(myradians)
#assuming this transect was conducted West to East or East to West - adjusted for 270 degrees
#enter the degrees to adjust by
mydegrees = 90 + mydegrees
print(mydegrees)

# enter coordinates for the center of the drone image
lat1deg = -1.214402
lon1deg = 110.103287
#enter dist_m here
dist = 52.0804
brg12deg = mydegrees

def vincentydirect(lat1deg, lon1deg, brg12deg, dist):
    import math
    if dist < 0:  # if distance negative, we reverse bearing (can be useful)
        dist = abs(dist)
        brg12deg = brg12deg + 180
    brg12deg = brg12deg % 360  # make sure it does not exceed 360 degrees
    a, b = 6378137.0, 6356752.3141  # GRS80 ellipsoid, edit as required

    lat1rad = math.radians(lat1deg)
    lon1rad = math.radians(lon1deg)
    brg12rad = math.radians(brg12deg)

    e2 = ((a * a) - (b * b)) / (a * a)
    sinlat1 = math.sin(lat1rad)
    coslat1 = math.cos(lat1rad)
    sinbrg12 = math.sin(brg12rad)
    cosbrg12 = math.cos(brg12rad)
    N1 = a / ((1.0 - e2 * (sinlat1 * sinlat1))) ** 0.5
    M1 = (a * (1.0 - e2)) / ((1 - (e2 * sinlat1 * sinlat1)) ** 1.5)
    R = (M1 * N1) / ((M1 * sinbrg12 * sinbrg12) + (N1 * cosbrg12 * cosbrg12))
    d12 = dist - (dist * dist * dist) / (24.0 * R * R)
    X1 = N1 * math.cos(lat1rad)
    Z1 = N1 * (1.0 - e2) * sinlat1
    mu = math.asin(d12 / (2.0 * R))
    sinmu = math.sin(mu)
    cosmu = math.cos(mu)

    while 1:  # iterative section to compute X2, Y2 and Z2 while minimizing h
        X2 = X1 - d12 * (coslat1 * math.sin(mu) + sinlat1 * cosbrg12 * cosmu)
        Y2 = d12 * sinbrg12 * math.cos(mu)
        Z2 = Z1 + d12 * (coslat1 * cosbrg12 * math.cos(mu) - sinlat1 * sinmu)
        h = (((X2 * X2) + (Y2 * Y2) + ((Z2 * Z2) / (1.0 - e2))) ** 0.5) - a
        sigmamu = h / (d12 * math.cos(mu))
        mu = mu + sigmamu
        if abs(h) < 0.0001:
            break

    lat2rad = math.atan2(Z2, ((1.0 - e2) * ((X2 * X2) + (Y2 * Y2)) ** 0.5))
    sinlat2 = math.sin(lat2rad)
    coslat2 = math.cos(lat2rad)
    deltalon = math.atan2(Y2, X2)
    cosdeltalon = math.cos(deltalon)
    lon2rad = lon1rad + deltalon
    N2 = a / ((1 - e2 * math.sin(lat2rad) ** 2) ** 0.5)
    temp = (Z2 - Z1) * coslat2 - (N2 * coslat2 - X1 * cosdeltalon) * sinlat2
    brg21rad = math.atan(X1 * math.sin(deltalon) / temp)

    lat2deg = math.degrees(lat2rad)
    lon2deg = math.degrees(lon2rad)
    brg21deg = math.degrees(brg21rad)
    if abs(brg21deg - brg12deg) < 10:  # reverse bearing if at 180 degrees
        brg21deg = brg21deg + 180
        brg21deg = brg21deg % 360
    return lat2deg, lon2deg, #brg21deg


print(vincentydirect(lat1deg, lon1deg, brg12deg, dist))


