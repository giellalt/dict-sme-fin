#!/usr/bin/perl -w
use utf8 ;

# Simple script to convert csv to xml
# For input/outpus examples, see below.


print STDOUT "<r>\n";

while (<>) 
{
	chomp ;
	my ($lemma, $trans, $lPOS, $tPOS) = split /_/ ;
	my @lemma = split /, /, $lemma ;
	my @trans = split /, /, $trans ;
	my @lPOS = split /, /, $lPOS ;
	my @tPOS = split /, /, $tPOS ;
	print STDOUT "  <e>\n";
	print STDOUT "    <l pos=\"$lPOS\">$lemma</l>\n";
	print STDOUT "    <mg>\n";
	print STDOUT "      <tg>\n";
	print STDOUT "        <t pos=\"$tPOS\">$trans</t>\n";
	print STDOUT "      </tg>\n";
	print STDOUT "    </mg>\n";
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