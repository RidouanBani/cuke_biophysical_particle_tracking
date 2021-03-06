type_year <- commandArgs(TRUE)[1]
PLD <- commandArgs(TRUE)[2]
bin <- commandArgs(TRUE)[3]

print("output from dispersal_distance.R")

print(type_year)
print(PLD)
print(bin)

library(rgdal)
library(maptools)
library(rgeos)
library(raster)
library(plyr)
library(dplyr)
library(fields)



proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"


data(wrld_simpl)
world <- wrld_simpl
BC <- world[world$NAME=="United States"|world$NAME=="Canada", ]
BC <- BC[,]
plot(BC)
BCshp <- spTransform(BC, crs(proj))
ras <- raster(nrow=500, ncol=500)
crs(ras) <- crs(BCshp)
extent(ras) <- extent(c(lon1 = -140, lon2 = -120, lat1 = 45, lat2 = 60))
BCras <- is.na(rasterize(BCshp, ras))
BCras[BCras==0] <- 9999
# plot(BCras)
# create a Transition object from the raster
# this calculation took a bit of time
library(gdistance)
tr <- transition(BCras, function(x) 1/mean(x), 16)
tr <- geoCorrection(tr,type="c")



#### open tabulated output data and grid shapefile ####
type <- substr(type_year,1,1)
year <- substr(type_year,2,5)
fn <- paste0(type,"_data_",year,"_pld_",PLD,"_bin_",bin,".csv")
print(fn)

#### open tabulated output data ####
data <- read.csv(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp/",fn))
# unlink(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/",fn))


#### calculate Euclidean distance ####
print("calculate Euclidean distance")
data$Euclidist <- adply(data,1,mutate,
						dist=(rdist.earth(matrix(c(long0,lat0,long,lat),ncol=2,byrow=T),miles=F)[2,1]),.progress="text")$dist



#### Create subset chunks that can be used by dplyr for in-sea distance ####
#print("chunk the data")

# data$IDS=as.numeric(rownames(data))
#data$chunks=cut(data$IDS,1000)


SeaDist=function(x,tr){
	proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
	
	release_loc <- data.frame(long=x$long0,lat=x$lat0, stringsAsFactors=F)
	coordinates(release_loc) <- ~ long + lat
	proj4string(release_loc) <- CRS(proj)
	
	settle_loc <- data.frame(long=x$long,lat=x$lat, stringsAsFactors=F)
	coordinates(settle_loc) <- ~ long + lat
	proj4string(settle_loc) <- CRS(proj)
	
	seaDist=diag(costDistance(tr,settle_loc,release_loc)/1000)
	return(seaDist)
}

print("calculate in-sea distance")
#### subsetted version of in-sea distance ####
#Dists=filter(data,chunks %in% unique(data$chunks))%>%group_by(chunks)%>%do(Dispersal=SeaDist(.,tr=tr))

print("unlist")
#unlist the object
#dispersal.distance=unlist(Dists$Dispersal)

print("add to data")
#add the object to the data
#data2=filter(data,chunks %in% unique(data$chunks))
#data2$sea_dist=dispersal.distance

data$sea_dist <- SeaDist(data,tr)

print("filter")
#filter wonky results
#data2$sea_dist[data2$sea_dist>2000] <- data2$Euclidist[data2$sea_dist>2000]




if((length(readLines(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp/",fn)))-1)==length(data$Euclidist)){
#if((length(readLines(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp/",fn)))-1)==length(data2$Euclidist)){
	print("write data in temp2")
	write.csv(data,paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp2/",fn))
	#write.csv(data2,paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp2/",fn))
} else {
	print("original length")
	print(length(readLines(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp/",fn))))
	print("new length")
	print(length(data2$Euclidist))
}

                 
