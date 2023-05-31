# Proyecto #2

if(!require(psych)){install.packages("psych")}
if(!require(FSA)){install.packages("FSA")}
if(!require(ggplot2)){install.packages("ggplot2")}
if(!require(rcompanion)){install.packages("rcompanion")}
if(!require(car)){install.packages("car")}
if(!require(multcompView)){install.packages("multcompView")}
if(!require(multcomp)){install.packages("multcomp")}
if(!require(lsmeans)){install.packages("lsmeans")}
if(!require(phia)){install.packages("phia")}
if(!require(stringr)){install.packages("stringr")}

library(rcompanion)
library(ggplot2)
library(car)
library(repr)
library(dplyr)
library(stringr)
library(data.table)

# Directorio donde se encuentra el archivo
setwd(this.path::here())


# Se leen los datos y se guardan en la variable Data
#datos-auto-integrators.txt
my_data <- read.table("data-complete.txt", header=TRUE, 
                      colClasses = c("factor", "factor","factor", "factor", "factor", "double", "factor", "factor"))

#Ignoramos los factores que ya tenemos configurados como 2K en la columna Configuration

my_data = my_data[, setdiff(names(my_data), c("Accelerator", "Sampler"))]
my_data$Configuration <- gsub('-', '_', my_data$Configuration)
my_data$Filename <- gsub('.pbrt', '', my_data$Filename)

my_data$Configuration <- factor(my_data$Configuration, levels = unique(my_data$Configuration)) #Important to do this
my_data$Filename <- factor(my_data$Filename, levels = unique(my_data$Filename)) #Important to do this

Data = my_data

headTail(Data)
str(Data)
summary(Data)

# Diagrama de cajas - Recordar que los bigotes es el rango
M = tapply(Data$Time, INDEX = Data$OS, FUN = mean)

boxplot(Time ~ OS, data = Data)

points(M, col="red", pch="+", cex=2)

#Boxplot con segunda variable por bloques
boxplot(Time ~ Configuration, data = Data)

points(M, col="red", pch="+", cex=2)


#Boxplot con segunda variable por bloques
boxplot(Time ~ Scene, data = Data)

points(M, col="red", pch="+", cex=2)

#Boxplot con segunda variable por bloques
boxplot(Time ~ Lot, data = Data)

points(M, col="red", pch="+", cex=2)




#Grafico simple de interaccion, se hace antes de analisis de varianzas y modelos

interaction.plot(x.factor= Data$Configuration,
                 trace.factor= Data$OS,
                 response = Data$Time,
                 fun=mean, type="b", col=c("black", "red", "green", "blue", "pink"),
                 pch=c(19,17,15), fixed=TRUE, leg.bty="o")

interaction.plot(x.factor= Data$Scene,
                 trace.factor= Data$OS,
                 response = Data$Time,
                 fun=mean, type="b", col=c("black", "red", "green", "blue", "pink"),
                 pch=c(19,17,15), fixed=TRUE, leg.bty="o")

interaction.plot(x.factor= Data$Lot,
                 trace.factor= Data$OS,
                 response = Data$Time,
                 fun=mean, type="b", col=c("black", "red", "green", "blue", "pink"),
                 pch=c(19,17,15), fixed=TRUE, leg.bty="o")


#Definimos Modelo Lineal y Anova

model = lm(Time ~ OS * Configuration * Scene, data=Data)

Anova(model, type="II")



#Evaluacion de los supuestos
x =  residuals(model)
plotNormalHistogram(x)

#Ver el patron homcedasteicidad
plot(fitted(model), residuals(model))


plot(model)

#Prueba de LEVEN para homocedasticidad 
leveneTest(Time ~ OS * Configuration * Scene, data=Data)


#Revisar si esto debemos ponerlo en el paper
#Analisis post-hoc con los datos transformados
marginal = lsmeans(model, pairwise ~ OS,
                   adjust = "tukey")
CLD = cld(marginal, alpha=0.05, Letters = letters, adjust="tukey")
CLD



marginal = lsmeans(model, pairwise ~ Configuration,
                   adjust = "tukey")
CLD = cld(marginal, alpha=0.05, Letters = letters, adjust="tukey")
CLD


