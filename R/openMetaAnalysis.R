openMetaAnalysis <- function(content,lefthand,righthand, type, cofactorlabel, topic, theme) {
temp <- content
# http://stat.ethz.ch/R-manual/R-devel/library/base/html/regex.html
temp <- gsub('\n', '', fixed = TRUE, temp, perl = TRUE)
#temp <- gsub("\\s+$", "", temp, perl = TRUE) #Removing trailing whitespace
#temp <- gsub(",+$", "", temp, perl = TRUE) #Remove trailing comma if accidentally added by user online
temp <- gsub("\t", ' ', fixed = TRUE, temp)
temp <- gsub(',', '","', fixed = TRUE, temp)
temp <- paste('"',temp,'"',sep = '')
temp <- paste('Mymatrix <- matrix(c(',temp,'), ncol=6, byrow=TRUE,dimnames = list(NULL, c("Study","exp_events", "exp_total","control_events","control_total","cofactor")))')
x<-eval(parse(file = "", n = NULL, text = temp))
myframe <- data.frame (x)
myframe$Study<-gsub("\'", '', fixed = TRUE, myframe$Study)
myframe$Study<-as.character(str_trim(myframe$Study))
myframe$exp_events<-as.numeric(as.character(str_trim(myframe$exp_events)))
myframe$exp_total<-as.numeric(as.character(str_trim(myframe$exp_total)))
myframe$control_events<-as.numeric(as.character(str_trim(myframe$control_events)))
myframe$control_total<-as.numeric(as.character(str_trim(myframe$control_total)))
attach(myframe)
KUBlue = "#0022B4"
SkyBlue = "#6DC6E7"
#par(col.axis="black" ,col.lab=KUBlue ,col.main=KUBlue ,col.sub=KUBlue, col=KUBlue,new = TRUE) #bg=SkyBlue)

if (type=="ignore")
	{
	meta1 <- metabin(exp_events, exp_total, control_events,control_total, data=myframe, sm="OR", method="I", studlab=paste(Study))
	#forest(meta1, leftcols="studlab",rightcols=FALSE, xlim=c(0.1, 10),ff.hetstat="plain",col.diamond="blue", col.diamond.lines="blue",comb.fixed=FALSE,print.tau2=FALSE)
	forest(meta1, xlim=c(0.1, 10),ff.hetstat="plain",col.diamond="blue", col.diamond.lines="blue",comb.fixed=FALSE,print.tau2=FALSE)
	}
if (type=="subgroup")
	{
	myframe$cofactor<-gsub("\'", '', fixed = TRUE, myframe$cofactor)
	myframe$cofactor<-as.character(str_trim(myframe$cofactor))
	meta1 <- metabin(exp_events, exp_total, control_events,control_total, data=myframe, sm="OR", method="I", studlab=paste(Study),byvar=cofactor)
	#forest(meta1, leftcols="studlab",rightcols=FALSE, xlim=c(0.1, 10),ff.hetstat="plain",col.diamond="blue", col.diamond.lines="blue",comb.fixed=FALSE,print.tau2=FALSE)
	forest(meta1, xlim=c(0.1, 10),ff.hetstat="plain",col.diamond="blue", col.diamond.lines="blue",comb.fixed=FALSE,print.tau2=FALSE)
	}
if (type=="metaregression")
	{
	myframe$cofactor<-as.numeric(as.character(str_trim(myframe$cofactor)))
	meta1 <- meta.DSL(myframe[["exp_total"]], myframe[["control_total"]], myframe[["exp_events"]], myframe[["control_events"]],names=Study,conf.level=0.95)
	studyweights <- 1 / (meta1$tau2 + meta1$selogs^2)
	x <- myframe$cofactor
	y <- meta1$logs
	metaregression <- lm(y ~ x , data = myframe , weights = studyweights)
	plot(y ~ x, data = myframe, main=paste("Meta-regression of ", topic), xlab="", ylab="",ylim=c(-1,1),xaxs="r",type="n")
	points(y ~ x,cex=10*studyweights/sum(studyweights),pch=21,bg='blue',col='blue')
	text(x=x, y=y,labels=paste(Study), cex=0.65, pos=4,adj=0,font=1,col='black')
	abline(h=0, v=0, col = "gray90")
	abline(lm(y ~ x, data = myframe, weights = studyweights))
	legendtext = "Correlation of cofactor and odds ratio:\n"
	legendtext = paste(legendtext,"All studies (" ,length(myframe$Study),"):",round(summary(metaregression)$coef[2,1],3),", p =",round(summary(metaregression)$coefficients[2,4],3))
	legend("topright", legend=legendtext,lty=1, lwd = 2, inset=0.05)
	mtext(side=1,line=2,paste("Cofactor",cofactorlabel), font=2)
	mtext(side=2,line=3,"Odds ratio transformed to natural log (Ln)", font=2)
	mtext(side=2,line=2,"(0 indicates odds ratio = 1)")
	#mtext(side=3,line=0.5,"(Ln odds ratio below 0 favors treatment)")
	mtext(side=1,line=3,cex=0.9,adj=0,"Notes:", font=2)
	mtext(side=1,line=4,cex=0.9,adj=0, "1. For each study, the size of the point is its weight in the meta-regression.", font=1)
	}
#if(theme=="KU"){display_logo(x=1.2,y=0.05)}
}
