<xsl:stylesheet
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"                
    exclude-result-prefixes="tei xs"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    >
<xsl:include href="jsonlib.xsl"/>

<xsl:strip-space elements="*"/>
<xsl:output method="text" encoding="utf-8" />
  
<xsl:template match="/">
  <xsl:call-template name="main"/>
</xsl:template>

<xsl:template name="main">
  <xsl:variable name="docs" select="collection('../texts?select=*.xml;recurse=yes;on-error=warning')"/> 
  <xsl:variable name="all" as="xs:string+">
    <xsl:for-each select="$docs/TEI[.//geo[@decls='#WGS']]">
      <xsl:variable name="geo"><xsl:value-of   select="ancestor-or-self::TEI/teiHeader//geo[@decls='#WGS']"/></xsl:variable>
      <xsl:if test="teiHeader//profileDesc/particDesc/listPerson//event[@type='dateofdeath']">
      <xsl:value-of select="tei:jsonObject((
			    tei:json('id',ancestor-or-self::TEI/teiHeader//idno[1], true()),
			    tei:json('year',(ancestor-or-self::TEI/teiHeader//profileDesc/particDesc/listPerson//event[@type='dateofdeath'])[1]/@when/substring(.,1,4),false()),
			    tei:json('long',substring-after($geo,' '),false()),
			    tei:json('image',ancestor-or-self::TEI/facsimile/graphic[1]/@url,true())
			    ))"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:value-of select="tei:jsonObject(tei:jsonArray('TEI',$all,false()))"/>
</xsl:template>

</xsl:stylesheet>
