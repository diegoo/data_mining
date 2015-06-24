# http://www.ms.unimelb.edu.au/~odj/Teaching/dm/arules_examples_Graham_Williams.pdf

library(arules)
library(arulesViz)

# --------------------------------------------------------------------------------

d <- read.csv('precios.totales.por.categoria.para.cada.cliente.csv', header=TRUE)
d$cliente <- as.factor(d$cliente)
d$categoria <- as.factor(d$categoria)
d$cantidad_por_categoria <- NULL
d$precio_total <- as.numeric(d$precio_total)
d$precio_total <- discretize(d$precio_total, method="fixed", categories = c(-Inf,10000,25000,50000,100000,250000,500000,1500000,5005000))
trans <- as(d, "transactions")
summary(trans)

reglas <- apriori(trans, parameter=list(supp=0.002, conf=0.05, minlen=2, target="rules")) # target="frequent"
reglas_por_confidence <-sort(reglas, decreasing=TRUE,by="confidence")
reglas_por_lift <-sort(reglas, decreasing=TRUE,by="lift")
creglas10 <- head(sort(reglas_por_confidence), n=10)
creglas30 <- head(sort(reglas_por_confidence), n=30)
plot(creglas10, method="graph")
plot(creglas30, method="graph")

plot(reglas, measure=c("support", "lift"), shading="confidence", interactive=TRUE)

# --------------------------------------------------------------------------------

# d$cantidad_por_categoria <- as.numeric(d$cantidad_por_categoria)
# d$cantidad_por_categoria <- discretize(d$cantidad_por_categoria, method = "frequency", 10)

# trans <- read.transactions('precios.totales.por.categoria.para.cada.cliente.csv', sep=",", format="single", cols=c(1,2))

# --------------------------------------------------------------------------------

transactions <- read.transactions('precios.totales.por.categoria.para.cada.cliente.csv', format='basket', sep=',')
summary(transactions)

reglas <- apriori(trans, parameter=list(supp=0.05, conf=0.4, minlen=2, target="rules")) # target="frequent"
reglas_por_confidence <-sort(reglas, decreasing=TRUE,by="confidence")
reglas_por_lift <-sort(reglas, decreasing=TRUE,by="lift")
inspect(head(sort(reglas), n=10))

plot(reglas, measure=c("support", "lift"), shading="confidence", interactive=TRUE)
plot(reglas, method="graph")

--------------------------------------------------------------------------------

clientes <- read.csv('ranking.clientes.csv', header=TRUE)

> summary(clientes)
    cliente          total        
 Min.   :67111   Min.   :    164  
 1st Qu.:68261   1st Qu.:  17669  
 Median :70754   Median :  44350  
 Mean   :69997   Mean   : 201056  
 3rd Qu.:71526   3rd Qu.: 155806  
 Max.   :71805   Max.   :5004974  


discretize(clientes$total, "fixed", categories = c(-Inf,10000,50000,5005000))

--------------------------------------------------------------------------------

cpc <- read.transactions('categorias.por.cliente.csv', sep=",", format="single")
summary(trans)
itemsets <- apriori(trans, parameter=list(supp=0.03, conf=0.2, minlen=2, maxlen=5, target="rules")) # target="frequent"
inspect(head(sort(itemsets), n=10))
reglas_por_confidence <-sort(reglas_por_confidence, decreasing=TRUE,by="confidence")
reglas_por_lift <-sort(reglas_por_lift, decreasing=TRUE,by="lift")
ireglas <- head(sort(reglas, decreasing=TRUE,by="confidence"), n=20)

# http://www.salemmarafi.com/code/market-basket-analysis-with-r/comment-page-1/
# Support: The fraction of which our item set occurs in our dataset.
# Confidence: probability that a rule is correct for a new transaction with items on the left.
# Lift: The ratio by which by the confidence of a rule exceeds the expected confidence. 
# Note: if the lift is 1 it indicates that the items on the left and right are independent.

# --------------------------------------------------------------------------------

