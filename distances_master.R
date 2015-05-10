type_year <- commandArgs(TRUE)[1]
PLD <- commandArgs(TRUE)[2]

print(type_year)
print(PLD)

type <- substr(type_year,1,1)
year <- substr(type_year,2,5)
fn <- paste0(type,"_data_",year,"_pld_",PLD,".csv")

print(paste("splitting",fn))

require(data.table)

data <- read.csv(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/",fn))
data$IDS <- as.numeric(rownames(data))
fn2 <- substr(fn,1,nchar(fn)-4)
unlink(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp/",fn2,"*"))
unlink(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp2/",fn2,"*"))
unlink(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/processed/",fn2,"*"))

splits <- 20
filenames <- NULL
#for(bin in 1){
for(bin in seq_along(unique(data$bin))){
	n <- dim(data[data$bin==bin,])[1]
	for(i in 1:splits){
		bins <- paste0(letters[i],bin)
		print(paste("writing bin ",bins))
		write.csv(split(data[data$bin==bin,], rep(1:splits, each=(ceiling(n/splits))))[[i]],paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp/",fn2,"_bin_",bins,".csv"))
		filenames <- c(filenames,paste0(fn2,"_bin_",bins))
		command <- paste0("qsub -A uxb-461-aa -N ds_",type_year,"_",PLD,"_",bins," -v t=",type_year,",P=",PLD,",b=",bins," ./distances_sub.sh")
		print(command)
		system(command)
	}
}
print("start cleanup")
delayH <- as.numeric(strftime(Sys.time(),"%H"))
delayM <- as.numeric(strftime(Sys.time(),"%M"))+45
if(delayM>60) delayH <- delayH+1
if(delayM>60) delayM <- delayM-60
delaytime <- as.numeric(paste0(delayH,formatC(delayM, width = 2, format = "d", flag = "0")))
if(delaytime>2400) delaytime <- delaytime-2400
command <- paste0("qsub -a ",formatC(delaytime, width = 4, format = "d", flag = "0")," -A uxb-461-aa -N dc_",type_year,"_",PLD," -v t=",type_year,",P=",PLD," ./distances_cleanup.sh")
print(command)
system(command)