marginal = lsmeans(model, pairwise ~ Scene,
                   adjust = "tukey")
CLD = cld(marginal, alpha=0.05, Letters = letters, adjust="tukey")
CLD




#Transformacion de datos - Por raiz cuadrada

T.sqrt = sqrt(Data$Time)

model = lm(T.sqrt ~ OS * Configuration * Scene, data=Data)

Anova(model, type="II")

x =  residuals(model)
plotNormalHistogram(x)

#Ver el patron homcedasteicidad
plot(fitted(model), residuals(model))

plot(model)


#Prueba de LEVEN para homocedasticidad 
leveneTest(T.sqrt ~ OS * Configuration * Scene, data=Data)



#Analisis post-hoc con los datos transformados
marginal = lsmeans(model, pairwise ~ OS,
                   adjust = "tukey")
CLD = cld(marginal, alpha=0.05, Letters = letters, adjust="tukey")
CLD



marginal = lsmeans(model, pairwise ~ Configuration,
                   adjust = "tukey")
CLD = cld(marginal, alpha=0.05, Letters = letters, adjust="tukey")
CLD


marginal = lsmeans(model, pairwise ~ Scene,
                   adjust = "tukey")
CLD = cld(marginal, alpha=0.05, Letters = letters, adjust="tukey")
CLD






# #TRANSFORMACION DE DATOS - POR RAIZ CUBICA
# 
# #La transformacion se aplica sobre la variable dependiente
# T.cub = sign(Data$Time) * abs(Data$Time) ^ (1/3)
# 
# model = lm(T.cub ~ OS * Configuration * Scene
#            , data=Data)
# 
# Anova(model, type="II")
# 
# x =  residuals(model)
# plotNormalHistogram(x)
# 
# #Ver el patron homcedasteicidad
# plot(fitted(model), residuals(model))
# 
# plot(model)
# 
# 
# 
# 
# #La transformacion se aplica sobre la variable dependiente
# T.log = log(Data$Time)
# 
# model = lm(T.log ~ OS * Configuration * Scene
#            , data=Data)
# 
# Anova(model, type="II")
# 
# x =  residuals(model)
# plotNormalHistogram(x)
# 
# #Ver el patron homcedasteicidad
# plot(fitted(model), residuals(model))
# 
# plot(model)




#GRAFICO PRINICIPAL - PROMEDIOS TRANSFORMADOS


Sum = Summarize(T.sqrt ~ OS, data=Data, digits=3)

#Agregamos el se

Sum$se = Sum$sd / sqrt(Sum$n)
Sum$se = signif(Sum$se, digits=3)
Sum

#Ordenamos
Sum$OS = factor(Sum$OS, levels=unique(Sum$OS))

#Graficamos

pd=position_dodge(.2)


ggplot ( Sum , aes (x= OS , y=mean , color = OS ) ) +
   geom_errorbar ( aes ( ymin = mean - se , ymax = mean + se) , width =.2 , size =0.7 , position = pd ) +
  geom_point ( aes ( shape = OS ) , size =5 , position = pd ) + theme_bw () +
  theme ( plot.title = element_text ( face ="bold", size =20 , hjust =0.5) ,
             axis.title = element_text ( face ="bold", size =20) ,
             axis.text = element_text ( face ="bold", size =15) ,
          plot.caption = element_text ( hjust =0) ,
          legend.text = element_text ( face ="bold", size =15) ,
          legend.title = element_text ( face ="bold", size =20) ,
          legend.justification = c(0 ,1) , legend.position =c (0.01 , 0.99) ) +
   ylab ( expression ( "Average of rendering time after data transformation" ) ) +
   ggtitle ( "Time vs Operating System" )



#GRAFICO PRINICIPAL - PROMEDIOS TRANSFORMADOS


Sum = Summarize(T.sqrt ~ Configuration, data=Data, digits=3)

#Agregamos el se

Sum$se = Sum$sd / sqrt(Sum$n)
Sum$se = signif(Sum$se, digits=3)
Sum

#Ordenamos
Sum$Configuration = factor(Sum$Configuration, levels=unique(Sum$Configuration))

#Graficamos

pd=position_dodge(.2)


