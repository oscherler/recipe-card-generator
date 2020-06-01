# -*- coding: utf8 -*-

import sys
import os
import xml.etree.ElementTree as ET
from copy import deepcopy

XHTML = 'http://www.w3.org/1999/xhtml'

XHTML_BODY = '{' + XHTML + '}body'
XHTML_UL = '{' + XHTML + '}ul'
XHTML_HR = '{' + XHTML + '}hr'
XHTML_EM = '{' + XHTML + '}em'

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

out_html = ET.Element('html')
doc = ET.ElementTree( out_html )

out_body = ET.SubElement( out_html, 'body' )
table = ET.SubElement( out_body, 'table', border='1' )

new_step = True

for el in body:
    # <hr> is the step separator
    if el.tag == XHTML_HR:
        new_step = True
        continue

    # if a step doesn’t start with a <ul>, it’s a step without ingredients
    if new_step and el.tag != XHTML_UL:
        row = ET.SubElement( table, 'tr' )
        step_cell = ET.SubElement( row, 'td', colspan='3' )
        step_cell.append( deepcopy( el ) )
        continue

    # <ul>: ingredients
    if el.tag == XHTML_UL:
        # span the text <td> on all the ingredient rows
        step_cell = ET.Element('td', rowspan=str( len( el ) ))

        first = True
        for ingredient in el:
            row = ET.SubElement( table, 'tr' )
            quantity_cell = ET.Element('td')
            ingredient_cell = ET.SubElement( row, 'td' )
            has_quantity = False

            if len( ingredient ) == 0:
                # no sub elements, just text, so no quantity
                ingredient_cell.text = ingredient.text
            else:
                # sub elements, check for <em> for quantity
                for ingredient_el in ingredient:
                    if ingredient_el.tag == XHTML_EM:
                        has_quantity = True

                        # text after last element is in last element tail, move it so ingredient text
                        ingredient_cell.text = ingredient_el.tail
                        ingredient_el.tail = None

                        # insert quantity cell before ingredient cell
                        quantity_cell.append( deepcopy( ingredient_el ) )
                        row.insert( 0, quantity_cell )
                    else:
                        ingredient_cell.append( deepcopy( ingredient_el ) )
                    
            if not has_quantity:
                ingredient_cell.attrib['colspan'] = '2'
            
            if first:
                row.append( step_cell )

            first = False

    else:
        step_cell.append( deepcopy( el ) )
        pass

    new_step = False

doc.write( output_path )
