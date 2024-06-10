#!/usr/bin/perl -w
use utf8 ;

# Simple script to convert csv to xml
# For input/outpus examples, see below.


print STDOUT "<r>\n";

while (<>) 
{
	chomp ;
	my ($lemma, $POS, $trans1, $trans2, $trans3, $trans4, $trans5, $trans6, $trans6, $trans7, $trans8) = split /\t/ ;
#	my ($lemma, $trans, $lPOS, $tPOS) = split /_/ ;
#	my @lemma = split /, /, $lemma ;
#	my @trans = split /, /, $trans ;
#	my @lPOS = split /, /, $lPOS ;
#	my @tPOS = split /, /, $tPOS ;
	print STDOUT "  <e>\n";
	print STDOUT "   <lg>\n";
	print STDOUT "    <l pos=\"$POS\">$lemma</l>\n";
	print STDOUT "   </lg>\n";
	print STDOUT "    <mg>\n";
	print STDOUT "      <tg xml:lang=\"fin\">\n";
	print STDOUT "        <t pos=\"$POS\">$trans1</t>\n";
	print STDOUT "      </tg>\n";
	print STDOUT "    </mg>\n";
	print STDOUT "    <mg>\n";
	print STDOUT "      <tg xml:lang=\"fin\">\n";
	print STDOUT "        <t pos=\"$POS\">$trans2</t>\n";
	print STDOUT "      </tg>\n";
	print STDOUT "    </mg>\n";
	print STDOUT "    <mg>\n";
	print STDOUT "      <tg xml:lang=\"fin\">\n";
	print STDOUT "        <t pos=\"$POS\">$trans3</t>\n";
	print STDOUT "      </tg>\n";
	print STDOUT "    </mg>\n";
	print STDOUT "    <mg>\n";
	print STDOUT "      <tg xml:lang=\"fin\">\n";
	print STDOUT "        <t pos=\"$POS\">$trans4</t>\n";
	print STDOUT "      </tg>\n";
	print STDOUT "    </mg>\n";
	print STDOUT "    <mg>\n";
	print STDOUT "      <tg xml:lang=\"fin\">\n";
	print STDOUT "        <t pos=\"$POS\">$trans5</t>\n";
	print STDOUT "      </tg>\n";
	print STDOUT "    </mg>\n";
	print STDOUT "    <mg>\n";
	print STDOUT "      <tg xml:lang=\"fin\">\n";
	print STDOUT "        <t pos=\"$POS\">$trans6</t>\n";
	print STDOUT "      </tg>\n";
	print STDOUT "    </mg>\n";
	print STDOUT "    <mg>\n";
	print STDOUT "      <tg xml:lang=\"fin\">\n";
	print STDOUT "        <t pos=\"$POS\">$trans7</t>\n";
	print STDOUT "      </tg>\n";
	print STDOUT "    </mg>\n";
	print STDOUT "    <mg>\n";
	print STDOUT "      <tg xml:lang=\"fin\">\n";
	print STDOUT "        <t pos=\"$POS\">$trans8</t>\n";
	print STDOUT "      </tg>\n";
	print STDOUT "    </mg>\n";
#	print STDOUT "    <mg>\n";
#	print STDOUT "      <tg xml:lang=\"fin\">\n";
#	print STDOUT "        <t pos=\"$POS\">$trans9</t>\n";
#	print STDOUT "      </tg>\n";
#	print STDOUT "    </mg>\n";
#	print STDOUT "    <mg>\n";
#	print STDOUT "      <tg xml:lang=\"fin\">\n";
#	print STDOUT "        <t pos=\"$POS\">$trans10</t>\n";
#	print STDOUT "      </tg>\n";
#	print STDOUT "    </mg>\n";
	print STDOUT "  </e>\n";
}

print STDOUT "</r>\n";




# Example input:
#
# се̄ййп_N_ANIMAL_хвост длинный, длинный хвост
# кӣдтжэва_N_ANIMAL, LIVING-PLACE_животное домашнее, домашнее животное
# оа̄к_N_ANIMAL_лосиха


#Target output:
#
#  <e>
#    <l>на̄ввьт</l>
#    <pos class="N"/>
#    <t>
#      <tr xml:lang="rus">животное домашнее</tr>
#      <tr xml:lang="rus">домашнее животное</tr>
#    </t>
#    <semantics>
#      <sem class="ANIMAL"/>
#      <sem class="LIVING-PLACE"/>
#    </semantics>
#    <sources>
#      <book name="l1"/>
#    </sources>
#  </e>
