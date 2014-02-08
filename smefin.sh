
# Dette skal bli ei makefil for å lage smefin.fst, 
# ei fst-fil som tar sme og gjev ei fin-omsetjing.

# Førebels er det berre eit shellscript.


echo ""
echo "Shellscript for å lage smefin.fst"
echo "Det skriv ei fil bin/smefin.lexc"
echo "Deretter tar det kolonne 5 og 15 frå"
echo "alle filene i src/ og legg dei til i lexc-fila."
echo "Resultatet blir kompilert som smefin.fst."
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