d <- read.csv('monto.por.categoria.por.venta.csv', header=TRUE)
d <- subset(d, cantidad > 0)
d$venta_id <- as.factor(d$venta_id)
d$categoria <- as.factor(d$categoria)
d$monto_total <- as.numeric(d$monto_total)

# hist(subset(d, monto_total > 0 & monto_total < 50000)$monto_total, breaks=seq(0,50000,by=5000))
d$cantidad <- discretize(d$cantidad, method="fixed", categories = c(0,10,Inf))
d$monto_total <- discretize(d$monto_total, method="fixed", categories = c(0,5000,10000,Inf))
# d$monto_total <- discretize(d$monto_total, method="fixed", categories = c(0,5000,10000,Inf), labels=c('poco','medio','mucho'))
trans <- as(d, "transactions")
summary(trans)

reglas <- apriori(trans, parameter=list(supp=0.002, conf=0.05, minlen=2, target="rules")) # target="frequent"
reglas_por_confidence <-sort(reglas, decreasing=TRUE,by="confidence")
reglas_por_lift <-sort(reglas, decreasing=TRUE,by="lift")
creglas10 <- head(sort(reglas_por_confidence), n=10)
creglas30 <- head(sort(reglas_por_confidence), n=30)
plot(creglas10, method="graph")
plot(creglas30, method="graph")

plot(reglas, measure=c("support", "lift"), shading="confidence", interactive=TRUE)

# --------------------------------------------------------------------------------

# preparar transacciones
d <- read.csv('monto.por.categoria.por.venta.csv', header=TRUE)
d <- subset(d, cantidad > 0)
d$venta_id <- as.factor(d$venta_id)
d$categoria <- as.factor(d$categoria)
d$monto_total <- as.numeric(d$monto_total)
d$cantidad <- NULL
# hist(subset(d, monto_total < 10000)$monto_total, breaks=100)
d$monto_total <- discretize(d$monto_total, method="fixed", categories = c(0,2000,6000,10000,Inf), labels=c('poco', 'medio', 'mucho', 'muchisimo'))
d$monto_por_categoria <- paste(d$categoria, d$monto_total, sep="_")
d$monto_total <- NULL
d$categoria <- NULL
write.csv(d, "monto.categoria.csv", row.names=FALSE, quote=FALSE)

# procesar transacciones
transacciones <- read.transactions('monto.categoria.3.csv', format="single", sep=",", cols=c(1,2))
summary(transacciones)

# transactions as itemMatrix in sparse format with
#  6265 rows (elements/itemsets/transactions) and
#  39 columns (items) and a density of 0.05119201 <- 11 categorías x 4 niveles de montos (no son 44 porque algunas combinaciones no aparecen) 
# most frequent items:
#  CAMP_poco  PESP_poco CAMP_medio  PESC_poco  PESR_poco    (Other) 
#       1819       1670       1051       1008       1006       5954 

reglas <- apriori(transacciones, parameter=list(supp=0.002, conf=0.05, minlen=2, target="rules"))
reglas_ordenadas_por_confidence <-sort(reglas, decreasing=TRUE,by="confidence")
reglas_ordenadas_por_confidence_10 <- head(sort(reglas_ordenadas_por_confidence), n=10)
reglas_ordenadas_por_lift <-sort(reglas, decreasing=TRUE,by="lift")
reglas_ordenadas_por_lift_10 <- head(sort(reglas_ordenadas_por_lift), n=10)

plot(reglas_ordenadas_por_confidence_10, method="graph")
plot(reglas_ordenadas_por_lift_10, method="graph")


# muchísimo

> inspect(subset(reglas_ordenadas_por_confidence, subset=lhs %in% c("CAMP_muchisimo","CUCH_muchisimo","INDP_muchisimo","INDU_muchisimo","OPTI_muchisimo","PESC_muchisimo","PESP_muchisimo","PESR_muchisimo","TIRO_muchisimo")))
  lhs                 rhs                  support confidence      lift
