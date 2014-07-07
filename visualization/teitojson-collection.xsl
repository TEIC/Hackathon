<xsl:stylesheet
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"                
    exclude-result-prefixes="tei xs"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    >
<xsl:strip-space elements="*"/>
<xsl:output method="text" encoding="utf-8" />
<xsl:variable name="inq">"</xsl:variable>
<xsl:variable name="outq">\\"</xsl:variable>
<xsl:template match="/">
  <xsl:call-template name="extract"/>
</xsl:template>


<xsl:template name="extract">
  <xsl:for-each select="//date">
    <n id="{ancestor-or-self::TEI/teiHeader//idno[1]}">
      <xsl:choose>
	<xsl:when test="@when">
	  <xsl:value-of select="@when"/>
	</xsl:when>
	<xsl:otherwise>
	       <xsl:apply-templates select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </n>
  </xsl:for-each>
</xsl:template>

<xsl:template name="main">
  <xsl:variable name="docs" select="collection('../texts?select=*.xml;recurse=yes;on-error=warning')"/> 
  <xsl:variable name="objects">
       <xsl:for-each select="$docs/*">	 
	 <xsl:call-template name="extract"/>
       </xsl:for-each>
  </xsl:variable>
  <xsl:text>{"TEI": [</xsl:text>
  <xsl:for-each select="$objects/*" >
    <xsl:text>{ </xsl:text>
    <xsl:sequence select="tei:json('id',@id, false())"/>
    <xsl:sequence select="tei:json('value',.,true())"/>
    <xsl:text> }</xsl:text>
    <xsl:if test="position() != last()">,</xsl:if>
    <xsl:text>&#10;</xsl:text>
  </xsl:for-each>
<xsl:text>
] }
</xsl:text>

</xsl:template>

<xsl:template match="text()">
  <xsl:value-of select="replace(replace(normalize-space(.),'\\','\\\\'),$inq,$outq)"/>
</xsl:template>

<xsl:function name="tei:jsonnumber" as="xs:string">
  <xsl:param name="label"/>
  <xsl:param name="content"/>
  <xsl:param name="last"/>
  <xsl:variable name="result">
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$label"/>
    <xsl:text>":</xsl:text>
    <xsl:value-of select="$content"/>
      <xsl:text></xsl:text>
    <xsl:if test="not($last)">
      <xsl:text>,</xsl:text>
    </xsl:if>
  </xsl:variable>
  <xsl:value-of select="$result"/>
</xsl:function>

<xsl:function name="tei:json" as="xs:string">
  <xsl:param name="label"/>
  <xsl:param name="content"/>
  <xsl:param name="last"/>
  <xsl:variable name="result">
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$label"/>
    <xsl:text>":"</xsl:text>
    <xsl:value-of select="$content"/>
      <xsl:text>"</xsl:text>
    <xsl:if test="not($last)">
      <xsl:text>,</xsl:text>
    </xsl:if>
  </xsl:variable>
  <xsl:value-of select="$result"/>
</xsl:function>

<xsl:function name="tei:jsonbycontext" as="xs:string">
  <xsl:param name="label"/>
  <xsl:param name="content"/>
  <xsl:param name="last"/>
  <xsl:variable name="result">
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$label"/>
    <xsl:text>":"</xsl:text>
    <xsl:for-each select="$content">
      <xsl:apply-templates/>
    </xsl:for-each>
      <xsl:text>"</xsl:text>
    <xsl:if test="not($last)">
      <xsl:text>,</xsl:text>
    </xsl:if>
  </xsl:variable>
  <xsl:value-of select="$result"/>
</xsl:function>

</xsl:stylesheet>
