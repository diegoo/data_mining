### c) Seleccionar 10 reglas que representen conocimiento relevante a nivel monto y cantidad de ventas de la empresa.

Para analizar las ventas de la empresa, consideramos los productos agrupados por categoría. Primero calculamos el monto total por categoría de productos en cada venta, y para eso sumamos los montos calculados por unidad y por millar. Quitamos los valores negativos (¿devoluciones o créditos, quizá?).

```
SELECT a.venta_id, a.categoria, FLOOR(SUM(a.monto)) as monto_total
	FROM
		(SELECT v.Venta_ID AS venta_id, p.Cat_id AS categoria, SUM((vp.Cantidad_UM2 / 1000) * ps.Precio) AS monto
			FROM TP_Ventas v
				JOIN TP_Ventas_Prod vp ON v.Venta_ID = vp.Venta_ID
				JOIN TP_Productos p ON vp.Prod_ID = p.Prod_ID
				JOIN TP_Precio_Sugerido ps ON p.Prod_ID = ps.Prod_ID
			WHERE (vp.Cantidad_UM1 = 0 and vp.Cantidad_UM2 > 0)
			GROUP BY v.Venta_ID, p.Cat_ID
		UNION ALL
		SELECT v.Venta_ID AS venta_id, p.Cat_id AS categoria, SUM(vp.Cantidad_UM1 * ps.Precio) AS monto
			FROM TP_Ventas v
				JOIN TP_Ventas_Prod vp ON v.Venta_ID = vp.Venta_ID
				JOIN TP_Productos p ON vp.Prod_ID = p.Prod_ID
				JOIN TP_Precio_Sugerido ps ON p.Prod_ID = ps.Prod_ID
			WHERE (vp.Cantidad_UM1 > 0)
			GROUP BY v.Venta_ID, p.Cat_ID) a
	GROUP BY a.Venta_ID, a.categoria ORDER BY a.Venta_ID, a.categoria;
```

```
venta_id,categoria,monto_total
1,CAMP,488
1,OPTI,1057
1,PESP,710
1,PESR,681
1,TIRO,492
2,OPTI,5634
3,PESC,20242
3,PESP,64800
3,PESR,23908
4,CAMP,4776
4,PESC,3056
4,PESR,7344
5,PESP,18304
(...)
```

Cargamos los datos en R y damos formato numérico a los montos:

```
d <- read.csv('monto.por.categoria.por.venta.csv', header=TRUE)
d$venta_id <- as.factor(d$venta_id)
d$categoria <- as.factor(d$categoria)
d$monto_total <- as.numeric(d$monto_total)
summary(d)

   categoria	  monto_total	 
 CAMP	 :3488	 Min.	:	  0	 
 PESP	 :2069	 1st Qu.:  1620	 
 OPTI	 :1611	 Median :  4304	 
 PESC	 :1441	 Mean	: 10681	 
 PESR	 :1383	 3rd Qu.: 10816	 
 INDU	 : 803	 Max.	:480730	 
 (Other):1768
```

Para usar los montos de las ventas en reglas de asociación, las dividimos en categorías discretas. Observamos su distribución:

```
png("montos.por.venta.png")
hist(subset(d, monto_total < 10000)$monto_total, breaks=100, main="distribución del monto total (en ventas hasta $10.000)", xlab="monto", ylab="cantidad de ventas")
dev.off()
```

