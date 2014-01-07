
# Dette skal bli ei makefil for å lage smefin.fst, 
# ei fst-fil som tar sme og gjev ei fin-omsetjing.

# Førebels er det berre eit shellscript.

echo 
echo "Etter at dette scriptet er ferdig står du i xfst med promten"
echo "xfst[1]"
echo 
echo "Gjör då dette:"
echo "invert"
echo "save bin/smefin.fst"
echo "quit"
echo ""

# Kommando for å lage smefin.fst
echo "LEXICON Root" > bin/smefin.lexc
cat src/*_smefin.xml | tr '\n' '™' | sed 's/<e>/£/g;'| tr '£' '\n'| sed 's/<re>[^>]*>//g;'|tr '<' '>'| cut -d">" -f5,15| tr ' ' '_'| tr '>' ':'| grep -v '__'|sed 's/$/ # ;/g' >> bin/smefin.lexc
#xfst -e "read lexc < bin/smefin.lexc"

printf "read lexc < bin/smefin.lexc \n\
invert net \n\
save stack bin/smefin.fst \n\
quit \n" > tmpfile
xfst -utf8 < tmpfile
rm -f tmpfile

