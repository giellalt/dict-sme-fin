#!/usr/bin/perl -w
#
# kvasikode
#
# Felt:
# #"lemma","(language) trans (restriction)& (language) trans (restriction)","lPOS","tPOS"

# Les inn felta
# 
# Putt relevante felt inn i relevante stader i xml-strukturen
# 
#   <e>
#     <l pos="lPOS">lemma</l>
#     <mgr>
#       <tg>
#         <t pos="tPOS">trans</t>
#       </tg>
#     </mg>
#   </e>

########################################################

use encoding 'utf-8';


print "<dictionary >\n";

while (<>) {
	chomp;
	$line = $_ ;
print $line;
	($lemma,
     $trans,
     $lPOS,
     $tPOS)
	   = split /"?,"?/, $line ;
#    print "Lina er: $line\n";
#    print "Lemma er: $Lemma\n";
#    $lemma =~ s/"\W?(\w)/$1/; # rens $Lemma for " og ^L
    print "\t<e>\n";
    print "\t  <l pos=\"$lPOS\">$lemma</l>\n";
    print "\t  <mg>\n";
    print "\t    <tg>\n";
    print "\t      <t pos=\"$tPOS\">$trans</t>\n";
    print "\t    </tg>\n";
    print "\t  </mg>\n";
    print "\t</e>\n";
}

print "</dictionary>\n";

