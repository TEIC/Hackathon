<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:local="http://www.tei-c.org/ns/local"
    exclude-result-prefixes="#all"
    version="2.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns="http://www.tei-c.org/ns/1.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 29, 2015</xd:p>
            <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>This stylesheet is designed to take input in the form of HOCR (XHTML documents) 
                produced by Tesseract and produce 
                basic TEI output.</xd:p>
            <xd:p>
                Initially created at the TEI Hackathon at DH 2015.
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="docTitle" select="'OCRed document'"/>
    <xsl:param name="pageNum" select="'1'"/>
    <xsl:param name="poetry" select="'no'"/>
    
    <xsl:param name="collectionPath" as="xs:string" select="'../cinders'"/>
    
    <xsl:variable name="hocrFiles" select="collection(concat($collectionPath, '/?select=*.hocr;recurse=yes'))"/>
    
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href="../xsl/render.xsl"</xsl:processing-instruction>
        <TEI version="5.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title><xsl:value-of select="$docTitle"/></title>
                    </titleStmt>
                    <publicationStmt>
                        <p></p>
                    </publicationStmt>
                    <sourceDesc>
                        <p>[Please supply information about the source document.]</p>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <facsimile>
                
                <xsl:for-each select="$hocrFiles">
                    <xsl:sort select="document-uri(.)"/>
                    <xsl:for-each select="descendant::div[starts-with(@title, 'image ')]">
                    <xsl:variable name="bbox" select="local:getBbox(@title)"/>
                    <xsl:variable name="imgName" select="local:getImgName(@title)"/>
                    <surface ulx="{$bbox[1]}" uly="{$bbox[2]}"  lrx="{$bbox[3]}" lry="{$bbox[4]}" xml:id="{$imgName}_surface">
                        <graphic url="{$imgName}"/>
                        <xsl:for-each select="descendant::*[matches(@title, 'bbox')]">
                            <xsl:variable name="bbox" select="local:getBbox(@title)"/>
                            <zone xml:id="{$imgName}_{@id}" ulx="{$bbox[1]}" uly="{$bbox[2]}"  lrx="{$bbox[3]}" lry="{$bbox[4]}"/> 
                        </xsl:for-each>
                    </surface>
                    </xsl:for-each>
                </xsl:for-each>
            </facsimile>
           
            
            <text>
                <body>
                    <xsl:for-each select="$hocrFiles">
                        <xsl:sort select="document-uri(.)"/>
                        <xsl:apply-templates select="descendant::body" mode="#current"/>
                    </xsl:for-each>
                    
                </body>
            </text>
        </TEI>
    </xsl:template>
    
    <xsl:template match="div[matches(@class, 'ocr_page')]">
        <pb facs="#{local:getImgName(@title)}_surface"/>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="div" mode="#all">
        <div>
            <xsl:if test="starts-with(@title, 'bbox ')">
                <xsl:attribute name="facs" select="concat('#', local:getImgName(ancestor::*[starts-with(@title, 'image')][1]/@title), '_', @id)"/>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>
    
    <xsl:template match="p">
        <p>
            <xsl:if test="starts-with(@title, 'bbox ')">
                <xsl:attribute name="facs" select="concat('#', local:getImgName(ancestor::*[starts-with(@title, 'image')][1]/@title), '_', @id)"/>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </p>
    </xsl:template>
    
    <xsl:template match="p" mode="poetry">
        <lg>
            <xsl:if test="starts-with(@title, 'bbox ')">
                <xsl:attribute name="facs" select="concat('#', local:getImgName(ancestor::*[starts-with(@title, 'image')][1]/@title), '_', @id)"/>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </lg>
    </xsl:template>
    
    <xsl:template match="span[matches(@class, 'line')]" mode="poetry">
        <l>
            <xsl:if test="starts-with(@title, 'bbox ')">
                <xsl:attribute name="facs" select="concat('#', local:getImgName(ancestor::*[starts-with(@title, 'image')][1]/@title), '_', @id)"/>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </l>
    </xsl:template>
    
    <xsl:template match="span[matches(@class, 'line')]" mode="#default">
        <lb/>
        <!--<xsl:if test="starts-with(@title, 'bbox ')">
                <xsl:attribute name="facs" select="concat('#', local:getImgName(ancestor::*[starts-with(@title, 'image')][1]/@title), '_', @id)"/>
            </xsl:if>-->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="span[matches(@class, 'word')]" mode="#all">
        <w><xsl:if test="starts-with(@title, 'bbox ')">
                <xsl:attribute name="facs" select="concat('#', local:getImgName(ancestor::*[starts-with(@title, 'image')][1]/@title), '_', @id)"/></xsl:if>
            <xsl:apply-templates select="@title" mode="#current"/>
            <xsl:apply-templates mode="#current"/>
        </w>
    </xsl:template>
    
    <xsl:template match="span[matches(@class, 'word')]/@title[matches(., 'x_wconf \d+')]">
        <xsl:variable name="confVal" select="xs:integer(replace(., '^.*x_wconf\s+', ''))"/>
        <xsl:if test="$confVal gt 0 and $confVal lt 100">
            <xsl:attribute name="cert" select="concat('0.', $confVal)"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:function name="local:getBbox" as="xs:integer*">
        <xsl:param name="inTitle" as="xs:string"/>
        <xsl:variable name="preStrip" select="replace($inTitle, '^.*bbox ', '')"/>
        <xsl:variable name="postStrip" select="replace($preStrip, ';.*', '')"/>
        <xsl:sequence select="for $x in tokenize($postStrip, '\s+') return xs:integer($x)"/>
    </xsl:function>
    
    <xsl:function name="local:getImgName" as="xs:string">
        <xsl:param name="titleAtt" as="xs:string"/>
        <xsl:value-of select="translate(tokenize($titleAtt, '\s+')[2], '&quot;;', '')"/>
    </xsl:function>
        
</xsl:stylesheet>