#Eagleson Water Balance model with s.o and M as state variables
#This is coded up with parameters from Clinton, MA clay parameters
#Need to check lambda parameters and gamma.depth


###Goal: 
###find s.o and M such that Pr.modeled = annual Precip
###in other words, such that ET.model.a(M,kv)-Runoff.model(s.o)-Annual Precip=0
M.1<-as.list(runif(200)) #samples from uniform distribution to get values from 0 to 1
s.o<-M.1 #take the same values for s.o (also from 0 to 1)
#set.seed(10)

#create matrix of all possible M and s.o combinations to run in the water balance function
m.so<-expand.grid(M.1,s.o)


#basic water balance
#water.bal<-function(M,s.o){
#abs(ET.model.a(M)+Runoff(s.o)-mPa)
#}


#ET.model.a<-((m.n*e.p)/alpha)*(1-M)*beta.s(M,k.v) + M*k.v

#m.n=mean number rainstorms per year
#Beta.s=avg bare soil evap efficiency
#M=vegetation canopy denisity
#ET.model.a=evaporation component of water balance

#in Eagleson Soil vegetation systems 1, he approximates beta.s
#create approximate water balance




#####################################
#define site based model parameters##
#####################################
if(site="Clinton"){
  m.n<-109 # mean number of storms per year # obtained from Eagleson: Climate, Soil, and Vegetation
  e.p<-0.15 # average bare soil potential evaporation rate
  m.Pa<-102.6 #mean annual precipitation in cm
  m.r<-0.32 #mean storm depth--double check value
  m.b<-2.98 #in units of days
  m.t<-365 #mean rainy season
  alpha<-1/m.b #one over mean time between storms
  #Eagleson (2002) has poisson pulse parameters for a number of stations in Appendix F
  #for Clinton, MA, I used parameters for Boston (Station ID 14 in eagleson
  lambda<-1.47*2.54 #may be incorrect, changed inches to cm #scale parameter for gamma distribution of storm depths (1/cm)
  gamma.depth<-0.50 #these may be incorrect #shape parameter for the gamma distribution of storm depths
}else{
  if(site="SantaPaula"){
    m.n<-109 # mean number of storms per year # obtained from Eagleson: Climate, Soil, and Vegetation
    e.p<-0.27 # average bare soil potential evaporation rate
    m.Pa<-54.4 #mean annual precipitation in cm
    m.r<-1.4 #mean storm depth--double check value
    m.b<-10.4 #in units of days
    m.t<-212 #mean rainy season
    alpha<-1/m.b #one over mean time between storms
    #Eagleson (2002) has poisson pulse parameters for a number of stations in Appendix F
    #for Clinton, MA, I used parameters for Boston (Station ID 14 in eagleson
    lambda<-1.86*2.54 #may be incorrect, changed inches to cm #scale parameter for gamma distribution of storm depths (1/cm)
    gamma.depth<-0.25 
  }
}

#treat M and k.v as state variables

#create a list of these params to feed into the water.bal model

#the general water balance function



