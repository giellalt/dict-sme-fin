<?xml version="1.0"?>
<!--+
    | Usage: 
    | java -Xmx2048m net.sf.saxon.Transform -it main THIS-FILE inFile="WHOLE-DICT".xml
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:fn="fn"
		xmlns:local="nightbar"
		exclude-result-prefixes="xs fn local">
    
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
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


  <!--   Input file in text format: as parameter -->
  <xsl:param name="inFile" select="'../src/x_finsmn.xml'"/>
  <xsl:param name="outputDir" select="'_out_src_'"/>
  <xsl:variable name="lang_pair" select="'fin2smn'"/>
  <xsl:variable name="slang" select="'fin'"/>
  
  <!-- Patterns for the feature values -->
  <xsl:variable name="e" select="'xml'"/>
  <xsl:variable name="file_name" select="substring-before((tokenize($inFile, '/'))[last()], '.xml')"/>
  
  
  <xsl:template match="/" name="main">
    
    <xsl:for-each-group select="doc($inFile)/r/e" group-by="./lg/l/@pos">
	
      <xsl:message terminate="no">
        <xsl:value-of select="concat('Processing pos: ', current-grouping-key())"/>
      </xsl:message>

      <xsl:result-document href="{$outputDir}/{current-grouping-key()}_{$lang_pair}.{$e}">
	<r xml:lang="{$slang}">
	  <xsl:copy-of select="current-group()"/>
	</r>
      </xsl:result-document>
    </xsl:for-each-group>
    
  </xsl:template>
  
</xsl:stylesheet>

