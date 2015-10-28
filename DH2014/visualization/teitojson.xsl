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
<xsl:output method="text" encoding="utf-8" />

<xsl:template match="/">
  <xsl:variable name="names" as="xs:string+">
    <xsl:for-each-group select="//placeName" group-by=".">
      <xsl:sort select="current-grouping-key()"/>
	<xsl:value-of select="tei:jsonObject ((
			      tei:json('name',current-grouping-key(), true()),
			      tei:json('count',count(current-group()),  false())
			  ))"/>
    </xsl:for-each-group>
  </xsl:variable>
  
  <xsl:value-of select="tei:jsonObject(tei:jsonArray('TEI',$names,false()))"/>


</xsl:template>

</xsl:stylesheet>
