#Potential solution to our exercise.


guild <- tax$Guild 
sap <- which(guild=="Saprotroph")

tax_sap <- tax[sap,]
tax_sap
keep <- tax_sap$ASV_ID

ab.sap <- ab[,keep]
