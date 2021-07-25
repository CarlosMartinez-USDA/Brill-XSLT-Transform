<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" xmlns="http://www.loc.gov/mods/v3"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:saxon="http://saxon.sf.net/"
    exclude-result-prefixes="xs xd saxon xlink">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 19, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> rdonahue</xd:p>
            <xd:p>Pulled out in June 2017 as part of the refactoring project</xd:p>
        </xd:desc>
    </xd:doc>
    <!--archiveFile tokenizes "/" saxon:system-id(); then [last()] tells the processor which "/" to stop at. 
        leaveing just "filename.xml" from the original full path.--> 
    <!--saxon:system-id function = file:/W:/orkingDirectory/../filename.xml -->
    <!--substring-before() identifies two arguments the first containing the full file path, and the seocnd containing where the function should stop
    Leaving the "file:/W:/orkingDir/../-->
    <!--the combination of $workingDir and $archiveFile in the XSLT provide the full path for each transformation every time without having to set outside paramters-->
    <xd:doc>
        <xd:desc>
            <xd:p>Name of source vendor and filename being processed.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="vendorName"/>    
     <xsl:param name="archiveFile" select="replace(tokenize($originalFilename, '/')[last()], '(.*)(\.xml)','$1')"/>
    <xsl:param name="originalFilename" select="saxon:system-id()"/>    
    <xsl:param name="workingDir" select="substring-before($originalFilename, $archiveFile) "/>
    
</xsl:stylesheet>
