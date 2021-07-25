<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:f="http://functions" xmlns:saxon="http://saxon.sf.net/" 
    xmlns:ali="http://www.niso.org/schemas/ali/1.0/" 
    xmlns="http://www.loc.gov/mods/v3"
    xmlns:tp="http://www.plazi.org/taxpub"
    exclude-result-prefixes="xd xs f saxon xlink xsi xml ali tp">

    <xsl:import href="../jats_to_mods_30.xsl"/>

    <xsl:template name="name-info">
        <namePart type="given">
            <xsl:value-of select="normalize-space((string-name | name)/given-names)"/>
        </namePart>
        <namePart type="family">
            <xsl:value-of select="(string-name | name)/surname"/>
        </namePart>
        <displayForm>
            <xsl:value-of select="(string-name | name)/surname"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="normalize-space((string-name | name)/given-names)"/>
        </displayForm>

        <!-- Get author's ORCID -->
        <xsl:apply-templates select="contrib-id[@contrib-id-type = 'orcid']"/>

        <!-- Create variables for matching author(s) to affiliation(s) -->
        <!-- Check if author has an affiliation ID for matching -->
        <xsl:variable name="affid" select="xref[@ref-type = 'aff']/@rid"/>
        <!-- Count number of affiliations available for matching -->
        <xsl:variable name="affnum" select="count(../aff)"/>
        <!-- Count number of affiliations available for matching, using alternate path in Indian Journals -->
        <xsl:variable name="affnumIJ" select="count(../../aff)"/>
        <!-- Save author's last name -->
        <xsl:variable name="lastName" select="(string-name | name)/surname"/>
        <!-- Find and save author's initials -->
        <xsl:variable name="initials">
            <xsl:for-each select="tokenize((string-name | name)/given-names, ' ')">
                <xsl:value-of select="substring(., 1, 1)"/>
            </xsl:for-each>
            <xsl:for-each select="tokenize((string-name | name)/surname, ' ')">
                <xsl:value-of select="substring(., 1, 1)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$affid">
                <xsl:for-each select="../aff[@id = $affid] | ../../aff[@id = $affid]">
                    <xsl:choose>
                        <xsl:when test="contains(., 'First') and contains(., 'second')">
                            <!-- do nothing -->
                        </xsl:when>
                        <xsl:when test="addr-line/@content-type = 'verbatim'">
                            <affiliation>
                                <xsl:value-of select="addr-line[@content-type = 'verbatim']"/>
                            </affiliation>
                        </xsl:when>
                        <xsl:when test="count(addr-line) = 1 and count(./*) &lt; 3">
                            <affiliation>
                                <xsl:value-of select="addr-line"/>
                            </affiliation>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="aff" mode="affiliation"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="aff">
                <xsl:for-each select="aff">
                    <xsl:choose>
                        <xsl:when test="contains(., 'First') and contains(., 'second')">
                            <!-- do nothing -->
                        </xsl:when>
                        <xsl:when test="addr-line/@content-type = 'verbatim'">
                            <affiilation>
                                <xsl:value-of select="addr-line[@content-type = 'verbatim']"/>
                            </affiilation>
                        </xsl:when>
                        <xsl:when test="count(addr-line) = 1 and count(./*) &lt; 3">
                            <affiliation>
                                <xsl:value-of select="addr-line"/>
                            </affiliation>
                        </xsl:when>
                        <xsl:otherwise>
                            <affiliation>
                                <xsl:value-of select="*[not(sup | label)]" separator=", "/>
                            </affiliation>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="not($affid) and $affnum = 1">
                <xsl:apply-templates mode="affiliation" select="../aff"/>
            </xsl:when>
            <xsl:when test="not($affid) and $affnumIJ >= 1">
                <xsl:apply-templates mode="affiliation" select="../../aff"/>
            </xsl:when>
        </xsl:choose>

        <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>

    <xsl:template match="/article/front/article-meta/abstract/label[text() = 'Abstract']"/>
    <xsl:template match="/article/front/article-meta/abstract/p/italic/tp:taxon-name | /article/front/article-meta/title-group/article-title/italic/tp:taxon-name">
        <xsl:variable name="taxonString" select="string-join(tp:taxon-name-part, ' ')"/>
        <xsl:value-of select="normalize-space($taxonString)"/>
    </xsl:template>

</xsl:stylesheet>