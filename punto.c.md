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

# hist(subset(d, monto_total < 10000)$monto_total, breaks=100)
library(arules)
d$monto_total <- discretize(d$monto_total, method="fixed", categories = c(0,2000,6000,10000,Inf), labels=c('poco', 'medio', 'mucho', 'muchisimo'))
d$monto_por_categoria <- paste(d$categoria, d$monto_total, sep="_")
d$monto_total <- NULL
d$categoria <- NULL
write.csv(d, "monto.categoria.csv", row.names=FALSE, quote=FALSE)

```
venta_id,monto_por_categoria
1,CAMP_poco
1,OPTI_poco
1,PESP_poco
1,PESR_poco
1,TIRO_poco
2,OPTI_medio
3,PESC_muchisimo
3,PESP_muchisimo
3,PESR_muchisimo
4,CAMP_medio
4,PESC_medio
4,PESR_mucho
5,PESP_muchisimo
```

Convertimos las ventas en transacciones:

```
transacciones <- read.transactions('monto.categoria.csv', format="single", sep=",", cols=c(1,2))
summary(transacciones)

transactions as itemMatrix in sparse format with
 6270 rows (elements/itemsets/transactions) and
 41 columns (items) and a density of 0.04887385 

most frequent items:
CAMP_muchisimo     CAMP_medio      CAMP_poco      PESP_poco PESP_muchisimo 
          1344            879            804            618            592 
       (Other) 
          8327 
```

Creamos reglas a partir de las transacciones:

```
reglas <- apriori(transacciones, parameter=list(supp=0.002, conf=0.05, minlen=2, target="rules"))
reglas_ordenadas_por_confidence <-sort(reglas, decreasing=TRUE,by="confidence")
reglas_ordenadas_por_confidence_10 <- head(sort(reglas_ordenadas_por_confidence), n=10)
reglas_ordenadas_por_lift <-sort(reglas, decreasing=TRUE,by="lift")
reglas_ordenadas_por_lift_10 <- head(sort(reglas_ordenadas_por_lift), n=10)

plot(reglas_ordenadas_por_confidence_10, method="graph")
plot(reglas_ordenadas_por_lift_10, method="graph")
```


