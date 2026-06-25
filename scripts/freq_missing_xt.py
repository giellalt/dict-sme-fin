#!/usr/bin/python

import argparse
from pathlib import Path

from lxml import etree

"""
This script is used for finding all lemmas without example translation and ordering them based on
a frequency list. It creates the file inc/missing_xt_prio.txt which can then be used by lexicographists
to prioritize their work.

freq file can be found at: https://giellatekno.uit.no/lists/sme/sme_lemma.freq.html

Run as follows:

python freq_missing_xt.py <freq file>
"""


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("freq_file", type=Path)

    return parser.parse_args()


def parse_freq_file(filename: Path) -> dict[str, int]:
    freq_dict = {}
    with open(filename, "r") as f:
        lines = f.readlines()
        for line in lines:
            parts = line.strip().split(" ")
            if len(parts) != 3:
                continue
            n, lemma, pos = parts
            id = f"{lemma}_{pos}"
            freq_dict[id] = int(n)
    return freq_dict


def main(args):
    xml_folder = Path(__file__).parent.parent / "src"
    output_folder = Path(__file__).parent.parent / "inc"
    freq_dict = parse_freq_file(args.freq_file)

    lemmas = []
    for file in xml_folder.glob("*.xml"):
        if file.name == "meta.xml":
            continue

        root = etree.parse(file).getroot()

        # e > mg > tg > xg > xt
        for e in root.iter("e"):
            xts = e.findall(".//xt")
            if not any([xt is not None and xt.text == "_FIN_" for xt in xts]):
                continue

            l = e.find(".//l")
            if l is None or not l.text:
                print("<e> node hase no lemma. Skipping...")
                continue
            lemma = l.text
            pos = l.get("pos")
            l_id = f"{lemma}_{pos}"
            pos_file = file.name.replace("_smefin.xml", "")

            if l_id in freq_dict.keys():
                lemmas.append((lemma, pos, freq_dict[l_id], pos_file))
            else:
                print("Not in freq list:", lemma)
                lemmas.append((lemma, pos, 0, pos_file))

    lemmas.sort(key=lambda x: x[2], reverse=True)
    # output_filename = file.name.replace("smefin.xml", "") + "missing_xt.txt"
    output = output_folder / "missing_xt_prio.txt"
    with open(output, "w") as f:
        f.writelines([f"{l[0]}\t{l[3]}\n" for l in lemmas])


if __name__ == "__main__":
    raise SystemExit(main(parse_args()))
