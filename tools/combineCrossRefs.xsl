<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"    
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:f="http://functions"    
    exclude-result-prefixes="f xd xlink xs xsi"    
    version="2.0"
    xpath-default-namespace="http://www.crossref.org/schema/4.4.2"
    >

<!--xmlns="http://www.crossref.org/schema/4.4.2"-->
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xd:doc  scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 19, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Rachel.Donahue</xd:p>
            <xd:p>Used to open a list of files and combine them into a single file for submission to CrossRef</xd:p>
        </xd:desc>
    </xd:doc>
      
    <xd:doc scope="component">
        <xd:desc>
            <xd:p><xd:b>depositorName, depositorEmail</xd:b></xd:p>
            <xd:p>Parameters used to allow depositor name and email address to be set at run-time in oXygen, rather than hardcoding within the stylesheet.</xd:p>            
        </xd:desc>
    </xd:doc>
    <xsl:param name="depositorName"/>
    <xsl:param name="depositorEmail"/>
    
    <xd:doc>
        <xd:desc><xd:p>Function used to create a value for the timestamp element</xd:p></xd:desc>
    </xd:doc>
    
    <xsl:function name="f:createTimestamp">
        <xsl:variable name="date" select="adjust-date-to-timezone(current-date(), ())"/>
        <xsl:variable name="time" select="adjust-time-to-timezone(current-time(), ())"/>
        <xsl:variable name="tempdatetime" select="concat($date, '', $time)"/>
        <xsl:variable name="datetime" select="translate($tempdatetime, ':-.', '')"/>
        <xsl:value-of select="$datetime"/>
    </xsl:function>
    
        
    <xd:doc>
        <xd:desc>
            <xd:p>Root template opens and combines all files into a single batch</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">        
        <doi_batch>            <!-- xmlns:cr="http://www.crossref.org/schema/4.4.2" xsl:exclude-result-prefixes="cr"-->
            <xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
            <xsl:attribute name="xsi:schemaLocation">http://www.crossref.org/schema/4.4.2 http://www.crossref.org/schema/deposit/crossref4.4.2.xsd</xsl:attribute>
            <xsl:attribute name="version">4.4.2</xsl:attribute>
            <head>
                <doi_batch_id>
                    <xsl:value-of select="concat('report_paper', '-', current-dateTime())"/>
                </doi_batch_id>              
                
                <timestamp>
                    <xsl:value-of select="f:createTimestamp()"/>
                </timestamp>
                <depositor>
                    <depositor_name><xsl:value-of select="$depositorName"/></depositor_name>
                    <email_address><xsl:value-of select="$depositorEmail"/></email_address>
                </depositor>
                
                <registrant>National Agricultural Library</registrant>
            </head>
            <body>
                <xsl:for-each select="fileList/file">          
                    <xsl:variable name="thisFile"><xsl:value-of select="./text()"/></xsl:variable>
                    <xsl:apply-templates select="document($thisFile)/doi_batch"/>
                </xsl:for-each>  
            </body>    
        </doi_batch>
    </xsl:template>
    
    <xsl:template match="doi_batch">
        <xsl:copy-of select="body/report-paper"/>
    </xsl:template>
    
    
</xsl:stylesheet>