import sys
import os
import xml.etree.ElementTree as ET
from copy import deepcopy

XHTML = 'http://www.w3.org/1999/xhtml'

XHTML_BODY = '{' + XHTML + '}body'
XHTML_UL = '{' + XHTML + '}ul'
XHTML_HR = '{' + XHTML + '}hr'

ns = {
    'x': XHTML,
}

ET.register_namespace( '', XHTML )
# ET.register_namespace( 'xlink', XLINK )

file_path = sys.argv[1]
output_path = sys.argv[2]

tree = ET.parse( file_path )
root = tree.getroot()
body = root.find( XHTML_BODY )


# Create the root element
page = ET.Element('html')
# Make a new document tree
doc = ET.ElementTree( page )

# Add the subelements
pageElement = ET.SubElement( page, 'body' )

table = ET.Element('table')
table.attrib['border'] = '1'

pageElement.append( table )

new_step = True

for el in body:
    if el.tag == XHTML_HR:
        new_step = True
        continue

    if new_step and el.tag != XHTML_UL:
        row = ET.Element('tr')
        step_cell = ET.Element('td')
        step_cell.attrib['colspan'] = '2'
        table.append( row )
        row.append( step_cell )
        step_cell.append( deepcopy( el ) )
        continue

    if el.tag == XHTML_UL:
        num_ingredients = len( el )
        step_cell = ET.Element('td')
        step_cell.attrib['rowspan'] = str( num_ingredients )

        first = True
        for ingredient in el:
            row = ET.Element('tr')

            ingredient_cell = ET.Element('td')

            for toto in ingredient:
                ingredient_cell.append( deepcopy( toto ) )

            row.append( ingredient_cell )

            if first:
                row.append( step_cell )

            table.append( row )

            first = False

    else:
        step_cell.append( deepcopy( el ) )
        pass

    new_step = False

doc.write( output_path )
