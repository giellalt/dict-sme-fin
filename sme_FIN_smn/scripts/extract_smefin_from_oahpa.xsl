<?xml version="1.0"?>
<!--+
    | 
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:fn="fn"
		xmlns:local="nightbar"
		exclude-result-prefixes="xs fn local">
    
  <xsl:strip-space elements="*"/>

  <xsl:output method="text" name="txt"
	      encoding="UTF-8"
	      omit-xml-declaration="yes"
	      indent="no"/>

  <xsl:output method="xml" name="xml"
              encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>
  

<xsl:function name="local:distinct-deep" as="node()*">
  <xsl:param name="nodes" as="node()*"/> 
 
  <xsl:sequence select=" 
    for $seq in (1 to count($nodes))
    return $nodes[$seq][not(local:is-node-in-sequence-deep-equal(
                          .,$nodes[position() &lt; $seq]))]
 "/>
   
</xsl:function>

<xsl:function name="local:is-node-in-sequence-deep-equal" as="xs:boolean">
  <xsl:param name="node" as="node()?"/> 
  <xsl:param name="seq" as="node()*"/> 
 
  <xsl:sequence select=" 
   some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
 "/>
   
</xsl:function>


  <xsl:param name="inFile" select="'_x_'"/>
  <xsl:param name="inDir" select="'src_smefin_oahpa'"/>
  <xsl:param name="outDir" select="'only_smefin_src'"/>

  <xsl:variable name="debug" select="true()"/>
  <xsl:variable name="of" select="'xml'"/>
  <xsl:variable name="e" select="$of"/>

  <xsl:template match="/" name="main">
    
    <xsl:for-each select="collection(concat($inDir, '?select=*.xml'))">
      
      <xsl:variable name="current_file" select="substring-before((tokenize(document-uri(.), '/'))[last()], '.xml')"/>
      <xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
      <xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
      
      <xsl:message terminate="no">
	<xsl:value-of select="concat('Processing file: ', $current_file)"/>
      </xsl:message>
      
      <xsl:result-document href="{$outDir}/{$current_file}.{$e}" format="{$of}">
	<r xml:lang="sme">
	  <xsl:for-each select="./r/e[some $t in
				.//tg[./@xml:lang='fin']/t satisfies not(normalize-space($t)='')]">

	    <e>
	      <lg>
		<l pos="{./lg/l/@pos}">
		  <xsl:value-of select="normalize-space(./lg/l)"/>
		</l>
	      </lg>
	      <xsl:for-each select="./mg[some $t in
				    ./tg[./@xml:lang='fin']/t satisfies not(normalize-space($t)='')]">
		<mg>
		  <xsl:for-each select="./tg[./@xml:lang='fin'][some $t in ./t satisfies not(normalize-space($t)='')]">
		    <tg xml:lang="{./@xml:lang}">
		      <xsl:for-each select="./t[not(normalize-space(.)='')]">
			<t>
			  <xsl:if test="./@pos and not(normalize-space(./@pos)='')">
			    <xsl:attribute name="pos">
			      <xsl:value-of select="normalize-space(./@pos)"/>
			    </xsl:attribute>
			  </xsl:if>
			  <xsl:value-of select="normalize-space(.)"/>
			</t>
		      </xsl:for-each>
		    </tg>
		  </xsl:for-each>
		</mg>
	      </xsl:for-each>
	    </e>
	  </xsl:for-each>
	</r>
      </xsl:result-document>
    </xsl:for-each>
    
  </xsl:template>
  
</xsl:stylesheet>

