
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

2. unify smefin/src with ped/sme/src data
2.1 extract smefin data from the ped/sme/src
_six extract_smefin_from_oahpa.xsl

2.2 extract smefin data from smefin/src
smefin>_six extract_e_dir.xsl

2.2 unify it with smefin/src data
 - pos values are not the same: syching is necessary
 -TODO

3. generate intersected dict
 -TODO

