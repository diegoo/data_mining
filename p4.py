#!/usr/bin/env python
import sys
import re
import unicodecsv as csv
import unidecode
from collections import defaultdict

if __name__ == '__main__':

    with open(sys.argv[1], 'r') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=',', quotechar='"')
        records = [r for r in reader]

    agrupado = defaultdict(list)
    for r in records:
        agrupado[r['cliente']].append(r['monto_por_categoria'])

    for cliente in sorted(agrupado.iterkeys()):
        output = [cliente]
        output.extend(sorted(set(agrupado[cliente])))
        print(','.join(output))
