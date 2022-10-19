#!/usr/bin/python3

"""
Read a dictionary file containing the ader attribute for adverbs,
copy the attribute to the same lemma in another dictionary file.

Usage:
    python3 copy_ader_attribute.py <source> <dest>
Example:
    python3 copy_ader_attribute.py ../../smenob/src/Adv_smenob.xml ../src/adv_smefin.xml
"""

import sys
import xml.etree.ElementTree as ET

if len(sys.argv) != 3:
    print(__doc__)
    sys.exit()

source_file_name = sys.argv[1]
dest_file_name = sys.argv[2]

ader_dict = {}

if __name__ == "__main__":
    source_tree = ET.parse(source_file_name)
    root = source_tree.getroot()

    for lemma in root.findall(".//l"):
        if lemma.get("ader") is not None:
            ader_dict[lemma.text] = lemma.get("ader")

    dest_tree = ET.parse(dest_file_name)
    root = dest_tree.getroot()

    i = 0
    for lemma in root.findall(".//l"):
        if lemma.text in ader_dict:
            lemma.set("ader", ader_dict[lemma.text])
            i += 1
    
    dest_tree.write(dest_file_name, encoding="UTF-8")

    print("Added 'ader' attribute to {} lemmas".format(i))  