ggplot ( Sum , aes (x= Configuration , y=mean , color = Configuration ) ) +
  geom_errorbar ( aes ( ymin = mean - se , ymax = mean + se) , width =.2 , size =0.7 , position = pd ) +
  geom_point ( aes ( shape = Configuration ) , size =5 , position = pd ) + theme_bw () +
  theme ( plot.title = element_text ( face ="bold", size =20 , hjust =0.5) ,
          axis.title = element_text ( face ="bold", size =20) ,
          axis.text = element_text ( face ="bold", size =15) ,
          plot.caption = element_text ( hjust =0) ,
          legend.text = element_text ( face ="bold", size =15) ,
          legend.title = element_text ( face ="bold", size =20) ,
          legend.justification = c(0 ,1) , legend.position =c (0.01 , 0.99) ) +
  ylab ( expression ( "Average of rendering time after data transformation" ) ) +
  ggtitle ( "Time vs Configuration" )



#GRAFICO PRINICIPAL - PROMEDIOS TRANSFORMADOS


Sum = Summarize(T.sqrt ~ Scene, data=Data, digits=3)

#Agregamos el se

Sum$se = Sum$sd / sqrt(Sum$n)
Sum$se = signif(Sum$se, digits=3)
Sum

#Ordenamos
Sum$Scene = factor(Sum$Scene, levels=unique(Sum$Scene))

#Graficamos

pd=position_dodge(.2)


ggplot ( Sum , aes (x= Scene , y=mean , color = Scene ) ) +
  geom_errorbar ( aes ( ymin = mean - se , ymax = mean + se) , width =.2 , size =0.7 , position = pd ) +
  geom_point ( aes ( shape = Scene ) , size =5 , position = pd ) + theme_bw () +
  theme ( plot.title = element_text ( face ="bold", size =20 , hjust =0.5) ,
          axis.title = element_text ( face ="bold", size =20) ,
          axis.text = element_text ( face ="bold", size =15) ,
          plot.caption = element_text ( hjust =0) ,
          legend.text = element_text ( face ="bold", size =15) ,
          legend.title = element_text ( face ="bold", size =20) ,
          legend.justification = c(-1 ,1) , legend.position =c (0.01 , 0.99) ) +
  ylab ( expression ( "Average of rendering time after data transformation" ) ) +
  ggtitle ( "Time vs Scene" )






#Interacciones  ******

Sum = Summarize (T.sqrt ~ OS + Configuration , data = Data , digits =3)
Sum $se = Sum $sd / sqrt ( Sum $n)
Sum $se = signif ( Sum $se , digits =3)
Sum

pd = position_dodge (.2)
ggplot ( Sum , aes (x= Configuration ,y=mean , color = OS ) ) + geom_errorbar( aes ( ymin =  mean - se , ymax = mean + se), width = 0.2 , size =0.7 , position = pd )+
   geom_point ( aes ( shape = OS ) , size =5 , position = pd )+ theme_bw () +
   theme ( plot.title = element_text ( face ="bold", size =20 , hjust =0.5) ,
             axis.title = element_text ( face ="bold", size =20) ,
             axis.text = element_text ( face ="bold", size =15) ,
             plot.caption = element_text ( hjust =0) ,
             legend.text = element_text ( face ="bold", size =15) ,
             legend.title = element_text ( face ="bold", size =20) ,
             legend.justification = c(0 ,1) ,
             legend.position =c (0.01 , 0.99) ) + xlab (" Configuration ") +
ylab ( expression ("Average time of square root transformation")) + ggtitle ("Time vs Configuration \n related to Operating System ")



Sum = Summarize (T.sqrt ~ OS + Scene , data = Data , digits =3)
Sum $se = Sum $sd / sqrt ( Sum $n)
Sum $se = signif ( Sum $se , digits =3)
Sum

