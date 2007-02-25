# This is a makefile that builds the sme-fin translation parser

LEXC = lexc -utf8
XFST = xfst -utf8

smefin.fst: ../bin/smefin.fst
../bin/smefin.fst: ../bin/smefin-inter.fst ../../../../gt/sme/bin/isme.fst \
	../../../../kt/fin/bin/fin.save
	@echo
	@echo "*** Building smefin.fst ***" 
	@echo
	@printf "read regex [ [@\"../../../../gt/sme/bin/isme.fst\" ] .o. \
	[@\"../bin/smefin-inter.fst\"] .o. [@\"../../../../kt/fin/bin/fin.save\"] ] ; \n\
	save stack ../bin/smefin.fst \n\
	quit \n" > ../../tmp/smefin-save-script
	$(XFST) < ../../tmp/smefin-save-script
	@rm -rf ../../tmp/smefin-save-script

smefin-inter.fst: ../bin/smefin-inter.fst
../bin/smefin-inter.fst: smefin-lex.txt  adj-smefin-lex.txt adv-smefin-lex.txt \
	conjunction-smefin-lex.txt interjection-smefin-lex.txt noun-smefin-lex.txt \
	numeral-smefin-lex.txt particle-smefin-lex.txt pp-smefin-lex.txt \
	pronoun-smefin-lex.txt subjunction-smefin-lex.txt verb-smefin-lex.txt
	@echo
	@echo "*** Building smefin-inter.fst ***" 
	@echo
	@printf "compile-source smefin-lex.txt  adj-smefin-lex.txt adv-smefin-lex.txt \
	conjunction-smefin-lex.txt interjection-smefin-lex.txt noun-smefin-lex.txt \
	numeral-smefin-lex.txt particle-smefin-lex.txt pp-smefin-lex.txt \
	pronoun-smefin-lex.txt subjunction-smefin-lex.txt verb-smefin-lex.txt \n\
	source-to-result \n\
	save-result ../bin/smefin-inter.fst \n\
	quit \n" > ../../tmp/smefin-inter-save-script
	$(LEXC) < ../../tmp/smefin-inter-save-script
	@rm -f ../../tmp/smefin-inter-save-script

