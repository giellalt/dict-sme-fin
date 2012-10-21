
# Dette skal bli ei makefil for å lage smefin.fst, 
# ei fst-fil som tar sme og gjev ei fin-omsetjing.

# Førebels er det berre eit shellscript.

# Kommando for å lage smefin.fst
echo "LEXICON Root" > bin/smefin.lexc
cat src/*_smefin.xml | tr '\n' '™' | sed 's/<e>/£/g;'| tr '£' '\n'| sed 's/<re>[^>]*>//g;'|tr '<' '>'| cut -d">" -f5,15| tr ' ' '_'| tr '>' ':'| grep -v '__'|sed 's/$/ # ;/g' >> bin/smefin.lexc
xfst -e "read lexc < bin/smefin.lexc"

# deretter i xfst:
# invert
# save bin/smefin.fst