pd = position_dodge (.2)
ggplot ( Sum , aes (x= Scene ,y=mean , color = OS ) ) + geom_errorbar( aes ( ymin =  mean - se , ymax = mean + se), width = 0.2 , size =0.7 , position = pd )+
  geom_point ( aes ( shape = OS ) , size =5 , position = pd )+ theme_bw () +
  theme ( plot.title = element_text ( face ="bold", size =20 , hjust =0.5) ,
          axis.title = element_text ( face ="bold", size =20) ,
          axis.text = element_text ( face ="bold", size =15) ,
          plot.caption = element_text ( hjust =0) ,
          legend.text = element_text ( face ="bold", size =15) ,
          legend.title = element_text ( face ="bold", size =20) ,
          legend.justification = c(-2.3 ,1) ,
          legend.position =c (0.01 , 0.99) ) + xlab (" Scene ") +
  ylab ( expression ("Average time of square root transformation")) + ggtitle ("Time vs Scene \n related to Operating System ")





#**************


#Ahora des-transformemos

Sum = Summarize(T.sqrt ~ OS, data=Data, digits=3)

Sum$mean = Sum$mean ^ 2
Sum$sd = Sum$sd ^ 2
Sum

#Agregamos el se

Sum$se = Sum$sd / sqrt(Sum$n)
Sum$se = signif(Sum$se, digits=3)
Sum

#Ordenamos
Sum$OS = factor(Sum$OS, levels=unique(Sum$OS))

#Graficamos

pd=position_dodge(.2)

ggplot ( Sum , aes (x= OS , y=mean , color = OS ) ) +
  geom_errorbar ( aes ( ymin = mean - se , ymax = mean + se) , width =.2 , size =0.7 , position = pd ) +
  geom_point ( aes ( shape = OS ) , size =5 , position = pd ) + theme_bw () +
  theme ( plot.title = element_text ( face ="bold", size =20 , hjust =0.5) ,
          axis.title = element_text ( face ="bold", size =20) ,
          axis.text = element_text ( face ="bold", size =15) ,
          plot.caption = element_text ( hjust =0) ,
          legend.text = element_text ( face ="bold", size =15) ,
          legend.title = element_text ( face ="bold", size =20) ,
          legend.justification = c(0 ,1) , legend.position =c (0.01 , 0.99) ) +
  ylab ( expression ( "Average of rendering time before data transformation" ) ) +
  ggtitle ( "Time vs Operating System" )


#Ahora des-transformemos

Sum = Summarize(T.sqrt ~ Configuration, data=Data, digits=3)

Sum$mean = Sum$mean ^ 2
Sum$sd = Sum$sd ^ 2
Sum

#Agregamos el se

Sum$se = Sum$sd / sqrt(Sum$n)
Sum$se = signif(Sum$se, digits=3)
Sum

#Ordenamos
Sum$Configuration = factor(Sum$Configuration, levels=unique(Sum$Configuration))

#Graficamos

pd=position_dodge(.2)

ggplot ( Sum , aes (x= Configuration , y=mean , color = Configuration ) ) +
  geom_errorbar ( aes ( ymin = mean - se , ymax = mean + se) , width =.2 , size =0.7 , position = pd ) +
  geom_point ( aes ( shape = Configuration ) , size =5 , position = pd ) + theme_bw () +
  theme ( plot.title = element_text ( face ="bold", size =20 , hjust =0.5) ,
          axis.title = element_text ( face ="bold", size =20) ,
          axis.text = element_text ( face ="bold", size =15) ,
          plot.caption = element_text ( hjust =0) ,
          legend.text = element_text ( face ="bold", size =15) ,
          legend.title = element_text ( face ="bold", size =20) ,
          legend.justification = c(0 ,1) , legend.position =c (0.01 , 0.99) ) +
  ylab ( expression ( "Average of rendering time before data transformation" ) ) +
  ggtitle ( "Time vs Configuration" )




#Ahora des-transformemos

Sum = Summarize(T.sqrt ~ Scene, data=Data, digits=3)

Sum$mean = Sum$mean ^ 2
Sum$sd = Sum$sd ^ 2
Sum

#Agregamos el se

Sum$se = Sum$sd / sqrt(Sum$n)
Sum$se = signif(Sum$se, digits=3)
Sum

#Ordenamos
Sum$Scene = factor(Sum$Scene, levels=unique(Sum$Scene))

#Graficamos

pd=position_dodge(.2)

