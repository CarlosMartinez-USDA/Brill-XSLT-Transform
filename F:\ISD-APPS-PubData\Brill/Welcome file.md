# PubData-XSLT
Repository for stylesheet development, split off of https://github.com/isdapps/PubData

## Brill Custom XSLT Transformation  

Brill's metadata had four issues that rendered invalid XML result documents and invalid archival copies of the source document. 

### Corrections Summary
1. Included an output statement from the brill.xsl file in order to correct the public-id and system-id provided in the original files sent from the publisher. The files initially were invalid and the transfomration corrects this by using the name attribute "archive-original" and listing utput to correct public-id and system-id.
*For example:*
 <xsl:output version="1.0"  doctype-public="-//NLM//DTD JATS (Z39.96) Journal Publishing DTD with MathML3 v1.1 20151215//EN"  doctype-system="http://jats.nlm.nih.gov/publishing/1.1/JATS-journalpublishing1-mathml3.dtd" encoding="UTF-8" name="archive-original" method="xml" indent="yes"/>

7

prodcuces valid JATS Journal Publishing files  
 2. Corrected originInfo template to only get the dateIssued from pub-date[@date-type="article"] and not pub-date[@date-type="issue"] tag.

3.  simplified the modsPart apply-templates to use pub-date[@date-type='article'] to render the three month, day, and year tags found in the part tag. 
4.  Matched author[@id] to affiliation[@rid] by using the current( ) function within the xpath to choose affiliation. (The template name that accomplishes this is"brill-author-name-info")


<!--stackedit_data:
eyJoaXN0b3J5IjpbNDU4NTk4NzI2LC0xNzY2MjE5MjM3XX0=
-->