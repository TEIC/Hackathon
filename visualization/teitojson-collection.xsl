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
  <xsl:call-template name="main"/>
</xsl:template>


<xsl:template name="extract">
  <xsl:for-each select="ancestor-or-self::TEI/teiHeader/fileDesc/sourceDesc/msDesc/history/origin/date">
    <xsl:variable name="docid" select="ancestor-or-self::TEI/teiHeader//idno[1]"/>
    <xsl:variable name="symbols" select="ancestor-or-self::TEI//teiHeader//decoNote"/>
    <xsl:variable name="xpath">
      <xsl:for-each select="ancestor::*">
	<xsl:value-of select="name()"/>
	<xsl:text>[</xsl:text>
	<xsl:value-of select="position()"/>
	<xsl:text>]</xsl:text>
	<xsl:text>/</xsl:text>
      </xsl:for-each>
      <xsl:value-of select="name()"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="position()"/>
      <xsl:text>]</xsl:text>
    </xsl:variable>
    
    <xsl:text>{ </xsl:text>
    <xsl:sequence select="tei:json('xpath',$xpath, false())"/>
    <xsl:sequence select="tei:json('id',$docid, false())"/>
    <xsl:sequence select="tei:dateJson('date',.,false())"/>
    <xsl:sequence select="tei:objectJson('object',$symbols,true())"/>
    <xsl:text> },</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:for-each>

</xsl:template>

<xsl:template name="main">
  <xsl:message>Start with collection</xsl:message>
  <xsl:variable name="docs" select="collection('../texts?select=*.xml;recurse=yes;on-error=warning')"/> 
  <xsl:text>{"TEI": [</xsl:text>
       <xsl:for-each select="$docs/*">	 
	 <xsl:call-template name="extract"/>
       </xsl:for-each>
<xsl:text>] }
</xsl:text>

</xsl:template>
  
  
  <xsl:function name="tei:objectJson" as="xs:string">
    <xsl:param name="label"/>
    <xsl:param name="content"/>
    <xsl:param name="last"/>
    <xsl:variable name="result">
          <xsl:text>"</xsl:text>
          <xsl:value-of select="$label"/>
          <xsl:text>"</xsl:text>
          <xsl:text>: [</xsl:text>
          <xsl:for-each select="$content">
            <xsl:text>{"description":"description of the decoration",</xsl:text>
            <xsl:text>"type":"symbol",</xsl:text>
            <xsl:text>"</xsl:text>
            <xsl:text>value</xsl:text>
            <xsl:text>"</xsl:text>
            <xsl:text>:</xsl:text>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>"}</xsl:text>
            <xsl:if test="position()!=last()">
              <xsl:text>,</xsl:text>
            </xsl:if>            
          </xsl:for-each>
          <xsl:text> ]</xsl:text>
      <xsl:if test="not($last)">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="$result"/>
  </xsl:function>
  
  
  <xsl:function name="tei:dateJson" as="xs:string">
    <xsl:param name="label"/>
    <xsl:param name="content"/>
    <xsl:param name="last"/>
    <xsl:variable name="result">
      <xsl:text>"</xsl:text>
      <xsl:value-of select="$label"/>
      <xsl:text>"</xsl:text>
      <xsl:text>: { </xsl:text>
      <xsl:text>"value":</xsl:text>
      <xsl:text>"</xsl:text>
      <xsl:value-of select="$content"/>
      <xsl:text>",</xsl:text>
      <xsl:for-each select="$content/@*">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text>"</xsl:text>
        <xsl:text>:</xsl:text>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
        <xsl:if test="position()!=last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
        
      </xsl:for-each>
      <xsl:text> }</xsl:text>
      <xsl:if test="not($last)">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="$result"/>
  </xsl:function>
  
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
