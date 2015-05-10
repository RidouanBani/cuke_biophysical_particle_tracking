print("output from distances_scheduler.R")

ready_filenames <- list.files(path="/sb/project/uxb-461-aa/Cuke-MPA/positions/", pattern=glob2rx("*_data_*"), full.names=FALSE,recursive=FALSE)
done_filenames <- list.files(path="/sb/project/uxb-461-aa/Cuke-MPA/positions/processed/", pattern=glob2rx("*_data_*"), full.names=FALSE,recursive=FALSE)
system('qstat -u rdaigle >queue.txt')
system('tail -n +6 queue.txt > queue2.txt')
Q <- read.table("queue2.txt", quote="\"")
unlink('queue*')
names(Q)=c('job_ID','Username','Queue','jobname','sessID','NDS','TSK','Rmem','Rtime','S','Etime')
dc <- as.character(Q$jobname[substr(Q$jobname,1,2)=='dc'])
dc <- data.frame(matrix(unlist(sapply(dc,strsplit,"_")),nrow=length(dc),ncol=3,byrow=T))
names(dc)=c('job','type_year','PLD')
dc$type <- substr(dc$type_year,1,1)
dc$year <- substr(dc$type_year,2,5)
current_filenames <- paste0(dc$type,"_data_",dc$year,"_pld_",dc$PLD,".csv")

# ds <-as.character(Q$jobname[substr(Q$jobname,1,2)=='ds'])
# ds <- matrix(unlist(sapply(ds,strsplit,"_")),nrow=length(ds),ncol=4,byrow=T)



filenames <- ready_filenames[!( ready_filenames %in% done_filenames)]
filenames <- filenames[!( filenames %in% current_filenames)]

filenames <- data.frame(matrix(unlist(sapply(filenames,strsplit,"_")),nrow=length(filenames),ncol=5,byrow=T))
names(filenames)=c('type','txt','year','txt2','pld')
filenames$pld <- substr(filenames$pld,1,nchar(as.character(filenames$pld))-4)


while(length(Q$jobname)<1500 | length(dc$job)<10){
	dc <- rbind(dc,data.frame(job='dc',type_year=paste0(filenames$type[1],filenames$year[1]),PLD=filenames$pld[1],type=filenames$type[1],year=filenames$year[1]))
	system(paste0('qsub -A uxb-461-aa -N d_',filenames$type[1],filenames$year[1],filenames$pld[1],' -v t=',filenames$type[1],filenames$year[1],',P=',filenames$pld[1],' ./distances.sh'))
	filenames <- filenames[-1,]
	Sys.sleep(10*60)
	system('qstat -u rdaigle >queue.txt')
	system('tail -n +6 queue.txt > queue2.txt')
	Q <- read.table("queue2.txt", quote="\"")
	unlink('queue*')
	names(Q)=c('job_ID','Username','Queue','jobname','sessID','NDS','TSK','Rmem','Rtime','S','Etime')
}


print("re-start scheduler")
delayH <- as.numeric(strftime(Sys.time(),"%H"))+3
delayM <- as.numeric(strftime(Sys.time(),"%M"))
if(delayM>60) delayH <- delayH+1
if(delayM>60) delayM <- delayM-60
delaytime <- as.numeric(paste0(delayH,formatC(delayM, width = 2, format = "d", flag = "0")))
if(delaytime>2400) delaytime <- delaytime-2400
command <- paste0("qsub -a ",formatC(delaytime, width = 4, format = "d", flag = "0")," -A uxb-461-aa ./distances_scheduler.sh")
print(command)
system(command)