1 {PESR_muchisimo} => {PESC_muchisimo} 0.002553871  0.3555556 42.029350
2 {PESR_muchisimo} => {PESP_medio}     0.002234637  0.3111111  8.087598
3 {PESC_muchisimo} => {PESR_muchisimo} 0.002553871  0.3018868 42.029350
4 {PESC_muchisimo} => {PESP_medio}     0.002075020  0.2452830  6.376341
5 {CAMP_muchisimo} => {PESP_poco}      0.004469274  0.0875000  0.328256

> inspect(subset(reglas_ordenadas_por_confidence, subset=rhs %in% c("CAMP_muchisimo","CUCH_muchisimo","INDP_muchisimo","INDU_muchisimo","OPTI_muchisimo","PESC_muchisimo","PESP_muchisimo","PESR_muchisimo","TIRO_muchisimo")))
  lhs                 rhs                  support confidence      lift
1 {PESR_muchisimo} => {PESC_muchisimo} 0.002553871 0.35555556 42.029350
2 {PESC_muchisimo} => {PESR_muchisimo} 0.002553871 0.30188679 42.029350
3 {PESP_medio}     => {PESR_muchisimo} 0.002234637 0.05809129  8.087598
4 {PESP_medio}     => {PESC_muchisimo} 0.002075020 0.05394191  6.376341

> inspect(subset(reglas_ordenadas_por_lift, subset=lhs %in% c("CAMP_muchisimo","CUCH_muchisimo","INDP_muchisimo","INDU_muchisimo","OPTI_muchisimo","PESC_muchisimo","PESP_muchisimo","PESR_muchisimo","TIRO_muchisimo")))
  lhs                 rhs                  support confidence      lift
1 {PESR_muchisimo} => {PESC_muchisimo} 0.002553871  0.3555556 42.029350
2 {PESC_muchisimo} => {PESR_muchisimo} 0.002553871  0.3018868 42.029350
3 {PESR_muchisimo} => {PESP_medio}     0.002234637  0.3111111  8.087598
4 {PESC_muchisimo} => {PESP_medio}     0.002075020  0.2452830  6.376341
5 {CAMP_muchisimo} => {PESP_poco}      0.004469274  0.0875000  0.328256

> inspect(subset(reglas_ordenadas_por_lift, subset=rhs %in% c("CAMP_muchisimo","CUCH_muchisimo","INDP_muchisimo","INDU_muchisimo","OPTI_muchisimo","PESC_muchisimo","PESP_muchisimo","PESR_muchisimo","TIRO_muchisimo")))
  lhs                 rhs                  support confidence      lift
1 {PESR_muchisimo} => {PESC_muchisimo} 0.002553871 0.35555556 42.029350
2 {PESC_muchisimo} => {PESR_muchisimo} 0.002553871 0.30188679 42.029350
3 {PESP_medio}     => {PESR_muchisimo} 0.002234637 0.05809129  8.087598
4 {PESP_medio}     => {PESC_muchisimo} 0.002075020 0.05394191  6.376341


# mucho

> inspect(subset(reglas_ordenadas_por_confidence, subset=lhs %in% c("CAMP_mucho","CUCH_mucho","INDP_mucho","INDU_mucho","OPTI_mucho","PESC_mucho","PESP_mucho","PESR_mucho","TIRO_mucho")))
   lhs             rhs              support confidence       lift
1  {CAMP_mucho,                                                  
    PESR_poco}  => {PESP_poco}  0.002075020 0.59090909  2.2167937
2  {INDP_mucho} => {PESP_poco}  0.002873105 0.43902439  1.6469987
3  {PESR_mucho} => {PESP_poco}  0.003032721 0.31666667  1.1879741
4  {PESC_mucho} => {PESR_medio} 0.003192338 0.29411765  6.7744377
5  {PESC_mucho} => {PESP_poco}  0.003032721 0.27941176  1.0482124
6  {CAMP_mucho,                                                  
    PESP_poco}  => {PESR_poco}  0.002075020 0.27659574  1.7225371
