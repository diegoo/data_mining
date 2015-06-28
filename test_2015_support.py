#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import unicodecsv as csv

# uso:
# ./test_2015_support.py dataset.2015.2.csv > reglas.2014.aplicadas.a.2015.csv

reglas_2014 = [

    # 1er mail
    
    # supp=0.05
    # conf=0.7

    { "itemset" : ("AA", "CAMPING", "OPTI_medio", "CAMP_mucho"),  "support": 0.05638474, "confidence": 0.9444444, "lift": 2.454741},
    { "itemset" : ("AA", "CAMPING", "INDP_medio", "CAMP_mucho"),  "support": 0.05472637, "confidence": 0.9428571, "lift": 2.450616}, 
    { "itemset" : ("AA", "CAMPING", "CUCH_poco", "CAMP_mucho"),   "support": 0.05970149, "confidence": 0.9000000, "lift": 2.339224}, 
    { "itemset" : ("AA", "TIRO_poco", "CAMPING"),                 "support": 0.06467662, "confidence": 0.8125000, "lift": 1.458147}, 
    { "itemset" : ("AA", "TIRO_poco", "CAMP_mucho"),              "support": 0.07296849, "confidence": 0.9166667, "lift": 2.382543}, 
    { "itemset" : ("AA", "TIRO_medio", "CAMP_mucho"),             "support": 0.05472637, "confidence": 0.9428571, "lift": 2.450616}, 
    { "itemset" : ("AA", "CAMPING", "INDU_medio", "CAMP_mucho"),  "support": 0.05306799, "confidence": 0.9142857, "lift": 2.376355}, 
    { "itemset" : ("BB", "CAMP_medio", "CAMPING"),                "support": 0.05140962, "confidence": 0.8857143, "lift": 1.589541}, 
    { "itemset" : ("BB", "CAMP_poco", "CAMPING"),                 "support": 0.06799337, "confidence": 0.8723404, "lift": 1.565540}, 
    
    # supp=0.025
    # conf=0.7

    { "itemset" : ("AA", "PESP_medio", "CAMPING"),    "support": 0.04311774, "confidence": 0.8965517, "lift": 1.608990}, 
    { "itemset" : ("MB", "PESC_medio", "PESR_medio"), "support": 0.02819237, "confidence": 0.8095238, "lift": 4.648980}, 
    { "itemset" : ("AA", "INST_poco", "CAMPING"),     "support": 0.03482587, "confidence": 0.7000000, "lift": 1.256250}, 
    { "itemset" : ("AA", "INDP_medio", "CAMPING"),    "support": 0.05804312, "confidence": 0.8139535, "lift": 1.460756}, 
    { "itemset" : ("INDU_medio", "MA", "CAMPING"),    "support": 0.02653400, "confidence": 0.7619048, "lift": 1.367347}, 
    { "itemset" : ("CUCH_poco", "MA", "CAMPING"),     "support": 0.02985075, "confidence": 0.7826087, "lift": 1.404503}, 
    { "itemset" : ("MA", "OPTI_medio", "CAMPING"),    "support": 0.02653400, "confidence": 0.7272727, "lift": 1.305195}, 
    { "itemset" : ("AA", "PESR_medio", "CAMPING"),    "support": 0.04311774, "confidence": 0.7428571, "lift": 1.333163}, 
    { "itemset" : ("AA", "PESP_medio", "CAMPING"),    "support": 0.04311774, "confidence": 0.8965517, "lift": 1.608990}, 

    # 2do mail
    
    # supp=0.05
    # conf=0.7

    { "itemset" : ("AA", "CAMPING", "TIRO_poco", "CAMP_mucho"),  "support": 0.06301824, "confidence": 0.9743590, "lift": 2.532493 },
    { "itemset" : ("AA", "INDP_medio", "CAMP_mucho"),            "support": 0.06633499, "confidence": 0.9302326, "lift": 2.417803 },
    { "itemset" : ("AA", "PESR_medio", "CAMP_mucho"),            "support": 0.05140962, "confidence": 0.8857143, "lift": 2.3020936},
    { "itemset" : ("AA", "CAMP_mucho", "INDU_medio", "CAMPING"), "support": 0.05306799, "confidence": 0.7272727, "lift": 1.305195 },
    
    # supp=0.025
    # conf=0.7

    { "itemset" : ("AA", "OPTI_poco", "CAMPING"),                    "support": 0.02985075, "confidence": 0.7200000, "lift": 1.292143},
    { "itemset" : ("AA", "INDU_poco", "CAMP_mucho"),                 "support": 0.04975124, "confidence": 0.8823529, "lift": 2.293357},
    { "itemset" : ("AA", "PESR_medio", "CAMP_mucho"),                "support": 0.05140962, "confidence": 0.8857143, "lift": 2.302094},
    { "itemset" : ("AA", "Capital Federal", "TIRO_poco", "CAMPING"), "support": 0.02653400, "confidence": 0.9411765, "lift": 1.689076},
    { "itemset" : ("AA", "PESP_mucho", "TIRO_medio", "CAMP_mucho"),  "support": 0.03482587, "confidence": 0.9130435, "lift": 2.373126},
    { "itemset" : ("AA", "INDU_mucho", "TIRO_poco", "CAMP_mucho"),   "support": 0.02819237, "confidence": 1.0000000, "lift": 2.599138},
    { "itemset" : ("AA", "INST_poco", "PESC_mucho", "CAMP_mucho"),   "support": 0.02653400, "confidence": 1.0000000, "lift": 2.599138},
]                                                                                         
                                                                                          
if __name__ == '__main__':

    with open(sys.argv[1], 'r') as dataset_2015:
        clientes_2015 = [cliente for cliente in csv.DictReader(dataset_2015, delimiter=';', quotechar='"')]
        T = float(len(clientes_2015)) # # total de clientes
        print('itemset_regla,support_2014,support_2015')
        for regla in reglas_2014:
            # cantidad de clientes que tienen todas las categorías del lhs & rhs de esta regla
            support_count_sigma = len(filter(lambda c: all(categoria in c.itervalues() for categoria in regla["itemset"]), clientes_2015))
            support = support_count_sigma / T
            print('"%s",%.2f,%.2f' % (','.join(regla["itemset"]), regla["support"], support))