water.bal<-function(M, s.o, site, type){
  #####################################
  #define site based model parameters##
  #####################################
  if(site=="Clinton"){
    m.n<-109 # mean number of storms per year # obtained from Eagleson: Climate, Soil, and Vegetation
    e.p<-0.15 # average bare soil potential evaporation rate
    m.Pa<-102.6 #mean annual precipitation in cm
    m.r<-0.32 #mean storm depth--double check value
    m.b<-2.98 #in units of days
    m.t<-365 #mean rainy season
    alpha<-1/m.b #one over mean time between storms
    #Eagleson (2002) has poisson pulse parameters for a number of stations in Appendix F
    #for Clinton, MA, I used parameters for Boston (Station ID 14 in eagleson
   # lambda<-1.47*2.54
    #may be incorrect, changed inches to cm #scale parameter for gamma distribution of storm depths (1/cm)
    gamma.depth<-0.50
   lambda<-gamma.depth/(m.Pa/m.n) #these may be incorrect #shape parameter for the gamma distribution of storm depths
  }else{
    if(site=="SantaPaula"){
      m.n<-15.7 # mean number of storms per year # obtained from Eagleson: Climate, Soil, and Vegetation
      e.p<-0.27 # average bare soil potential evaporation rate
      m.Pa<-54.4 #mean annual precipitation in cm
      m.r<-1.4 #mean storm depth--double check value
      m.b<-10.42 #in units of days
      m.t<-212 #mean rainy season
      c<-4.95
      alpha<-1/m.b #one over mean time between storms
      #Eagleson (2002) has poisson pulse parameters for a number of stations in Appendix F
      #for Clinton, MA, I used parameters for Boston (Station ID 14 in eagleson
      gamma.depth<-0.37 
      lambda<-gamma.depth/(m.Pa/m.n) #may be incorrect, changed inches to cm #scale parameter for gamma distribution of storm depths (1/cm)
      
    }}
  
#define soil paramters
  if(type == "clay"){
  Ksat<-0.72 #k saturation
  Matrix.pot<-25 #soil matrix potential
  c<-12 #for clay
  n<-0.45 #soil porosity, for clay
  
  h.o<-0.1 # small constant value for surface water retention
  k.v<-1# for santapaula
  #M<-0.5 # ranges from 0 to 1 (but cant be one)
  w<-0 #assume no capillary rise
  }else{
    if(type =="clayloam"){
      Ksat<-2.0 #k saturation
      Matrix.pot<-19 #soil matrix potential
      c<-10 #for clayloam
      n<-0.35 #soil porosity, for clay
      
      ##these values set to constant for this purpose
      h.o<-0.1 # small constant value for surface water retention
      k.v<-1# unstressed transpiration
      #M<-0.5 # ranges from 0 to 1 (but cant be one)
      w<-0 #assume no capillary rise
  }else{
    if(type =="siltloam"){
      Ksat<-8.64 #k saturation
      Matrix.pot<-166 #soil matrix potential
      c<-6 #for clayloam
      n<-0.35 #soil porosity, for clay
      
      ##these values set to constant for this purpose
      h.o<-0.1 # small constant value for surface water retention
      k.v<-1.0 #unstressed transpiration
      #M<-0.5 # ranges from 0 to 1 (but cant be one)
      w<-0 #assume no capillary rise
  }else{
    if(type =="sandyloam"){
      Ksat<-18 #k saturation
      Matrix.pot<-200 #soil matrix potential
      c<-4 #for clayloam
      n<-0.25 #soil porosity, for clay
      
      ##these values set to constant for this purpose
      h.o<-0.1 # small constant value for surface water retention
      k.v<-1# unstressed transpiration
      #M<-0.5 # ranges from 0 to 1 (but cant be one)
      w<-0 #assume no capillary rise
  
  }}}}
  
#k.v<-0.097/e.p #unstressed composite transpiration rate/e.p
#k.v<-1
#####################
#####Beta.s model####
#####################
#bets.s model needs k.v and s.o
require(gsl)
gamma.ratio<-pgamma(gamma.depth, lambda*h.o)/gamma(gamma.depth)

#define beta.s function
#beta.s.approx<-function(M,s.o){
 # B<- ((1-M)/(1+M*k.v-w/e.p))+((k.v*(M^2)+(1-M)*w/e.p)/((2*(1+M*k.v-w/e.p)^2)))
  
#  C<- 1/2*(M*k.v-w/e.p)^(-2)
#ex.diffus.approx<-(0.3477-(0.0731*c)+(0.0062*c^2)-0.0002*c^3)
  
 # E<-function(s.o){((alpha*n*(c-3)*Ksat*Matrix.pot*ex.diffus.approx/(pi*e.p^2))*s.o^((c+5)/2))}
  
  
 #(1-exp(-1*alpha*h.o/e.p)*(exp(-1*B*E(s.o))*(1+M*k.v+
  #                                         (2*B)^(1/2)*E(s.o)-w/e.p)-exp(-1*C*E(s.o))*(M*k.v+(2*C)^(1/2)*E(s.o-w/e.p)-
   #                           (2*E(s.o))^(1/2)*(pgamma(3/2,C*E(s.o))-pgamma(3/2,B*E(s.o))))))
  
#}

beta.s<-function(M, s.o){
ex.diffus.approx<-(0.3477-(0.0731*c)+(0.0062*c^2)-0.0002*c^3)
 B<- ((1-M)/(1+M*k.v-w/e.p))+((k.v*(M^2)+(1-M)*w/e.p)/((2*(1+M*k.v-w/e.p)^2)))
  
C<- 1/2*(M*k.v-w/e.p)^(-2)
  
E<-((alpha*n*(c-3)*Ksat*Matrix.pot*ex.diffus)/(pi*e.p^2))*s.o^((c+5)/2)
  
 beta<-(gamma.ratio)-((1+(alpha*h.o/e.p)/lambda*h.o)^(-1*gamma.depth))*((pgamma(gamma.depth, (lambda*h.o+alpha*h.o/e.p)))/gamma(gamma.depth))*exp(-B*E)+
   (1+gamma.ratio)*(1-exp(-B*E-alpha*h.o/e.p)*(1+M*k.v+(2*B)^(1/2)*E-w/e.p)+
    exp(-C*E-alpha*h.o/e.p)*(M*k.v +(2*C)^(1/2)*E-w/e.p)+
  
    ((2*E)^(1/2))*exp(-alpha*h.o/e.p)*(pgamma(3/2, C*E)-pgamma(3/2,B*E)) + 
     ((1+(1+(alpha*h.o/e.p)/lambda*h.o))^(-1*gamma.depth))*(pgamma(gamma.depth, lambda*h.o+(alpha*h.o/e.p))/gamma(gamma.depth))*(sqrt(2*E)*(pgamma(3/2, C*E)-pgamma(3/2,B*E))+
           exp(-C*E)*(M*k.v +(2*C)^(1/2)*E-w/e.p) -
             exp(-B*E)*(M*k.v+(2*B)^(1/2)*E-w/e.p)))
}



##########################################
#define exfiltration diffusivity & runoff#
##########################################


#Runoff Function:

Runoff<-function(s.o){
## define the integrated function
  
## integrate the function from 0 to s.o
#b$value provides the value of the intergral
in.diffus.approx<-function(s.o){((5/3)+(1/2)*(c+1)*(1-s.o)^(1.425-0.0375*(c+1)/2))^(-1)}
###Runoff model

mPa<-m.Pa # mean annual precipitation in mm, not sure if this needs to be changed to cm
  G<-(Ksat*(m.n*m.r)/m.Pa)*(((1+s.o^c)/2)-(w/Ksat))


  sigma<-function(s.o){((5*n*(c-3)*lambda^2*Ksat*Matrix.pot*in.diffus.approx(s.o)*m.r)/12*pi*gamma.depth^2)^(1/3)*(1-s.o)^(2/3)}

  Runoff.a<-m.Pa*(exp(-G-2*sigma(s.o))*gamma(sigma(s.o)+1)*sigma(s.o)^(-sigma(s.o))+((m.t*Ksat)/m.Pa)*s.o^c)
}


#basic ET.model.a functions repeated from above
ET.model.a<-function(M, s.o){
  ((m.n*e.p)/alpha)*(1-M)*beta.s(M,s.o) + M*k.v
}


abs(ET.model.a(M,s.o)+Runoff(s.o)-m.Pa)
  
}