7  {PESR_mucho} => {PESC_medio} 0.002394254 0.25000000  5.0200321
8  {PESR_mucho} => {PESC_mucho} 0.002234637 0.23333333 21.4975490
9  {PESC_mucho} => {PESR_mucho} 0.002234637 0.20588235 21.4975490
10 {CAMP_mucho} => {PESP_poco}  0.007501995 0.15771812  0.5916791
11 {OPTI_mucho} => {CAMP_poco}  0.002713488 0.14166667  0.4879283
12 {CAMP_mucho} => {INDU_poco}  0.003990423 0.08389262  0.8316254
13 {CAMP_mucho} => {PESR_poco}  0.003511572 0.07382550  0.4597582
14 {CAMP_mucho} => {PESC_poco}  0.003351955 0.07046980  0.4379894
15 {CAMP_mucho} => {TIRO_poco}  0.002873105 0.06040268  0.9532061
16 {CAMP_mucho} => {OPTI_poco}  0.002553871 0.05369128  0.3844295

> inspect(subset(reglas_ordenadas_por_confidence, subset=rhs %in% c("CAMP_mucho","CUCH_mucho","INDP_mucho","INDU_mucho","OPTI_mucho","PESC_mucho","PESP_mucho","PESR_mucho","TIRO_mucho")))
  lhs             rhs              support confidence      lift
1 {PESR_mucho} => {PESC_mucho} 0.002234637 0.23333333 21.497549
2 {PESC_mucho} => {PESR_mucho} 0.002234637 0.20588235 21.497549
3 {PESR_medio} => {PESC_mucho} 0.003192338 0.07352941  6.774438

> inspect(subset(reglas_ordenadas_por_lift, subset=lhs %in% c("CAMP_mucho","CUCH_mucho","INDP_mucho","INDU_mucho","OPTI_mucho","PESC_mucho","PESP_mucho","PESR_mucho","TIRO_mucho")))
   lhs             rhs              support confidence       lift
1  {PESC_mucho} => {PESR_mucho} 0.002234637 0.20588235 21.4975490
2  {PESR_mucho} => {PESC_mucho} 0.002234637 0.23333333 21.4975490
3  {PESC_mucho} => {PESR_medio} 0.003192338 0.29411765  6.7744377
4  {PESR_mucho} => {PESC_medio} 0.002394254 0.25000000  5.0200321
5  {CAMP_mucho,                                                  
    PESR_poco}  => {PESP_poco}  0.002075020 0.59090909  2.2167937
6  {CAMP_mucho,                                                  
    PESP_poco}  => {PESR_poco}  0.002075020 0.27659574  1.7225371
7  {INDP_mucho} => {PESP_poco}  0.002873105 0.43902439  1.6469987
8  {PESR_mucho} => {PESP_poco}  0.003032721 0.31666667  1.1879741
9  {PESC_mucho} => {PESP_poco}  0.003032721 0.27941176  1.0482124
10 {CAMP_mucho} => {TIRO_poco}  0.002873105 0.06040268  0.9532061
11 {CAMP_mucho} => {INDU_poco}  0.003990423 0.08389262  0.8316254
12 {CAMP_mucho} => {PESP_poco}  0.007501995 0.15771812  0.5916791
13 {OPTI_mucho} => {CAMP_poco}  0.002713488 0.14166667  0.4879283
14 {CAMP_mucho} => {PESR_poco}  0.003511572 0.07382550  0.4597582
15 {CAMP_mucho} => {PESC_poco}  0.003351955 0.07046980  0.4379894
16 {CAMP_mucho} => {OPTI_poco}  0.002553871 0.05369128  0.3844295

> inspect(subset(reglas_ordenadas_por_lift, subset=rhs %in% c("CAMP_mucho","CUCH_mucho","INDP_mucho","INDU_mucho","OPTI_mucho","PESC_mucho","PESP_mucho","PESR_mucho","TIRO_mucho")))
  lhs             rhs              support confidence      lift
1 {PESC_mucho} => {PESR_mucho} 0.002234637 0.20588235 21.497549
2 {PESR_mucho} => {PESC_mucho} 0.002234637 0.23333333 21.497549
3 {PESR_medio} => {PESC_mucho} 0.003192338 0.07352941  6.774438


# medio

