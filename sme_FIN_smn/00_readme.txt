
Task info:
http://giellatekno.uit.no/doc/admin/giellatekno/150520.html
http://giellatekno.uit.no/doc/mt/smesmn/BidixImprovementPlan.html


1. finsmn to GT xml 
1.1 csv2simple-xml
sh csv2xml_awk.sh

1.2 simple-xml2gt-xml
_six sxml2xml.xsl

1.3 sort by pos
_six split_file_by_pos.xsl

2. unify smefin/src with ped/sme/src data *)
2.1 extract smefin data from the ped/sme/src
_six extract_smefin_from_oahpa.xsl

2.2 extract smefin data from smefin/src
smefin>_six extract_e_dir.xsl

2.2 unify it with smefin/src data
 - pos values are not the same: syching is necessary
 -TODO

3. generate intersected dict
 -TODO


Notes
=====

*) ped/sme/src is problematic in this context. We start out with 3645 entries>
cat ../../../ped/sme/src/*l|grep '<l '|wc -l
but if we remove entries that are either known, substandard or inflected forms,
we are left with 46 ("smefin" = look the word up in the smefin dict):

cat ../../../ped/sme/src/*l|grep '<l '|tr '<' '>'|cut -d">" -f3|smefin|grep '?'|grep -v '[A-ZČŠÁ ]'|cut -f1|usme|egrep '(Inf|Sg\+Nom|Adv)$'|grep -v 'Err/Orth'|cut -f1|uniq |wc -l

These 46 might be better treated by manually considering adding them to smefin.

For smnfin, the situation is different. Here we might have a look at 
ped/smn/src, and see whether the smnfin entries may add to 
the finsmn dictionary (since the smn Oahpa contains a terminology database).

==========================
Notes on bidix compilation
==========================

1. Cip's internal deadline: 01.10.2015
   (waiting for the disambiguation of 508 strings from Miina)

2. input for the intersecting script:
   (a) main/words/dicts/smefin/src 
   (b) main/words/dicts/finsmn/src
       (now still in main/words/dicts/finsmn/inc/2015/2_*)

3. xml format of the input file for generating apertium bidix format
   (as we discussed earlier with CG, TT and LA)

   sme_LEMMA (fin_LINKING_LEMMAS as attribute) smn_TRANSLATIONS

Ex.


   <e>
      <lg>
         <l pos="N">miellahttuvuohta</l>
      </lg>
      <mg>
         <tg xml:lang="smn">
            <t pos="N" links="jäsenyys">jäsenyys</t>
         </tg>
      </mg>
   </e>


4. further issues
   4.1 linking refinements: add pos to the fin linking lemmata
   4.2 proper nouns treatment for bidix file

5. generating apertium bidix files:
   docu, templates, scripts for generating bidix files?
   ==> Cip has to ask Trond and/or Francis

