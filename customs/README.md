# Brill XSLT 

Brill's metadata had four issues that rendered invalid XML result documents and invalid archival copies of the source document. 

## Corrections Summary
1. Added archive-original output to correct public-id and system-id
2. Corrected originInfo template to only get the dateIssued from pub-date[@date-type="article"] and not pub-date[@date-type="issue"] tag.
3. simplified the modsPart apply-templates to use pub-date[@date-type='article'] to render the three month, day, and year tags found in the part tag. 
4.  Matched author[@id] to affiliation[@rid] by using the current( ) function within the xpath to choose affiliation. (The template name that accomplishes this is"brill-author-name-info")