> inspect(subset(reglas_ordenadas_por_confidence, subset=lhs %in% c("CAMP_medio","CUCH_medio","INDP_medio","INDU_medio","OPTI_medio","PESC_medio","PESP_medio","PESR_medio","TIRO_medio"))[1:10])
   lhs             rhs             support confidence     lift
1  {INDP_poco,                                                
    PESC_medio,                                               
    PESR_medio} => {PESP_poco} 0.002234637  0.9333333 3.501397
2  {CAMP_poco,                                                
    INDP_medio,                                               
    PESR_poco}  => {PESC_poco} 0.002234637  0.8750000 5.438368
3  {CAMP_medio,                                               
    PESC_medio,                                               
    PESR_medio} => {PESP_poco} 0.002234637  0.8750000 3.282560
4  {CAMP_poco,                                                
    INDP_poco,                                                
    PESC_medio} => {PESP_poco} 0.002075020  0.8666667 3.251297
5  {CAMP_medio,                                               
    INDU_poco,                                                
    PESP_poco,                                                
    PESR_poco}  => {PESC_poco} 0.002553871  0.8421053 5.233918
6  {INDP_poco,                                                
    PESR_medio} => {PESP_poco} 0.004309657  0.8181818 3.069407
7  {PESC_medio,                                               
    TIRO_poco}  => {PESP_poco} 0.002075020  0.8125000 3.048091
8  {CAMP_poco,                                                
    INDU_poco,                                                
    PESC_medio} => {PESP_poco} 0.002075020  0.8125000 3.048091
9  {OPTI_medio,                                               
    PESR_medio} => {PESP_poco} 0.002394254  0.7894737 2.961708
10 {CAMP_medio,                                               
    PESR_poco,                                                
    TIRO_poco}  => {PESC_poco} 0.002394254  0.7894737 4.906798

> inspect(subset(reglas_ordenadas_por_confidence, subset=rhs %in% c("CAMP_medio","CUCH_medio","INDP_medio","INDU_medio","OPTI_medio","PESC_medio","PESP_medio","PESR_medio","TIRO_medio"))[1:10])
   lhs             rhs              support confidence      lift
1  {INDP_poco,                                                  
    PESC_medio,                                                 
    PESP_poco}  => {PESR_medio} 0.002234637  0.5600000 12.898529
2  {CAMP_medio,                                                 
    PESC_medio,                                                 
    PESP_poco}  => {PESR_medio} 0.002234637  0.5600000 12.898529
3  {INDP_poco,                                                  
    PESP_poco,                                                  
    PESR_medio} => {PESC_medio} 0.002234637  0.5185185 10.411918
4  {INDP_poco,                                                  
    PESR_medio} => {PESC_medio} 0.002394254  0.4545455  9.127331
5  {CAMP_medio,                                                 
    PESP_poco,                                                  
    PESR_medio} => {PESC_medio} 0.002234637  0.4375000  8.785056
6  {INDP_poco,                                                  
    PESC_medio} => {PESR_medio} 0.002394254  0.4054054  9.337738
7  {INDP_medio,                                                 
    INDU_poco}  => {CAMP_medio} 0.002075020  0.3939394  2.348269
8  {PESP_poco,                                                  
    PESR_medio} => {PESC_medio} 0.009257781  0.3918919  7.869239
9  {CAMP_medio,                                                 
    PESR_medio} => {PESC_medio} 0.002553871  0.3902439  7.836148
10 {INDU_poco,                                                  
    PESR_medio} => {PESC_medio} 0.002075020  0.3823529  7.677696

> inspect(subset(reglas_ordenadas_por_lift, subset=lhs %in% c("CAMP_medio","CUCH_medio","INDP_medio","INDU_medio","OPTI_medio","PESC_medio","PESP_medio","PESR_medio","TIRO_medio"))[1:10])
   lhs             rhs                  support confidence      lift
1  {INDP_poco,                                                      
    PESC_medio,                                                     
    PESP_poco}  => {PESR_medio}     0.002234637 0.56000000 12.898529
2  {CAMP_medio,                                                     
    PESC_medio,                                                     
    PESP_poco}  => {PESR_medio}     0.002234637 0.56000000 12.898529
