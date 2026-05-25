#!/usr/bin/python

import argparse
from lxml import etree
from pathlib import Path
import subprocess
import os

"""
This script is used for importing example sentences from the dict-sme-nob repository
into the dict-sme-fin repository. It places all examples into the first mg and replaces the Norwegian translation
with the text _FIN_

Run as follows:

python import-examples-from-smenob.py <sme-nob file> <sme-fin file>

The output is written to the sme-fin file. 
"""

def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("sme_nob", type=Path)
    parser.add_argument("sme_fin", type=Path)

    return parser.parse_args()


def get_entry_id(entry):
    l = entry.xpath("./lg/l")[0]
    l_id = (l.text, l.get("pos"), l.get("type"))
    return l_id


def replace_example_translation(xg):
    xt = xg.xpath('./xt')[0]
    xt.text = "_FIN_"
    return xg


def fetch_examples(smenob_entry, smefin_entry):
    smefin_first_tg = smefin_entry.xpath('./mg/tg')[0]
    xgs = smenob_entry.xpath('.//xg')
    for xg in xgs:
        xg = replace_example_translation(xg)
        smefin_first_tg.append(xg)


def main(args):
    smenob_tree = etree.parse(args.sme_nob)

    smefin_tree = etree.parse(args.sme_fin)

    smenob_root = smenob_tree.getroot()
    smefin_root = smefin_tree.getroot()


    # Iterate through smefin entries. Look them up by l in smenob and fetch examples.
    for entry in smefin_root.iter("e"):
        l = entry.xpath("./lg/l")[0]
        l_id = (l.text, l.get("pos"), l.get("type"))
        smenob_l_list = smenob_root.xpath(f'.//l[text()="{l.text}"]')
        if len(smenob_l_list) == 1:
            # Match! Fetch examples from this entry
            smenob_entry = smenob_l_list[0].getparent().getparent()
            fetch_examples(smenob_entry, entry)
        elif len(smenob_l_list) > 1:
            # Multiple matches! Try to find the correct using pos and type
            match = False
            for smenob_l in smenob_l_list:
                if smenob_l.get("pos") == l.get("pos") and smenob_l.get("type") == l.get("type"):
                    smenob_entry = smenob_l.getparent().getparent()
                    fetch_examples(smenob_entry, entry)
                    match = True
                    continue
            # If no match, print info:
            if not match:
                print(f"Could not resolve {l_id}. Please fetch manually")


    smefin_tree.write(args.sme_fin, pretty_print=True, encoding="utf-8")



if __name__ == "__main__":
    raise SystemExit(main(parse_args()))