# this appears to work well for Clinton, MA, but not SantaPaula, CA
silt.loam<-mapply(water.bal, M=m.so$Var1, s.o=m.so$Var2,site="SantaPaula",type="siltloam") # this is to test if R can handle the large m.so
clay.loam<-mapply(water.bal, m.so$Var1, m.so$Var2,site="SantaPaula", type="clayloam")
sandy.loam<-mapply(water.bal, m.so$Var1, m.so$Var2,site="SantaPaula", type="sandyloam")
clay<-mapply(water.bal, m.so$Var1, m.so$Var2, site="SantaPaula", type="clay")
#test3 now contains the output of water.bal for all combinations of 100x100 values between 0 and 1
#to determine which values of M and s.o close the water balance, we need to keep values where abs(ET.model.a(M,s.o)+Runoff(s.o)-mPa) is ~ 0

#lets say we are willing to accept M and s.o values that fall within +/-5% of the Mean annual precidp
#this is not really the best way of doing this
wb.silt<-cbind(m.so, silt.loam)
wb.silt.small<-wb.silt[wb.silt$silt.loam < (m.Pa*0.05)^2,]
#if we keep the object as the square (Pa-Pmodel)^2
wb.sandy<-cbind(m.so, sandy.loam)
wb.sandy.small<-wb.sandy[wb.sandy$sandy.loam <(m.Pa*0.05)^2,]