3  {INDP_poco,                                                      
    PESP_poco,                                                      
    PESR_medio} => {PESC_medio}     0.002234637 0.51851852 10.411918
4  {INDP_poco,                                                      
    PESC_medio} => {PESR_medio}     0.002394254 0.40540541  9.337738
5  {INDP_poco,                                                      
    PESR_medio} => {PESC_medio}     0.002394254 0.45454545  9.127331
6  {CAMP_medio,                                                     
    PESP_poco,                                                      
    PESR_medio} => {PESC_medio}     0.002234637 0.43750000  8.785056
7  {PESC_medio,                                                     
    PESP_poco}  => {PESR_medio}     0.009257781 0.36708861  8.455184
8  {INDU_poco,                                                      
    PESC_medio} => {PESR_medio}     0.002075020 0.35135135  8.092707
9  {PESP_medio} => {PESR_muchisimo} 0.002234637 0.05809129  8.087598
10 {CAMP_medio,                                                     
    PESC_medio} => {PESR_medio}     0.002553871 0.34782609  8.011509

> inspect(subset(reglas_ordenadas_por_lift, subset=rhs %in% c("CAMP_medio","CUCH_medio","INDP_medio","INDU_medio","OPTI_medio","PESC_medio","PESP_medio","PESR_medio","TIRO_medio"))[1:10])
   lhs                 rhs              support confidence      lift
1  {INDP_poco,                                                      
    PESC_medio,                                                     
    PESP_poco}      => {PESR_medio} 0.002234637  0.5600000 12.898529
2  {CAMP_medio,                                                     
    PESC_medio,                                                     
    PESP_poco}      => {PESR_medio} 0.002234637  0.5600000 12.898529
3  {INDP_poco,                                                      
    PESP_poco,                                                      
    PESR_medio}     => {PESC_medio} 0.002234637  0.5185185 10.411918
4  {INDP_poco,                                                      
    PESC_medio}     => {PESR_medio} 0.002394254  0.4054054  9.337738
5  {INDP_poco,                                                      
    PESR_medio}     => {PESC_medio} 0.002394254  0.4545455  9.127331
6  {CAMP_medio,                                                     
    PESP_poco,                                                      
    PESR_medio}     => {PESC_medio} 0.002234637  0.4375000  8.785056
7  {PESC_medio,                                                     
    PESP_poco}      => {PESR_medio} 0.009257781  0.3670886  8.455184
8  {INDU_poco,                                                      
    PESC_medio}     => {PESR_medio} 0.002075020  0.3513514  8.092707
9  {PESR_muchisimo} => {PESP_medio} 0.002234637  0.3111111  8.087598
10 {CAMP_medio,                                                     
    PESC_medio}     => {PESR_medio} 0.002553871  0.3478261  8.011509




> itemFrequency(transacciones, type = "relative")
         CAMP_medio          CAMP_mucho           CAMP_poco          CUCH_medio 
       0.1901116427        0.2143540670        0.1518341308        0.0063795853 
         CUCH_mucho           CUCH_poco          INDP_medio          INDP_mucho 
       0.0014354067        0.0352472089        0.0562998405        0.0283891547 
          INDP_poco          INDU_medio          INDU_mucho           INDU_poco 
       0.0384370016        0.0481658692        0.0218500797        0.0580542265 
         INST_medio          INST_mucho           INST_poco monto_por_categoria 
       0.0027113238        0.0003189793        0.0213716108        0.0001594896 
         OPTI_medio          OPTI_mucho           OPTI_poco          PESC_medio 
       0.1145135566        0.0574162679        0.0850079745        0.1047846890 
         PESC_mucho           PESC_poco          PESP_medio          PESP_mucho 
       0.0634768740        0.0615629984        0.1212121212        0.0944178628 
          PESP_poco          PESR_medio          PESR_mucho           PESR_poco 
       0.1143540670        0.0912280702        0.0510366826        0.0783094099 
         TIRO_medio          TIRO_mucho           TIRO_poco 
       0.0285486443        0.0084529506        0.0543859649 
> 
