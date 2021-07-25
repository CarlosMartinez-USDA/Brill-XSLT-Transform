<?xml version="1.0" encoding="UTF-8"?>
<!-- Added Funder name and Identifiers 2016-06-09 jgg -->
<!-- Fixed publisher's lack of space within title and abstract italics 2016-07-12 jgg -->
<xsl:stylesheet xmlns="http://www.loc.gov/mods/v3" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:xschema="http://www.crossref.org/xschema/1.1"
    xmlns:jats="http://www.ncbi.nlm.nih.gov/JATS1"
    xmlns:fr="http://www.crossref.org/fundref.xsd"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs oai jats xschema fr" version="2.0"> 
    <xsl:output method="xml" indent="yes" encoding="UTF-8" />


    <!-- Pulls in source information such as Vendor and source file name -->
  
    <xsl:include href="extension.xsl" />
    <xsl:strip-space elements="*"/>
 
    
    <!-- Root -->
    <xsl:template match="/">
        <mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.6" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd">
            
            <xsl:apply-templates select="/item/*[namespace-uri()='http://www.openarchives.org/OAI/2.0/' and local-name()='record']/*[namespace-uri()='http://www.openarchives.org/OAI/2.0/' and local-name()='metadata']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='crossref']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='journal']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='journal_article']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='titles']"/>
           
            <xsl:apply-templates select="/item/*[namespace-uri()='http://www.openarchives.org/OAI/2.0/' and local-name()='record']/*[namespace-uri()='http://www.openarchives.org/OAI/2.0/' and local-name()='metadata']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='crossref']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='journal']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='journal_article']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='contributors']"/>
            
            <!-- Default -->
            <typeOfResource>text</typeOfResource>
            <genre>article</genre>
            
            <xsl:apply-templates select="/item/*[namespace-uri()='http://www.openarchives.org/OAI/2.0/' and local-name()='record']/*[namespace-uri()='http://www.openarchives.org/OAI/2.0/' and local-name()='metadata']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='crossref']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='journal']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='journal_article']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='publication_date']"/>
            
            <!-- Default language -->
            <language>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                <languageTerm type="text">English</languageTerm>
            </language>
            
            <xsl:apply-templates select="/item/*[namespace-uri()='http://www.openarchives.org/OAI/2.0/' and local-name()='record']/*[namespace-uri()='http://www.openarchives.org/OAI/2.0/' and local-name()='metadata']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='crossref']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='journal']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='journal_article']/*[namespace-uri()='http://www.ncbi.nlm.nih.gov/JATS1' and local-name()='abstract']"/>
            
            <xsl:apply-templates select="/item/*[namespace-uri()='http://www.openarchives.org/OAI/2.0/' and local-name()='record']/*[namespace-uri()='http://www.openarchives.org/OAI/2.0/' and local-name()='metadata']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='crossref']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='journal']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='journal_article']/*[namespace-uri()='http://www.crossref.org/fundref.xsd' and local-name()='program']"/>
            <xsl:apply-templates select="/item/*[namespace-uri()='http://www.openarchives.org/OAI/2.0/' and local-name()='record']/*[namespace-uri()='http://www.openarchives.org/OAI/2.0/' and local-name()='metadata']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='crossref']/*[namespace-uri()='http://www.crossref.org/xschema/1.1' and local-name()='journal']"/>
            
            <xsl:call-template name="extension"/>
            
        </mods>
    </xsl:template>
    
    <!-- Article title -->
    <xsl:template match="xschema:titles">
 <xsl:for-each select="xschema:title">
        <titleInfo>
            <title> 
                <xsl:variable name="title">
                    <xsl:for-each select="descendant-or-self::text()">
                        <xsl:choose>
                            <xsl:when test="ancestor::title"></xsl:when>
                            <xsl:otherwise><xsl:value-of select="."/><xsl:text> </xsl:text></xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="normalize-space($title)"></xsl:value-of>
            </title>
        </titleInfo>
 </xsl:for-each>
    </xsl:template>
  
    <!-- Authors -->
    <xsl:template match="xschema:contributors">
        <xsl:if test="xschema:person_name[@sequence='first']">     
            <name type="personal" usage="primary">  
                <namePart type="family">
                    <xsl:for-each select="xschema:person_name[@sequence='first']/xschema:surname">
                    <xsl:value-of select="." />
                    </xsl:for-each>
                </namePart>
                <namePart type="given">
                    <xsl:for-each select="xschema:person_name[@sequence='first']/xschema:given_name">
                    <xsl:value-of select="." />
                    </xsl:for-each>
                </namePart>
                <xsl:if test="xschema:person_name[@sequence='first']/xschema:ORCID">
                    <nameIdentifier type="orcid" displayLabel="ORCID">
                        <xsl:value-of select="xschema:person_name[@sequence='first']/xschema:ORCID"/>
                    </nameIdentifier>
                </xsl:if>
                <displayForm>
                    <xsl:value-of select="xschema:person_name[@sequence='first']/xschema:surname" />
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="xschema:person_name[@sequence='first']/xschema:given_name" />                  
                </displayForm>        
                <role>
                    <roleTerm type="text">author</roleTerm>
                </role>  
            </name>         
        </xsl:if> 
       <xsl:if test="xschema:person_name[@sequence='additional']">
           <xsl:for-each select="xschema:person_name[@sequence='additional']">
            <name type="personal">
                <namePart type="family">
                    <xsl:for-each select="xschema:surname">
                        <xsl:value-of select="." />
                   </xsl:for-each>
                </namePart>
                <namePart type="given">
                    <xsl:for-each select="xschema:given_name">
                        <xsl:value-of select="." />
                    </xsl:for-each>
                </namePart>
                <xsl:if test="xschema:ORCID">
                    <xsl:for-each select="xschema:ORCID">
                        <nameIdentifier type="orcid" displayLabel="ORCID">
                        <xsl:value-of select="."/>
                    </nameIdentifier>
                    </xsl:for-each>
                </xsl:if>
                <displayForm>
                    <xsl:value-of select="xschema:surname" />
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="xschema:given_name" />                  
                </displayForm>        
                <role>
                    <roleTerm type="text">author</roleTerm>
                </role>  
            </name> 
           </xsl:for-each>
        </xsl:if>       
    </xsl:template>

    <!-- Date Issued -->
    <xsl:template match="xschema:publication_date">
        <xsl:if test="@media_type='print'">
            <originInfo>
            <dateIssued encoding="w3cdtf" keyDate="yes">
                <xsl:value-of select="xschema:year"/>
            </dateIssued>
            </originInfo>
        </xsl:if>
    </xsl:template>
 
    <!-- Abstract -->
    <xsl:template match="xschema:journal_article/jats:abstract">
        <xsl:if test="jats:p">
            <xsl:for-each select="jats:p">
                <abstract>
                    <xsl:variable name="abstract">
                        <xsl:for-each select="descendant-or-self::*/text()">
                            <xsl:choose>
                                <xsl:when test="ancestor::title"></xsl:when>
                                <xsl:otherwise><xsl:value-of select="."/><xsl:text> </xsl:text></xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="normalize-space($abstract)"></xsl:value-of>
                </abstract>
            </xsl:for-each>
        </xsl:if>  
    </xsl:template>
    
    
    <xsl:template match="jats:sub">
        <xsl:value-of select="translate(.,
            '0123456789+-−=()aehijklmnoprstuvxəβγρφχ',
            '₀₁₂₃₄₅₆₇₈₉₊₋₋₌₍₎ₐₑₕᵢⱼₖₗₘₙₒₚᵣₛₜᵤᵥₓₔᵦᵧᵨᵩᵪ')" />
    </xsl:template>
    
    <xsl:template match="jats:sup">
        <xsl:value-of select="translate(.,
            '0123456789+-−=()abcdefghijklmnoprstuvwxyzABDEGHIJKLMNOPRTUVWαβγδεθɩφχ',
            '⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻⁻⁼⁽⁾ᵃᵇᶜᵈᵉᶠᵍʰⁱʲᵏˡᵐⁿᵒᵖʳˢᵗᵘᵛʷˣʸᶻᴬᴮᴰᴱᴳᴴᴵᴶᴷᴸᴹᴺᴼᴾᴿᵀᵁⱽᵂᵅᵝᵞᵟᵋᶿᶥᵠᵡ')" />
    </xsl:template>
    
   
    <!-- Funding Information -->
    <xsl:template match="fr:program">
      <xsl:if test="//fr:assertion[@name='award_number']">
          <xsl:for-each select="//fr:assertion[@name='award_number']">
                <note type="funding">        
                    <xsl:value-of select="."/>  
                </note> 
          </xsl:for-each>
      </xsl:if>
        <xsl:if test="fr:assertion[@name='funder_name']">
            <xsl:for-each select="fr:assertion[@name='funder_name']">
            <name type="corporate">  
                <namePart>
                    <xsl:value-of select="normalize-space(text())"/>
                </namePart>
                
                <xsl:if test="fr:assertion[@name='funder_identifier']">
                    <nameIdentifier type="uri">
                        <xsl:value-of select="normalize-space(fr:assertion[@name='funder_identifier'])"/>
                    </nameIdentifier>
                </xsl:if>
                <role>
                    <roleTerm type="text" authority="marcrelator">Funder</roleTerm>
                </role>
                
            </name>
            </xsl:for-each>
        </xsl:if>
  
    </xsl:template>
    
    
    <!-- Host Information -->
    <xsl:template match="xschema:journal">
        <relatedItem type='host'>
            <titleInfo>
                <title>
                    <xsl:if test="xschema:journal_metadata[@language='en']/xschema:full_title">
            <xsl:value-of select="xschema:journal_metadata[@language='en']/xschema:full_title"/>
                    </xsl:if>
                    <xsl:if test="xschema:journal_metadata[@language='en']/xschema:abbrev_title and not(xschema:journal_metadata[@language='en']/xschema:full_title)">
                        <xsl:value-of select="xschema:journal_metadata[@language='en']/xschema:abbrev_title"/>
                    </xsl:if>
                </title>
            </titleInfo>
            <xsl:if test="xschema:journal_metadata/xschema:issn[@media_type='print']">
                <identifier type='issn-p'>
                    <xsl:value-of select="xschema:journal_metadata/xschema:issn[@media_type='print']"/>
                </identifier>
            </xsl:if>
            <xsl:if test="xschema:journal_metadata/xschema:issn[@media_type='electronic']">
                <identifier type='issn-e'>
                    <xsl:value-of select="xschema:journal_metadata/xschema:issn[@media_type='electronic']"/>
                </identifier>
            </xsl:if>
            <identifier type="issn">
                <xsl:choose>
                    <xsl:when test="xschema:journal_metadata/xschema:issn[@media_type='print']">
                        <xsl:value-of select="xschema:journal_metadata/xschema:issn[@media_type='print']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="xschema:journal_metadata/xschema:issn[@media_type='electronic']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </identifier>
            <identifier type="pii">
                <xsl:value-of select="xschema:journal_article/xschema:publisher_item/xschema:identifier[@id_type='pii']" />
            </identifier>
          
          <!-- Hindawi does not cite vol/issues -->
            <part>
                <xsl:if test="xschema:journal_issue/xschema:journal_volume/xschema:volume">
                    <detail type="volume">
                        <number>
                            <xsl:value-of select="xschema:journal_issue/xschema:journal_volume/xschema:volume" />
                        </number>
                        <caption>v.</caption>
                    </detail>
                </xsl:if>
                
                <xsl:if test="xschema:journal_article/xschema:publisher_item/xschema:identifier[@id_type='pii']">
                    <detail type="article">
                        <number>
                            <xsl:value-of select="xschema:journal_article/xschema:publisher_item/xschema:identifier[@id_type='pii']" />
                        </number>
                        <caption>no.</caption>
                    </detail>
                </xsl:if>
                
                <xsl:if test="xschema:journal_article/xschema:pages/xschema:last_page">
                    <extent unit="pages">
                        <total>
                            <xsl:value-of select="xschema:journal_article/xschema:pages/xschema:last_page" />
                        </total>
                    </extent>
                </xsl:if>
                
                <xsl:if test="xschema:journal_article/xschema:publication_date[@media_type='print']/xschema:year">
                <text type="year">
                    <xsl:value-of select="xschema:journal_article/xschema:publication_date[@media_type='print']"/>
                </text>
                </xsl:if>
            </part>
        </relatedItem>  
    
    <!-- DOI   -->      
    <xsl:if test="xschema:journal_article/xschema:doi_data/xschema:doi">
            <identifier type="doi">
                <xsl:value-of select="xschema:journal_article/xschema:doi_data/xschema:doi" />
            </identifier>
            <location>
                <url><xsl:text>http://dx.doi.org/</xsl:text><xsl:value-of select="encode-for-uri(xschema:journal_article/xschema:doi_data/xschema:doi)" /></url>
            </location>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
