# This is a makefile that builds the sme-fin translation parser

# It should be rewritten with Twig or something similar instead of 
# the shellscript we have now

# =========== Tools: ============= #
LEXC = lexc #-utf8
XFST = xfst #-utf8
XSLT = ~/lib/saxon8.jar
XQL  = java net.sf.saxon.Query
JARF = -jar
SSH  = /usr/bin/ssh

# =========== Paths & files: ============= #
GTHOME      = ../../../gt
SMETESTING  = $(GTHOME)/sme/testing
SMENOBMAC   = deliv/macdict/objects
SMENOBNAME  = Nordsamisk-norsk ordbok.dictionary
SMENOBZIP   = smefin-mac.dictionary.tgz
UPLOADDIR   = sd@giellatekno.uit.no:xtdoc/sd/src/documentation/content/xdocs
DOWNLOADDIR = http://www.divvun.no/static_files
ADJ         = adjective_smefin.xml
ADV         = adverb_smefin.xml
NOUNC       = nounCommon_smefin.xml
NOUNP       = nounRevProper_smefin.xml
NOUNA		= nounActor_smefin.xml
NOUNG		= nounG3_smefin.xml
OTHER       = nounProperPl_smefin.xml
VERB        = verb_smefin.xml
SN_XML      = smefin.xml
SN_XSL      = smefin.xsl
SN_LEXC     = smefin.lexc
SN_HTML     = smefin.html
SN_FST      = smefin.fst
S_DIC       = sme.dic
S_FST       = smedic.fst
SRC         = src
BIN         = bin
SCRIPTS     = scripts
BEGIN       = @echo "*** Generating the $@-file ***"
END         = @echo "Done."

# =========== Other: ============= #
DATE = $(shell date +%Y%m%d)

# fst for the sme-fin dictionary

#Pseudocode:											    
#Make a lexc file:										    
#Print the first line: LEXICON Root						    
#Then, for each entry, make lines of the format smelemma:firstfintranslation # ;
#Then print the result to file.
#Then make xfst read it with the command read lexc.
# The trick is that only the first <t node may be chosen, there may be several.

# Target to create a fst transducer picking just the first translation of each 
# lemma. And while we're at it, we invert it as well.

# Create the smefin.fst-file
$(SN_FST): $(SN_LEXC)
	@echo
	$(BEGIN)
	@echo
	@printf "read lexc < $(BIN)/$< \n\
	save $(BIN)/ismefin.fst \n\
	invert net \n\
	save $(BIN)/$@ \n\
	quit \n" > ../tmp/smefin-save-script
	$(XFST) < ../tmp/smefin-save-script
	@rm -rf ../tmp/smefin-save-script
	@echo
	$(END)
	@echo

# # fst for the Sámi words in the dictionary
# # Pseudocode:
# # Pick the lemmas, and print them to list
# # Read the list into xfst
# # Save as an automaton.
# # The perlscript for glossing should use smefin.lexc or something similar.
# #
# # Create the smedic.fst-file
$(S_FST): $(S_DIC)
	@echo
	$(BEGIN)
	@echo
	@printf "read text < $(BIN)/$< \n\
	save stack $> \n\
	quit \n" > ../tmp/smedic-save-script
	$(XFST) < ../tmp/smedic-save-script
	@rm -f ../tmp/smedic-save-script
	@rm -f $(BIN)/$<

# # Create the sme.dic file from the smefin.xml-file
$(S_DIC): $(SN_XML)
	@echo
	$(BEGIN)
	@java $(JARF) $(XSLT) $(BIN)/$(SN_XML) $(SCRIPTS)/get-lemma.xsl > $(BIN)/$@
	@echo
	$(END)
	@echo

# Create the lexc file from the smefin.xml-file (using XQuery 1.0)
$(SN_LEXC): $(SN_XML)
	@echo
	$(BEGIN)
	@$(XQL) $(SCRIPTS)/smefin-pairs.xql smefin=../$(BIN)/$< > $(BIN)/$@
	@echo
	$(END)
	@echo

# Create the lexc file from the smefin.xml-file (using XSLT 2.0, which is not as nice as XQuery)
# $(SN_LEXC): $(SN_XML)
# 	@echo
# 	$(BEGIN)
# 	@java $(JARF) $(XSLT) $(BIN)/$< $(SCRIPTS)/smefin-pairs.xsl > $(BIN)/$@
# 	@echo
# 	$(END)
# 	@echo

