type_year <- commandArgs(TRUE)[1]
PLD <- commandArgs(TRUE)[2]

print("output from distances_cleanup.R")
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
# unlink(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp/",fn2,"*"))
# unlink(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp2/",fn2,"*"))
# unlink(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/processed/",fn2,"*"))

splits <- 200
filenames <- NULL
#for(bin in 1){
for(bin in seq_along(unique(data$bin))){
	n <- dim(data[data$bin==bin,])[1]
	for(i in 1:splits){
		first <- letters[as.numeric(substr(formatC(i, width = 3, format = "d", flag = "0"),1,1))+1]
		second <- letters[as.numeric(substr(formatC(i, width = 3, format = "d", flag = "0"),2,2))+1]
		third <- letters[as.numeric(substr(formatC(i, width = 3, format = "d", flag = "0"),3,3))+1]	
		bins <- paste0(first,second,third,bin)
		print(paste("assesing bin",bins))
		filenames <- c(filenames,paste0(fn2,"_bin_",bins,".csv"))
		command <- paste0("qsub -A uxb-461-aa -N ds_",type_year,"_",PLD,"_",bins," -v t=",type_year,",P=",PLD,",b=",bins," ./distances_sub.sh")
		if(!file.exists(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp2/",fn2,"_bin_",bins,".csv"))){
			print(paste("writing bin ",bins))
			write.csv(split(data[data$bin==bin,], rep(1:splits, each=(ceiling(n/splits))))[[i]],paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp/",fn2,"_bin_",bins,".csv"))
			print(command)
			system(command)
		} else if (dim(split(data[data$bin==bin,], rep(1:splits, each=(ceiling(n/splits))))[[i]])[1]!=(length(readLines(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp2/",fn2,"_bin_",bins,".csv")))-1)){
			print(paste("file length error, writing bin ",bins))
			unlink(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp/",fn2,"_bin_",bins,".csv"))
			unlink(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp2/",fn2,"_bin_",bins,".csv"))
			write.csv(split(data[data$bin==bin,], rep(1:splits, each=(ceiling(n/splits))))[[i]],paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp/",fn2,"_bin_",bins,".csv"))
			print(command)
			system(command)
		}
	}
}
IDS <- data$IDS
rm(data)

Sys.sleep(5*60)
if(all(file.exists(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp2/",filenames)))){
	print(paste("recombining",fn))
	filenames <- list.files(path="/sb/project/uxb-461-aa/Cuke-MPA/positions/temp2/", pattern=glob2rx(paste0(fn2,"_bin_*")), full.names=TRUE,recursive=T)
    datalist <- lapply( filenames, read.csv)
    data <- rbindlist(datalist)
	data <- data[with(data, order(data$IDS)), ]
	if(identical(IDS,data$IDS)){
		print(paste("writing out",fn))
		write.csv(data,paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/processed/",fn))
		unlink(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp/",fn2,"_bin_*"))
		unlink(paste0("/sb/project/uxb-461-aa/Cuke-MPA/positions/temp2/",fn2,"_bin_*"))
	} else {
		print("IDs not identical")
		print(paste("length of original",length(IDS)))
		print(paste("length of processed",length(data$IDS)))
	}
} else {
	print("re-start cleanup")
	delayH <- as.numeric(strftime(Sys.time(),"%H"))
	delayM <- as.numeric(strftime(Sys.time(),"%M"))+15
	if(delayM>=60) delayH <- delayH+1
	if(delayM>=60) delayM <- delayM-60
	delaytime <- as.numeric(paste0(delayH,formatC(delayM, width = 2, format = "d", flag = "0")))
	if(delaytime>2400) delaytime <- delaytime-2400
	command <- paste0("qsub -a ",formatC(delaytime, width = 4, format = "d", flag = "0")," -A uxb-461-aa -N dc_",type_year,"_",PLD," -v t=",type_year,",P=",PLD," ./distances_cleanup.sh")
	print(command)
	system(command)
}


