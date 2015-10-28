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
    <xsl:for-each select="$docs/TEI/teiHeader/fileDesc/sourceDesc/msDesc/history/origin/date">
      <xsl:call-template name="extract"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:value-of select="tei:jsonObject(tei:jsonArray('TEI',$all,false()))"/>
</xsl:template>

<xsl:template name="extract">
    <xsl:value-of select="tei:jsonObject((
			  tei:json('xpath',tei:xpath(.), true()),
			  tei:json('id',ancestor-or-self::TEI/teiHeader//idno[1], true()),
			  tei:dateJson('date',.),
			  tei:deco('object',ancestor-or-self::TEI//teiHeader//decoNote)
			  ))"/>
</xsl:template>

  <xsl:function name="tei:deco" as="xs:string">
    <xsl:param name="label"/>
    <xsl:param name="content"/>
    <xsl:variable name="result" as="xs:string*">
      <xsl:for-each select="$content">
	<xsl:variable name="c" as="xs:string+">
          <xsl:value-of select="tei:json('type','symbol',true())"/>
          <xsl:value-of select="tei:json('value',.,true())"/>
	</xsl:variable>
	<xsl:variable name="cr" >
	  <xsl:value-of select="($c)" separator=","/>
	</xsl:variable>
	<xsl:value-of select="tei:jsonObject($cr)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="tei:jsonArray($label,$result,false())"/>
  </xsl:function>
  
  
  <xsl:function name="tei:dateJson" as="xs:string">
    <xsl:param name="label"/>
    <xsl:param name="content"/>
    <xsl:variable name="result" as="xs:string+">
      <xsl:value-of select="tei:json('value',$content,true())"/>
      <xsl:for-each select="$content/@*">
	<xsl:value-of select="tei:json(local-name(),.,true())"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="r">
      <xsl:value-of select="($result)" separator=","/>
    </xsl:variable>
    <xsl:value-of select="tei:json($label,tei:jsonObject($r),false())"/>
  </xsl:function>
  

</xsl:stylesheet>
