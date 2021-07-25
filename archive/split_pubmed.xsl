<?xml version="1.0" encoding="UTF-8"?>
<!-- Split Pubmed file with multiple articles to one article per file -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">

<!-- Parameter with file path and prefix -->
    <xsl:param name="filePrefix"/>

<!-- Format output -->
    <xsl:output name="my-output" method="xml" encoding="UTF-8" indent="yes"
        doctype-public="-//NLM//DTD PubMed 2.1//EN"
        doctype-system="http://www.ncbi.nlm.nih.gov:80/entrez/query/static/PubMed.dtd"/>
        
<!-- Splitting using result-document -->
    <xsl:template match="/">
        <xsl:for-each select="ArticleSet/Article">
            <xsl:result-document href="{concat($filePrefix,position(),'.xml')}" format="my-output"  >
                <ArticleSet>
                    <xsl:copy-of select="."/>
                </ArticleSet>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>    
</xsl:stylesheet>