<?xml version="1.0"?>
<!--+
    | 
    | compares two lists of words and outputs both the intersection set
    | and the set of items which are in the first but not in the second set
    | NB: The user has to adjust the paths to the input files accordingly
    | Usage: java net.sf.saxon.Transform -it main THIS_FILE
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		exclude-result-prefixes="xs">

  <xsl:strip-space elements="*"/>

  <xsl:output method="text" name="txt"
	      encoding="UTF-8"
	      omit-xml-declaration="yes"
	      indent="no"/>

  <xsl:output method="xml" name="xml"
              encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  <xsl:variable name="tab" select="'&#x9;'"/>
  <xsl:variable name="spc" select="'&#x20;'"/>
  <xsl:variable name="nl" select="'&#xA;'"/>
  <xsl:variable name="cl" select="':'"/>
  <xsl:variable name="scl" select="';'"/>
  <xsl:variable name="us" select="'_'"/>
  <xsl:variable name="rbl" select="'('"/>
  <xsl:variable name="rbr" select="')'"/>
  <xsl:variable name="qm" select="'&#34;'"/>
  <xsl:variable name="cm" select="','"/>
  <xsl:variable name="debug" select="true()"/>

  <!-- input file, extention of the output file -->
  <xsl:param name="inFile" select="'smefin.csv'"/>
  <xsl:param name="of" select="'xml'"/>
  <xsl:param name="outDir" select="'r_out'"/>
  
  <xsl:variable name="rgx" select="'^([^_]+)_([^_]+)_([^_]+)(.*)$'"/>

  
  <xsl:template match="/" name="main">
    
    <xsl:choose>
      <xsl:when test="unparsed-text-available($inFile)">

	<xsl:if test="$debug">
	  <xsl:message terminate="no">
	    <xsl:value-of select="concat('-----------------------------------------', $nl)"/>
	    <xsl:value-of select="concat('processing file ', $inFile, $nl)"/>
	    <xsl:value-of select="'-----------------------------------------'"/>
	  </xsl:message>
	</xsl:if>
	
	<!-- file -->
	<xsl:variable name="file" select="unparsed-text($inFile)"/>
	<xsl:variable name="file_lines" select="distinct-values(tokenize($file, $nl))" as="xs:string+"/>
	<xsl:variable name="dict" as="element()">
	  <r>
	    <xsl:for-each select="$file_lines">
	      <xsl:variable name="normLine" select="normalize-space(.)"/>
	      <xsl:analyze-string select="$normLine" regex="{$rgx}" flags="s">
		<xsl:matching-substring>
		  
		  <xsl:variable name="lemma" select="normalize-space(regex-group(1))"/>
		  <xsl:variable name="pos" select="lower-case(normalize-space(regex-group(2)))"/>
		  <xsl:variable name="target" select="tokenize(regex-group(3), $scl)"/>
		  <xsl:variable name="rest" select="normalize-space(regex-group(4))"/>
		  
		  <xsl:if test="$debug">
		    <xsl:message terminate="no">
		      <xsl:value-of select="concat('lemma: ', $lemma, $nl)"/>
		      <xsl:value-of select="'............'"/>
		    </xsl:message>
		  </xsl:if>
		  
		  <!--xsl:if test="$rest = ''">
		    <ok>
		      <xsl:value-of select="."/>
		    </ok>
		  </xsl:if-->
		  <!--xsl:if test="not($rest = '')">
		    <ko>
		      <xsl:value-of select="."/>
		    </ko>
		  </xsl:if-->

		  <e>
		    <lg>
		      <l pos="{$pos}">
			<xsl:value-of select="$lemma"/>
		      </l>
		    </lg>
		    <xsl:for-each select="$target">
		      <xsl:variable name="current_tg" select="normalize-space(.)"/>
		      <xsl:variable name="current_re">
			<xsl:if test="contains($current_tg, '#')">
			  <xsl:value-of select="normalize-space(substring-before($current_tg, '#'))"/>
			</xsl:if>
			<xsl:if test="not(contains($current_tg, '#'))">
			  <xsl:value-of select="''"/>
			</xsl:if>
		      </xsl:variable>
		      <xsl:variable name="current_rest">
			<xsl:if test="contains($current_tg, '#')">
			  <xsl:value-of select="normalize-space(substring-after($current_tg, '#'))"/>
			</xsl:if>
			<xsl:if test="not(contains($current_tg, '#'))">
			  <xsl:value-of select="$current_tg"/>
			</xsl:if>
		      </xsl:variable>
		      <mg>
			<tg>
			  <xsl:if test="not($current_re = '')">
			    <re>
			      <xsl:value-of select="$current_re"/>
			    </re>
			  </xsl:if>
			  <xsl:for-each select="tokenize($current_rest, $cm)">
			    <xsl:variable name="current_t" select="normalize-space(.)"/>
			    <xsl:if test="not($current_t = '')">
			      <xsl:variable name="t_info" select="normalize-space(substring-before(substring-after($current_t, $rbl), $rbr))"/>
			      <xsl:if test="not($t_info = '')">
				<t>
				  <xsl:attribute name="info">
				    <xsl:value-of select="$t_info"/>
				  </xsl:attribute>
				  <xsl:value-of select="normalize-space(substring-before($current_t, $rbl))"/>
				</t>
			      </xsl:if>
			      <xsl:if test="$t_info = ''">
				<t>
				  <xsl:value-of select="$current_t"/>
				</t>
			      </xsl:if>
			    </xsl:if>
			  </xsl:for-each>
			</tg>
		      </mg>
		    </xsl:for-each>
		    <xsl:if test="not($debug)">
		      <rest val="{$rest}"/>
		    </xsl:if>
		  </e>
		</xsl:matching-substring>
		<xsl:non-matching-substring>
		  <xsl:if test="$debug">
		    <xsl:message terminate="no">
		      <xsl:value-of select="concat('non-matching-line ', ., $nl)"/>
		      <xsl:value-of select="'............'"/>
		    </xsl:message>
		  </xsl:if>
		  <xxx><xsl:value-of select="."/></xxx>
		</xsl:non-matching-substring>
	      </xsl:analyze-string>
	    </xsl:for-each>
	  </r>
	</xsl:variable>
	
	<!-- compute and output the intersection set: elements that are both in file 1 and in file 2 -->
	<xsl:result-document href="{$outDir}/{$inFile}.{$of}" format="{$of}">
	  <xsl:copy-of select="$dict"/>
	</xsl:result-document>
	
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="concat('Cannot locate file: ', $inFile, $nl)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