ggplot ( Sum , aes (x= Scene , y=mean , color = Scene ) ) +
  geom_errorbar ( aes ( ymin = mean - se , ymax = mean + se) , width =.2 , size =0.7 , position = pd ) +
  geom_point ( aes ( shape = Scene ) , size =5 , position = pd ) + theme_bw () +
  theme ( plot.title = element_text ( face ="bold", size =20 , hjust =0.5) ,
          axis.title = element_text ( face ="bold", size =20) ,
          axis.text = element_text ( face ="bold", size =15) ,
          plot.caption = element_text ( hjust =0) ,
          legend.text = element_text ( face ="bold", size =15) ,
          legend.title = element_text ( face ="bold", size =20) ,
          legend.justification = c(-2.0 ,1) , legend.position =c (0.01 , 0.99) ) +
  ylab ( expression ( "Average of rendering time before data transformation" ) ) +
  ggtitle ( "Time vs Scene" )








#Interacciones destransformadas

#Ahora des-transformemos

Sum = Summarize(T.sqrt ~ OS + Configuration, data=Data, digits=3)

Sum$mean = Sum$mean ^ 2
Sum$sd = Sum$sd ^ 2
Sum

#Agregamos el se

Sum$se = Sum$sd / sqrt(Sum$n)
Sum$se = signif(Sum$se, digits=3)
Sum


pd = position_dodge (.2)
ggplot ( Sum,aes (x=Configuration ,y=mean , color=OS ) ) + 
  geom_errorbar ( aes ( ymin = mean - se , ymax = mean+se), width =0.2, size =0.7, position = pd )+
   geom_point ( aes ( shape = OS ) , size =5 , position = pd )+ theme_bw () +
   theme ( plot.title = element_text ( face ="bold", size =20 , hjust =0.5) ,
            axis.title = element_text ( face ="bold", size =20) ,
            axis.text = element_text ( face ="bold", size =15) ,
            plot.caption = element_text ( hjust =0) ,
            legend.text = element_text ( face ="bold", size =15) ,
            legend.title = element_text ( face ="bold", size =20) ,
            legend.justification = c(0 ,1) ,
            legend.position =c(0.01 , 0.99) ) + xlab ("CONFIGURATION") + 
  ylab ( expression (" Average time ")) + ggtitle (" Time vs Configuration \n related to Operating System ")




#Interacciones destransformadas

#Ahora des-transformemos

Sum = Summarize(T.sqrt ~ OS + Scene, data=Data, digits=3)

Sum$mean = Sum$mean ^ 2
Sum$sd = Sum$sd ^ 2
Sum

#Agregamos el se

Sum$se = Sum$sd / sqrt(Sum$n)
Sum$se = signif(Sum$se, digits=3)
Sum


pd = position_dodge (.2)
ggplot ( Sum,aes (x=Scene ,y=mean , color=OS ) ) + 
  geom_errorbar ( aes ( ymin = mean - se , ymax = mean+se), width =0.2, size =0.7, position = pd )+
  geom_point ( aes ( shape = OS ) , size =5 , position = pd )+ theme_bw () +
  theme ( plot.title = element_text ( face ="bold", size =20 , hjust =0.5) ,
          axis.title = element_text ( face ="bold", size =20) ,
          axis.text = element_text ( face ="bold", size =15) ,
          plot.caption = element_text ( hjust =0) ,
          legend.text = element_text ( face ="bold", size =15) ,
          legend.title = element_text ( face ="bold", size =20) ,
          legend.justification = c(-2.2 ,1) ,
          legend.position =c(0.01 , 0.99) ) + xlab ("Scene") + 
  ylab ( expression (" Average time ")) + ggtitle (" Time vs Scene \n related to Operating System ")




 
# ********* Comparacion entre grupos mediante pairwise t.test***********

pairwise.t.test (T.sqrt , Data$OS , p.adjust.method = "BH")

pairwise.t.test (T.sqrt , Data$Configuration, p.adjust.method = "BH")

pairwise.t.test (T.sqrt , Data$Scene, p.adjust.method = "BH")

pairwise.t.test (T.sqrt, Data$OS:Data$Configuration, p.adjust.method = "BH")

pairwise.t.test (T.sqrt, Data$OS:Data$Scene, p.adjust.method = "BH")

#pairwise.t.test (T.sqrt, Data$OS:Data$Scene:Data$Configuration, p.adjust.method = "BH")
