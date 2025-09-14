#!/usr/bin/env python3
#
# Usage: ./convert_model.py MODEL
#
# MODEL must be a csv-file that follows the format used by Christof
# Schöch for storing his topic models. This script converts the input
# model into the tsv format used by ttm and prints the result to stdout.

import sys

if __name__ == '__main__':
    with open(sys.argv[1]) as f:
        model = { line.split('\t')[1].split('/')[-1]:
                  [ float(n) for n in line.split('\t')[2:] ]
                  for line in f }
    print('id', 'highdim', 'lowdim', sep='\t', end='\n')
    for doc in sorted(model.keys()):
        print(doc, model[doc], model[doc], sep='\t', end='\n')
