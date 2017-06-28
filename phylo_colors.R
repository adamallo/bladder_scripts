library(cowplot)
library(phangorn)
library(ggtree)

setwd("/Users/Diego/Desktop/bladder")
genotypeData=read.csv("genotypes.csv")

#Adding fake normal for rooting purposes
genotypeData$Sample=as.character(genotypeData$Sample)
genotypeData[9,]=c(0,rep(0,ncol(genotypeData)-1))
genotypeData[9,1]="N"
#####################################################

names=genotypeData[,1]
genData=as.matrix(genotypeData[,-1])
rownames(genData)=names

pcs=prcomp(t(genData))$rotation[,c(1,2,3)] ##I cannot scale for variances=1 due to the N sample. Actually, I am not 100% sure I should do it either way.
umat=svd(pcs)$u
rownames(umat)=rownames(pcs)

rescale=function(x,min=0,max=200)
{
  return((x-min(x))*(max-min)/(max(x)-min(x))+min)
}

torgb=function(x)
{
  return(rgb(red=x[1],green=x[2],blue=x[3],maxColorValue=255))
}

rgbdata=apply(umat,2,rescale)

colors=apply(rgbdata,1,torgb)
datacolors=as.data.frame(colors)

colorplot=ggplot(datacolors,aes(x=as.factor(rownames(datacolors)),y=1,fill=names))+geom_tile()+scale_fill_manual(values=colors)
save_plot("colorplot.svg",colorplot,base_height = 8)

##MP Exact (Branch and bound)
phydata=as.phyDat(genData, type="USER", levels = c(0, 1))
tree=bab(phydata,tree = NULL,trace = 3)
bestree=tree[[1]]
finaltree=acctran(bestree,phydata)

set.seed(20)
bstrees=bootstrap.phyDat(phydata,pratchet,bs=1000)
treebs=plotBS(tree = bestree,BStrees = bstrees,type = "phylogram")
rootedbs=root(treebs,outgroup = "N")
write.tree(rootedbs,file="patient1MPbab.tree")
write.nexus(rootedbs,file="patient1MPbab.nex")

treeforggtree=read.nexus("patient1MPbab.nex")
treeframe=fortify(treeforggtree)
treeframe$posteriorasterisk=as.character(ifelse(as.numeric(treeframe$label)>=80,"*",""))

root=which(treeframe$label=="N")
treeframe[root,"x"]=-treeframe[root,"x"]

treeplot=ggtree(treeframe,size=1.5)+
  theme_tree(legend.position='right')+
  geom_text2(aes(label=posteriorasterisk),vjust=+0.8,hjust=-0.5,color="black",size=rel(8.5)) +
  geom_tiplab(offset = 3,linesize = 0.5,size=rel(5),aes(color=label))+
  geom_text(aes(x=branch, label=branch.length, vjust=-.5))+
  scale_color_manual(values=colors,guide=FALSE) +
  ggplot2::xlim(-3,250)

save_plot(plot=treeplot,filename = "tree.pdf",base_height = 6,base_aspect_ratio = 2)

##NJ
njtree=nj(dist.gene(genData))
write.tree(njtree,file="patient1nj.tree")

##Number of mutations
apply(genData,1,sum)