wb.clay.loam<-cbind(m.so, clay.loam)
wb.clay.loam.small<-wb.clay.loam[wb.clay.loam$clay.loam < (m.Pa*0.05)^2,]

wb.clay<-cbind(m.so, clay)
wb.clay.small<-wb.clay[wb.clay$clay < (m.Pa*0.05)^2,]

plot(wb.clay.small$Var1,wb.clay.small$Var2,type="p", col="red", xlim=c(0,1),ylim=c(0,1))
lines(wb.clay.loam.small$Var1,wb.clay.loam.small$Var2,type="p", col="blue")
lines(wb.sandy.small$Var1,wb.sandy.small$Var2,type="p", col="green")
lines(wb.silt.small$Var1,wb.silt.small$Var2,type="p", col="purple")
#plot(wb.small$Var1,wb.small$Var2, type="l", col="red", main="Isoclines of parameter combinations (M,s.o) that satisfiy water balance closre for Clinton, MA", xlab="M, Canopy density", ylab="Equlibrium soil moisture, s.o")

#test<-data.frame(matrix(unlist(wb.clay.loam), 10000))




#trying to find a better way to find the s.o value for each M with the lowest Mean squared error


clay1<-data.frame(matrix(unlist(wb.clay), 40000))
silt1<-data.frame(matrix(unlist(wb.silt), 40000))
sand1<-data.frame(matrix(unlist(wb.sandy), 40000))
clayloam1<-data.frame(matrix(unlist(wb.clay.loam), 40000))

#trying to find a better way to find the s.o value for each M with the lowest Mean squared error


#or M
require(reshape)
clay.by <- cast(clay1, X2~X1, min,value="X3")
min.clay<-matrix(0,201,2)
for(i in 2:201){
  min.clay[i,1]<-clay.by[which.min(clay.by[,i]),]$X2
  
}
min.clay[1:200,2]<-as.numeric(colnames(clay.by[,2:201]))
plot(min.clay[,2], min.clay[,1], type="p", xlim=c(0,1))


silt.by <- cast(silt1, X2~X1, min, value="X3")
min.silt<-matrix(0,201,2)
for(i in 2:201){
  min.silt[i,1]<-silt.by[which.min(silt.by[,i]),]$X2
}
min.silt[1:200,2]<-as.numeric(colnames(silt.by[,2:201]))
plot(min.silt[,2], min.silt[,1], type="p", xlim=c(0,1), ylim=c(0,1), col="purple")

require(reshape)
sand.by <- cast(sand1, X1~X2, min,value="X3")
min.sand<-matrix(0,201,2)
for(i in 2:201){
  min.sand[i,1]<-sand.by[which.min(sand.by[,i]),]$X1
}
min.sand[1:200,2]<-as.numeric(colnames(sand.by[,2:201]))
plot(min.sand[,2], min.sand[,1], type="p", xlim=c(0,1), ylim=c(0,1), col="green")

require(reshape)
clayl.by <- cast(clayloam1, X1~X2, min,value="X3")
min.clay.l<-matrix(0,201,2)
for(i in 2:201){
  min.clay.l[i,1]<-clayl.by[which.min(clayl.by[,i]),]$X1
}
min.clay.l[1:200,2]<-as.numeric(colnames(clayl.by[,2:201]))
plot(min.clay.l[,2], min.clay.l[,1], type="p", xlim=c(0,1), ylim=c(0,1), col="red")
