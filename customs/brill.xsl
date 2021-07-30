<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE transform [
         <!ENTITY % htmlmathml-f PUBLIC
         "-//W3C//ENTITIES HTML MathML Set//EN//XML"
         "http://www.w3.org/2003/entities/2007/htmlmathml-f.ent"
       >
       %htmlmathml-f;
]>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:f="http://functions"
    xmlns:saxon="http://saxon.sf.net/" xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
    xmlns="http://www.loc.gov/mods/v3" exclude-result-prefixes="xd xs f saxon xlink xsi xml ali">
    <xsl:import href="../jats_to_mods_30.xsl"/>
    <xsl:output version="1.0" encoding="UTF-8" name="archive-original" method="xml" indent="yes"
        doctype-public="-//NLM//DTD JATS (Z39.96) Journal Publishing DTD with MathML3 v1.1 20151215//EN"
        doctype-system="http://jats.nlm.nih.gov/publishing/1.1/JATS-journalpublishing1-mathml3.dtd"/>

    <xd:doc scope="stylesheet" id="brill">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 16, 2021</xd:p>
            <xd:p><xd:b>Author:</xd:b> Carlos.Martinez</xd:p>
            <xd:ul>
                <xd:p>Invalid XML due to usage of wrong document type definition</xd:p>
                <xd:li>The the following document type definition provided for Brill's metadata
                    renders invalid XML. <![CDATA[<!DOCTYPE article PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.1 20151215//EN"
                "http://jats.nlm.nih.gov/publishing/1.1/JATS-journalpublishing1.dtd">]]></xd:li>
                <xd:li>Thus the output changes the public and system-id values to <![CDATA[<!DOCTYPE article PUBLIC"-//NLM//DTD JATS (Z39.96) Journal Publishing DTD with MathML3 v1.1 20151215//EN"
                Delivered as file "JATS-journalpublishing1-mathml3.dtd"]]> to render valid XML
                    documents.</xd:li>
            </xd:ul>

            <xd:p>Brill has two pub-dates which render an invalid mods document </xd:p>
            <xd:p>This stylesheet selects the attribute @date-type="article" </xd:p>
            <xd:p>Modified modsPart to include date</xd:p>
            <xd:p>Revised author's name info template to match id path </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes"
            href="file:///{$workingDir}A-{replace($originalFilename,'(.*/)(.*)(\.xml)', '$2')}_{position()}.xml"
            format="archive-original">
            <xsl:copy-of select="."/>
        </xsl:result-document>
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes"
            href="file:///{$workingDir}N-{replace($originalFilename,'(.*/)(.*)(\.xml)', '$2')}_{position()}.xml">
            <mods version="3.7">
                <xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
                <xsl:attribute name="xsi:schemaLocation"
                    select="normalize-space('http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd')"/>
                <xsl:apply-templates select="article/front/article-meta/title-group"/>
                <xsl:apply-templates select="article/front/article-meta/contrib-group"/>

                <!-- Check if need to add affiliation note -->
                <xsl:apply-templates select="article/front/article-meta/(. | contrib-group)/aff"
                    mode="note"/>

                <!-- Default -->
                <typeOfResource>text</typeOfResource>
                <genre>article</genre>

                <xsl:call-template name="brill_originInfo"/>

                <!-- Default language -->
                <language>
                    <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                    <languageTerm type="text">English</languageTerm>
                </language>

                <xsl:choose>
                    <xsl:when
                        test="article/front/article-meta/abstract and article/front/article-meta/trans-abstract[@xml:lang = 'en']">
                        <xsl:apply-templates
                            select="article/front/article-meta/trans-abstract[@xml:lang = 'en']"/>
                    </xsl:when>
                    <xsl:when test="not(article/front/article-meta/abstract) and article/body">
                        <xsl:apply-templates select="article/body/p[1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="article/front/article-meta/abstract"/>
                        <xsl:apply-templates select="article/front/article-meta/trans-abstract"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="article/front/article-meta/kwd-group"/>

                <relatedItem type="host">
                    <xsl:apply-templates select="article/front/journal-meta"/>
                    <xsl:call-template name="brill_modsPart"/>
                </relatedItem>

                <xsl:apply-templates
                    select="article/front/article-meta/article-id[@pub-id-type] | /article/front[1]/article-meta[1]/doi-group[1]/article-doi[1]"/>
                <xsl:call-template name="extension"/>

            </mods>
        </xsl:result-document>
    </xsl:template>

    <xd:doc scope="component" id="contrib">
        <xd:desc>If the contributor is a collaborator rather than an individual, format output
            accordingly. If processing the first author in the group, assign an attribute of
                <xs:b>usage</xs:b> with a value of "primary."</xd:desc>
    </xd:doc>
    <xsl:template match="contrib">
        <xsl:choose>
            <xsl:when test="collab">
                <name type="corporate">
                    <namePart>
                        <xsl:value-of select="collab/text()"/>
                    </namePart>
                </name>
            </xsl:when>
            <xsl:otherwise>
                <name type="personal">
                    <xsl:if test="position() = 1 and count(../preceding-sibling::contrib-group) = 0">
                        <xsl:attribute name="usage">primary</xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="brill-authors-name-info"/>
                </name>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc scope="component" id="brill-authors-name-info">
        <xd:desc>
            <xd:p>Formatting for personal names</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="brill-authors-name-info">
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
        <!-- Using xpath uses the author's id with the current() function to match affiliation to its rid  -->
        <xsl:for-each
            select="/article/front/article-meta/contrib-group/aff[@id = current()/xref/@rid]">
            <xsl:variable name="this">
                <xsl:apply-templates mode="affiliation"/>
            </xsl:variable>
            <affiliation>
                <xsl:value-of select="normalize-space($this)"/>
            </affiliation>
        </xsl:for-each>
        <!--corresponding author's email-->
        <xsl:for-each
            select="/article/front/article-meta/author-notes/fn[@id = current()/xref/@rid]">
            <affiliation>
                <xsl:apply-templates mode="affiliation"/>
            </affiliation>
        </xsl:for-each>
        <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>

    <xd:doc scope="component" id="dateIssued">
        <xd:desc>
            <xd:p><xd:b>Issue:</xd:b> the dateIssued mods tag was matching both date elements, thus providing two
                dateIssued tags with different values, while both containing the keyDate attribute set
                to "yes"</xd:p>
            <xd:p><xd:b>Example of issue:</xd:b>The following two dateIssued elements are actual results before customization:</xd:p>
            <xd:p>
            <![CDATA[]
                <dateIssued encoding="w3cdtf" keyDate="yes">2020-09-30</dateIssued>
                <dateIssued encoding="w3cdtf" keyDate="yes>2021-07-12</dateIssued>
             ]]>
            </xd:p>
            <xd:p><xd:b>Customization:</xd:b>Thus new conditional criteria had to be implemented to match only one pub-date element
                within the source metadata. 
            </xd:p>
        </xd:desc>
       
    </xd:doc>
    <xsl:template name="brill_originInfo">       
        <originInfo>
            <xsl:for-each select="/article/front/article-meta">
                <xsl:choose>
                    <xsl:when test="//pub-date[(@publication-format = 'online' and @date-type = 'article')] [* except @date-type = 'issue']">
                        <xsl:apply-templates select="//pub-date[(@publication-format = 'online' and @date-type = 'article' )] [* except @date-type- = 'issue']"
                            mode="origin"/>
                    </xsl:when>
                    
                        <xsl:when test="//pub-date[@publication-format='online'and not(@date-type='issue' or @publication-format='print')]">
                        <xsl:apply-templates select="//pub-date[(@publication-format='online' and not(@date-type='issue' or @publication-format='print'))]"
                            mode="origin"/>
                        </xsl:when>
                    <xsl:otherwise>
                       <xsl:text>this is wrong</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </originInfo>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Print publication date added as 'dateIssued.' If no print, then online
                used.</xd:p>
            <xd:p>Checks that 'day' is not 'NaN'. Month function checks that 'month' is present and
                not 'null.'</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template
        match="//pub-date[(@publication-format = 'online' and @date-type = 'article')] [* except @date-type- != 'issue']"
        mode="origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of
                select="string-join((year, f:checkMonthType(month[not(. = '')]), format-number(day[not(. = '')], '00'))[. != 'NaN'], '-')"
            />
        </dateIssued>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template
        match="//pub-date[@publication-format='online'] [(* except @pub-type!='issue' and @publication-format!='print')]"
        mode="origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of
                select="string-join((year, f:checkMonthType(month)[not(. = '')], format-number(day[not(. = '')], '00'))[. != 'NaN'], '-')"
            />
        </dateIssued>
    </xsl:template>

    <xd:doc scope="component" id="brill_modsPart">
        <xd:desc>
            <xd:p>This template is simplified to use apply-templates from the template that matched
                date-type="article"</xd:p>
            <xd:p> invalid MODS sample data produced before modification </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="brill_modsPart">
        <part>
            <xsl:apply-templates
                select="/article/front/article-meta/volume[not(@content-type = 'year')]"/>
            <xsl:apply-templates select="/article/front/article-meta/issue"/>
