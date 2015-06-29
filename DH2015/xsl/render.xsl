<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"    
    version="1.0">
    
    <xsl:template match="/">
        <html>
            <head>
                <link rel="stylesheet" href="../xsl/render.css"/>
                
            </head>
            <body>
                <div class="left">
                    <xsl:apply-templates/>
                </div>
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
    
</xsl:stylesheet>