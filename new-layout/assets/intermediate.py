# -*- coding: utf8 -*-

import sys
import os
from lxml import etree as ET
from copy import deepcopy

XHTML = 'http://www.w3.org/1999/xhtml'

XHTML_BODY = '{' + XHTML + '}body'
XHTML_SECTION = '{' + XHTML + '}section'
XHTML_UL = '{' + XHTML + '}ul'
XHTML_HR = '{' + XHTML + '}hr'
XHTML_EM = '{' + XHTML + '}em'

input_path = sys.argv[1]
output_path = sys.argv[2]

tree = ET.parse( input_path )
root = tree.getroot()
steps = root.find( XHTML_BODY + '/' + XHTML_SECTION + '[@class="steps"]' )

out_steps = ET.Element('section')
out_steps.attrib['id'] = 'ingredients'
out_steps.attrib['class'] = 'level1 ingredients'

table = ET.SubElement( out_steps, 'table' )
tbody = ET.SubElement( table, 'tbody' )

new_step = True

for el in steps:
    # <hr> is the step separator
    if el.tag == XHTML_HR:
        new_step = True
        continue

    # if a step doesn’t start with a <ul>, it’s a step without ingredients
    if new_step and el.tag != XHTML_UL:
        row = ET.SubElement( tbody, 'tr' )
        step_cell = ET.SubElement( row, 'td', colspan='3', Class='step' )
        step_cell.append( deepcopy( el ) )
        continue

    # <ul>: ingredients
    if el.tag == XHTML_UL:
        # span the text <td> on all the ingredient rows
        step_cell = ET.Element( 'td', rowspan=str( len( el ) ), Class='steps' )

        first = True
        for ingredient in el:
            row = ET.SubElement( tbody, 'tr' )
            quantity_cell = ET.Element( 'td', Class='quantity' )
            ingredient_cell = ET.SubElement( row, 'td', Class='ingredient' )
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

parent = steps.getparent()
parent.insert( parent.index( steps ), out_steps )
steps.getparent().remove( steps )

tree.write( output_path )