<!--            <xsl:if test="/article/front/article-meta/pub-date[@publication-format = 'online' and @pub-type='article', not('issued')]">-->
            <xsl:apply-templates select="/article/front/article-meta/pub-date[@date-type!='issue']"
                    mode="brill_part"/>
            <!--</xsl:if>-->
            <xsl:if test="/article/front/article-meta/fpage or /article/front/article-meta/elocation-id or /article/front[1]/article-meta[1]/counts[1]/page-count[1]/@count">
                <xsl:call-template name="modsPages"/>
            </xsl:if>
        </part>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>The date contained within pub-date[@date-type='article'] is parsed into three
                metatags representing the month day and year</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/article/front/article-meta/pub-date[@date-type!='issue']"
        mode="brill_part">
        <xsl:for-each select="year, month, day, season, string-date">
            <xsl:choose>
                <xsl:when test="name() = 'month'">
                    <text type="month">
                        <xsl:value-of select="f:checkMonthType(.)"/>
                    </text>
                </xsl:when>
                <xsl:otherwise>
                    <text type="{name()}">
                        <xsl:value-of select="."/>
                    </text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="article-id[@pub-id-type = 'doi']">
        <identifier type="doi">
            <xsl:value-of select="."/>
        </identifier>
        <location>
            <url>
                <xsl:text>http://dx.doi.org/</xsl:text>
                <xsl:value-of select="."/>
            </url>
        </location>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="article-id[@pub-id-type = 'other']">
        <identifier type="brill">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>

</xsl:stylesheet>