# Create a simple HTML file for local browsing of the whole dictionary
$(SN_HTML): $(SN_XML) $(SCRIPTS)/$(SN_XSL)
	@echo
	$(BEGIN)
	@java $(JARF) $(XSLT) $(BIN)/$(SN_XML) $(SCRIPTS)/$(SN_XSL) > $(BIN)/$@
	@echo
	$(END)
	@echo

# Create the smefin.xml-file by unifing the individual parts (using XQuery 1.0)
$(SN_XML):
	@echo
	$(BEGIN)
	@$(XQL) $(SCRIPTS)/collect-smefin-parts.xql \
	 adj=../$(SRC)/$(ADJ) adv=../$(SRC)/$(ADV) nounc=../$(SRC)/$(NOUNC) nouna=../$(SRC)/$(NOUNA) \
	 noung=../$(SRC)/$(NOUNG) nounp=../$(SRC)/$(NOUNP) other=../$(SRC)/$(OTHER) verb=../$(SRC)/$(VERB) > $(BIN)/$@
	@echo
	$(END)
	@echo

# Create the smefin.xml-file by unifing the individual parts (using XSLT 2.0, which is not as nice as XQuery)
# $(SN_XML):
# 	@echo
# 	$(BEGIN)
# 	@java $(JARF) $(XSLT) $(SCRIPTS)/dummy.xml $(SCRIPTS)/collect-smefin-parts.xsl \
# 	 adj=../$(SRC)/$(ADJ) adv=../$(SRC)/$(ADV) nounc=../$(SRC)/$(NOUNC) \
# 	 nounp=../$(SRC)/$(NOUNP) nouna=../$(SRC)/$(NOUNA) \
#	 noung=../$(SRC)/$(NOUNG) other=../$(SRC)/$(OTHER) verb=../$(SRC)/$(VERB) > $(BIN)/$@
# 	@echo
# 	$(END)
# 	@echo




# Target to make a MacOS X/Dictionary.app compatible dictionary bundle:
macdict: macdict/smefin.xml
macdict/smefin.xml: src/smefin.xml \
					scripts/smefin2macdict.xsl \
					scripts/add-paradigm.xsl
	@echo
	@echo "*** Extracting words from dictionary file. ***"
	@echo
	grep '<l pos' $< | \
	   perl -pe 's/^.*pos="([^"]+)">(.+)<.*$$/\2	\1/' | \
	   grep '	[nav]$$' | grep -v '^-' | sort -u \
	   > $(SMETESTING)/dictwords.txt
	@echo
	@echo "*** Generating paradigms. ***"
	@echo
	cd $(SMETESTING) && ./gen-paradigms.sh dictwords.txt
	@echo
	@echo "*** Building smefin.xml for MacOS X Dictionary ***" 
	@echo
	java -Xmx1024m \
		org.apache.xalan.xslt.Process \
		-in  $< \
		-out $@.tmp \
		-xsl scripts/add-paradigm.xsl \
		-param gtpath $(SMETESTING)
	@xsltproc scripts/smefin2macdict.xsl $@.tmp > $@
	rm -f $@.tmp
	@cd deliv/macdict && make

# Target to upload a MacOSX dictionary module
upload-macdict:
	@echo
	@echo "*** TAR-ing and ZIP-ing smefin Mac dictionary ***"
	@echo
	tar -czf $(SMENOBZIP) "$(SMENOBMAC)/$(SMENOBNAME)"
	@echo
	@echo "*** Uploading smefin Mac dictionary to www.divvun.no ***"
	@echo
	@scp $(SMENOBZIP) $(UPLOADDIR)/static_files/$(DATE)-$(SMENOBZIP)
	@$(SSH) sd@divvun.no \
		"cd staticfiles/ && ln -sf $(DATE)-$(SMENOBZIP) $(SMENOBZIP)"
	@echo
	@echo "*** New zip file for smefin Mac dictionary now available at: ***"
	@echo
	@echo "$(DOWNLOADDIR)/$(DATE)-$(SMENOBZIP)"
	@echo
	@echo "*** Permlink to newest version is always: ***"
	@echo
	@echo "$(DOWNLOADDIR)/$(SMENOBZIP)"
	@echo

clean:
	rm -f $(BIN)/*fst $(BIN)/*dic $(BIN)/*lexc $(BIN)/*list $(BIN)/*html $(BIN)/*xml $(BIN)/*txt

