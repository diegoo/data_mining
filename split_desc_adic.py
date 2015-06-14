#!/usr/bin/env python
import sys
import re
import unicodecsv as csv
import unidecode

# uso:
# ./split_desc_adic [input_file]

input_data_file = sys.argv[1]

attribute_names = []

def process(r):
    new_r = r.copy()
    desc_gen, desc_adic = record['DescGen'], record['DescAdic']
    desc_gen = unidecode.unidecode(desc_gen)
    desc_adic = unidecode.unidecode(desc_adic).replace(desc_gen, '').strip()

    parts = {'product': desc_gen, 'attributes': None}
    attributes = [g.strip() for g in re.findall(r'(?:Accesorios|Accion|Altura|Anzuelo|Arbor|Aumentos|Cacha|Calibre|Capacidad|Capacidad/PSI|Caracteristicas|Color|Color/Desc|Densidad|Descripcion|Descripcion 1|Descripcion 2|Descripcion 3|Diam+DF|Diam/Varillas|Diametro|Est/Material|Estructura|Estuche|Extra|Extra1|Extra2|Funda|Grosor|Hoja|Lamparas|Largo|Lente|Libras|Linea|M|Material|Material/mm|Maximo|Medida|Modelo|Montura|Neoprene|Numero|Numero 1|Numero 2|Numero 3|Oculares/Objs|Orden|Pack|Pack/Medida|Parte|Personas|Peso|Pie|Piezas|Pilas|Plazas|Poste|Recipientes|Rulemanes|Secciones|Sexo|Tabla|Talle|Tamano|Tapa|Temperatura|Terminacion|Tipo|Tramo|Tramos|Tubitos|Uso|Utensilio):\s+[\s\w\-/.()+]+(?:\s+|$)', desc_adic)]
    parts['attributes'] = [a.split(':') for a in attributes]
    record['ParsedDescAdic'] = ['%s|%s' % (p[0].strip(), p[1].strip()) for p in parts['attributes']]
    for p in parts['attributes']: attribute_names.append(p[0].strip())
    return record

if __name__ == '__main__':

    with open(input_data_file, 'r') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=',', quotechar="'")
        records = [process(record) for record in reader]
        
        for record in records: #[0:10]:
            print record['Prod_ID'], record['ParsedDescAdic']

        # print set(attribute_names)
