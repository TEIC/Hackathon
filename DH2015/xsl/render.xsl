<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"    
    version="1.0">
    
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <link rel="stylesheet" href="../xsl/render.css"/>
            </head>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
        

    </xsl:template>
    <xsl:template match="tei:pb">
        <hr/>
        <div class="right">
            <hr/>
            <img src="{substring-after(substring-before(@facs, '_'), '#')}" />
        </div>
    </xsl:template>
    <xsl:template match="tei:div">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:lb">
        <br/>
            <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:w">
        <span class="w">
            <xsl:if test="@cert">
                <xsl:call-template name="certToBgColor">
                    <xsl:with-param name="cert" select="@cert"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template name="certToBgColor">
        <xsl:param name="cert"/>
        <xsl:variable name="certVal" select="number($cert)"/>
        <xsl:choose>
            <xsl:when test="$certVal &lt; .5"><xsl:attribute name="style">background-color: #ffaaaa;</xsl:attribute></xsl:when>
            <xsl:when test="$certVal &lt; .6"><xsl:attribute name="style">background-color: #ffbbbb;</xsl:attribute></xsl:when>
            <xsl:when test="$certVal &lt; .7"><xsl:attribute name="style">background-color: #ffcccc;</xsl:attribute></xsl:when>
            <xsl:when test="$certVal &lt; .8"><xsl:attribute name="style">background-color: #ffdddd;</xsl:attribute></xsl:when>
            <xsl:when test="$certVal &lt; .9"><xsl:attribute name="style">background-color: #ffeeee;</xsl:attribute></xsl:when>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:stylesheet>