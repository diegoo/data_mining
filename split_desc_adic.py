#!/usr/bin/env python
import sys
import re
import unicodecsv as csv
import unidecode

# uso:
# ./split_desc_adic [input_file]

input_data_file = sys.argv[1]
        
def process(r):
    new_r = r.copy()
    desc_gen, desc_adic = record['DescGen'], record['DescAdic']
    desc_gen = unidecode.unidecode(desc_gen)
    desc_adic = unidecode.unidecode(desc_adic).replace(desc_gen, '').strip()

    parts = {'product': desc_gen, 'attributes': None}
    attributes = [g.strip() for g in re.findall(r'\S+:\s+[\s\w\-/.]+(?:\s+|$)', desc_adic)]
    parts['attributes'] = [a.split(':') for a in attributes]
    record['ParsedDescAdic'] = ['%s|%s' % (p[0].strip(), p[1].strip()) for p in parts['attributes']]

    return record

if __name__ == '__main__':

    with open(input_data_file, 'r') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=',', quotechar="'")
        records = [process(record) for record in reader]
        
        for record in records:
            print record['Prod_ID'], record['ParsedDescAdic']
