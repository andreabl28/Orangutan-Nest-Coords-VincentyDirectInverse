#Georeferencing orangutan nest locations

#load library packages
library(devtools)
#devtools::install_github("JoshOBrien/exiftoolr", force = TRUE)
#devtools::install_github("filipematias23/FIELDimageR")
library(FIELDimageR)
library(exiftoolr)
#library(exifr)
library(raster)
library(sp)
library(maps)
library(jpeg)

#https://gis.stackexchange.com/questions/384756/georeference-single-drone-image-from-exif-data

#Set working directory
setwd("C:/Users/black/Documents/Documents/Nest Survey/TR_0_final/TR0_final_nests_tagged")

#getwd()
#In RStudio, in the Knit dropdown menu, select Knit directory, then Current Working Directory. Then rerun setwd(...).

list.files()
#example of an image with a nest
#DSC01080<-readJPEG("DSC01080_geotag_edited.jpg")

#can use install to update tool
install_exiftool()

#Test drone image of TR8
setwd("C:/Users/black/Documents/Documents/Nest Survey/Test_images/TR8_For Andrea/uncertain (blue) nests")
#setwd("C:/Users/black/Documents/Documents/Nest Survey/Test_images/TR8_For Andrea/certain (red) nests")
list.files()
#c_nest_2_1<-readJPEG("certain nest 2_column 1.jpg.jpg")

#Exiftool (Toevs, 2016) was used to extract the GPS metadata recorded with each image
#https://github.com/JoshOBrien/exiftoolr

devtools::install_github("JoshOBrien/exiftoolr")
#exif_read() can be used to read metadata from one or more files into a data.frame with one column per metadata field and one row per file. 
#setwd("C:/Users/black/Documents/Documents/Nest Survey/Test_images/TR8_For Andrea/certain (red) nests")
image<-exif_read("uncertain nest 2_column 2.jpg")

image$GPSLatitude
image$GPSLatitudeRef
image$GPSLongitudeAre
image$GPSLongitudeRef
image$GPSPosition
image$GPSVersionID
image$Technology
image$GPSPosition

#Selecting the nest location and extracting the pixel coordinates.
setwd("C:/Users/black/Documents/Documents/Nest Survey/Test_images/TR8_For Andrea/uncertain (blue) nests")
#setwd("C:/Users/black/Documents/Documents/Nest Survey/Test_images/TR8_For Andrea/certain (red) nests")
#create image stack
img_stack<-stack("uncertain nest 2_column 2.jpg")
#create spatial polygon
img.shp<-fieldPolygon(img_stack,extent = T)
# click on plot where you want to query pixel value in R Script, doesn't seem to work in R Markdown format
pxy <- locator(1)
pxy$x
pxy$y

#' Drone camera:
#' Sony ILCE-5100 With a APS-C type (23.5 x 15.6mm), Exmor™ CMOS

#'Calcuating Ground Surface Distance
#'The distance between pixels on the ground was calculated using the ground-surface distance formula (Felipe-García et al., 2012) and Vincenty’s Formula (Youn et al., 2009) was used to determine the GPS coordinates of the target pixel for each nest and fig tree.
#' https://wingtra.com/how-ground-sample-distance-gsd-relates-to-accuracy-and-drone-roi/
#Ground Sample Distance Example:
#'Sensor (Sw x Sh) = 13.2 x 8.8 mm
#'Focal length, F = 8.8 mm (rear focal length, not 35 mm equivalent)
#'The flight height, H = 100 m
#'Image resolution, (imW x imH) = 4096 x 2160 (in pixels)
#'Then, Ground Sampling Distance, (GSD) = (H x Sw) / (F x imW) (in cm)


#The aperture is the size of the opening through which the light enters. It is expressed as an “f/ number” which is the focal length divided by the diameter of the aperture 
image$ApertureValue
#2.8 aperature
image$LensModel
#20mm focal length, 2.8 aperature
image$GPSAltitude
#197.3m

#Field of view (FOV) is the maximum area of a sample that a camera can image
image$FOV
#61.9

#center of the image coordinates
image$GPSPosition

#ground-surface distance formula
#(H * Sw) / (F * imW) (in cm)

#image width - 6000 px
imW<-c(6000)
#image height - 4000 px
imH<-c(4000)
#drone height & convert from m to cm
H<-100*(image$GPSAltitude)
#focal lens length & convert from mm to cm
f<-(20/10)
#sensor length & convert from mm to cm
Sw<-(15.6/10)

#GSD cm/pixel
GSD<-(H * Sw) / (f * imW)
#2.5649

#Width of image? 153.9m
(6000*2.5649)/100

#pixel distance between two points (center of image and nest)
dist=sqrt((pxy$y-2000)^2+(pxy$x-3000)^2)
#distance in pixels
dist
#convert to distance in m
dist_m<-(dist*GSD)/100
dist_m

#Calculate bearing in python & run Vincenty Formula in Python - Visual Studio Explorer

#Direct Vincenty Formula:
#((ϕ2, λ2), b2) = vfwd((ϕ1, λ1), b1, g), (11)
#which calculates the destination point (ϕ2, λ2) and the final
#bearing b2 given the starting point (ϕ1, λ1), initial bearing b1,
#and the great circle distance (short enough distance we can use linear) g from the starting point to the destination.

