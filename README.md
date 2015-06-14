## TP 1 Data Mining 2015

### tablas

- **table_1.csv**: productos de cada venta, con sus atributos (no hay repetidos; si dos productos tienen el mismo atributo, ese atributo aparece una sola vez)
```
VENTA_ID, PROD_ID1, PROD_ID2, ..., PROD_IDN, ATRIBUTO1, ATRIBUTO2, ..., ATRIBUTON
```

- **table_2.csv**: productos de cada venta, con sus atributos (hay repetidos; si dos productos tienen el mismo atributo, ese atributo aparece dos veces)
```
VENTA_ID, PROD_ID1, PROD_ID2, ..., PROD_IDN, ATRIBUTO1, ATRIBUTO1, ATRIBUTO2, ATRIBUTO2, ..., ATRIBUTON
```

- **table_3.csv**: solamente los productos de cada venta
```
VENTA_ID, PROD_ID1, PROD_ID2, ..., PROD_IDN
```

- **productos.csv**: el archivo original de la consigna, *TP_Productos*
```
PROD_ID,DESCGEN,DESCADIC,MARCA,PROVEEDOR,CAT_ID,SUBCAT_ID,CANTENVASE
```

- **productos_por_venta.txt**: product_ids por venta, sale de la tabla *TP_Ventas_Prod*
```
VENTA_ID,PROD_ID1,PROD_ID2,...,PROD_IDN
```