![montos por venta](https://github.com/diegoo/data_mining/blob/master/montos.por.venta.png "montos por venta")

Una discretización posible: separar la campana inicial (entre 0 y 2500, aprox.), los valores entre 2500 y 10000, y las ventas con montos más grandes.

```
library(arules)

d$monto_total <- discretize(d$monto_total, method="fixed", categories = c(0,2500,10000,Inf), labels=c('poco', 'medio', 'mucho'))
d$monto_por_categoria <- paste(d$categoria, d$monto_total, sep="_")
d$monto_total <- NULL
d$categoria <- NULL
write.csv(d, "monto.categoria.csv", row.names=FALSE, quote=FALSE)
```

El dataset resultante:

```
venta_id,monto_por_categoria
1,CAMP_poco
1,OPTI_poco
1,PESP_poco
1,PESR_poco
1,TIRO_poco
2,OPTI_medio
3,PESC_mucho
3,PESP_mucho
3,PESR_mucho
4,CAMP_medio
(...)
```

Convertimos las ventas en transacciones:

```
transacciones <- read.transactions('monto.categoria.csv', format="single", sep=",", cols=c(1,2), rm.duplicates=TRUE)
summary(transacciones)

transactions as itemMatrix in sparse format with
 6270 rows (elements/itemsets/transactions) and
 31 columns (items) and a density of 0.0646396 

most frequent items:
CAMP_mucho CAMP_medio  CAMP_poco PESP_medio OPTI_medio    (Other) 
1344       1192        952        760        718       7598
```

Hay menos de 33 columnas (3 niveles de monto x 11 categorías de producto) porque no todos los productos se venden en todos los niveles de montos. (Confirmamos, además, la importancia de las categorías *Camping*, *Pesca* y *Cañas de Pesca* hallada en el punto a.).

```
png("distribucion.de.transacciones.segun.montos.png")
itemFrequencyPlot(transacciones, support = 0.005, type="relative", topN=15)
dev.off()
```

![frecuencia de categorías por montos](https://github.com/diegoo/data_mining/blob/master/distribucion.de.transacciones.segun.montos.png "frecuencia de categorías por montos")

Creamos reglas a partir de las transacciones. Si conservamos los niveles del punto a. (supp=0.005, conf=0.7, aprox.), obtenemos a lo sumo 1 o 2 reglas como la siguente:

```
      lhs             rhs          support     confidence        lift
1 {CAMP_mucho,                                                
   PESP_poco,                                                 
   PESR_medio} => {PESC_medio}   0.002073365     0.8125        7.753995
```

Por lo tanto, ajustamos los valores. Bajar el soporte agrega pocas reglas:

```
  lhs             rhs              support confidence      lift
1 {PESC_medio,                                                 
   TIRO_medio} => {PESR_medio} 0.003030303  0.7037037  7.713675
2 {INDP_poco,                                                  
   PESR_medio} => {PESC_medio} 0.003827751  0.7272727  6.940639
3 {CAMP_mucho,                                                 
   PESP_mucho,                                                 
   PESR_mucho} => {PESC_mucho} 0.003349282  0.7500000 11.815327
```

Bajamos también el nivel de confianza, y podamos:

```
reglas <- apriori(transacciones, parameter=list(supp=0.004, conf=0.3, minlen=2, target="rules"))

subset.matrix <- is.subset(reglas, reglas)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
reglas.podadas <- reglas[!redundant]
inspect(reglas.podadas)
```

Ordenando por *confidence*:

```
reglas.ordenadas.por.confidence <-sort(reglas.podadas, decreasing=TRUE, by="confidence")
reglas.ordenadas.por.confidence.10 <- head(sort(reglas.ordenadas.por.confidence), n=10)

> inspect(reglas.ordenadas.por.confidence.10)
   lhs             rhs              support confidence     lift
1  {PESR_medio} => {PESC_medio} 0.044338118  0.4860140 4.638216
2  {PESR_mucho} => {PESC_mucho} 0.030622010  0.6000000 9.452261
3  {PESC_poco}  => {PESR_poco}  0.029505582  0.4792746 6.120268
4  {PESR_poco}  => {PESC_medio} 0.026953748  0.3441955 3.284788
5  {INDU_medio} => {CAMP_mucho} 0.018022329  0.3741722 1.745580
6  {TIRO_poco}  => {CAMP_mucho} 0.017543860  0.3225806 1.504896
7  {PESR_mucho} => {PESP_mucho} 0.015629984  0.3062500 3.243560
8  {CUCH_poco}  => {CAMP_mucho} 0.011802233  0.3348416 1.562096
9  {TIRO_medio} => {CAMP_mucho} 0.010845295  0.3798883 1.772247
10 {CAMP_poco,                                                 
    PESC_medio} => {PESP_medio} 0.005741627  0.3913043 3.228261
```

Y por *lift*:
```
reglas.ordenadas.por.lift <-sort(reglas.podadas, decreasing=TRUE, by="lift")
reglas.ordenadas.por.lift.10 <- head(sort(reglas.ordenadas.por.lift), n=10)

   lhs             rhs              support confidence     lift
1  {PESR_medio} => {PESC_medio} 0.044338118  0.4860140 4.638216
2  {PESR_mucho} => {PESC_mucho} 0.030622010  0.6000000 9.452261
3  {PESC_poco}  => {PESR_poco}  0.029505582  0.4792746 6.120268
4  {PESR_poco}  => {PESC_medio} 0.026953748  0.3441955 3.284788
5  {INDU_medio} => {CAMP_mucho} 0.018022329  0.3741722 1.745580
6  {TIRO_poco}  => {CAMP_mucho} 0.017543860  0.3225806 1.504896
7  {PESR_mucho} => {PESP_mucho} 0.015629984  0.3062500 3.243560
8  {CUCH_poco}  => {CAMP_mucho} 0.011802233  0.3348416 1.562096
9  {TIRO_medio} => {CAMP_mucho} 0.010845295  0.3798883 1.772247
10 {CAMP_poco,                                                 
    PESC_medio} => {PESP_medio} 0.005741627  0.3913043 3.228261
```

Desde un punto de vista de negocio, nos interesan en primer lugar las reglas que
	- vinculen artículos de distintas categorías (por lo tanto excluimos las que conecten variantes de *Pesca*)
	- tengan como consecuencia que los clientes compren *mucho*

Filtramos el *rhs*:

```
inspect(subset(reglas.ordenadas.por.lift, subset=rhs %in% c("CAMP_mucho","CUCH_mucho","INDP_mucho","INDU_mucho","OPTI_mucho","PESC_mucho","PESP_mucho","PESR_mucho","TIRO_mucho")))

  lhs             rhs              support confidence     lift
4 {INDP_medio,                                                
   PESP_mucho} => {CAMP_mucho} 0.004146730  0.4262295 1.988437
5 {TIRO_medio} => {CAMP_mucho} 0.010845295  0.3798883 1.772247
6 {INDU_medio} => {CAMP_mucho} 0.018022329  0.3741722 1.745580
7 {CUCH_poco}  => {CAMP_mucho} 0.011802233  0.3348416 1.562096
8 {PESC_mucho,                                                
   PESP_mucho} => {CAMP_mucho} 0.005422648  0.3269231 1.525155
9 {TIRO_poco}  => {CAMP_mucho} 0.017543860  0.3225806 1.504896
```

Son, en principio, reglas relevantes porque vinculan niveles bajos y medios de una categoría (TIRO, INDU y CUCH) con el nivel máximo de la categoría más vendida (CAMP). Y representan una oportunidad (si los clientes ya están gastando mucho en CAMP, podrían estar dispuestos a gastar un poco más en las otras categorías también).


