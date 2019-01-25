#!/bin/bash

_pages=$( pdfinfo "$1" | awk '/^Pages/ { print $2 }' )

if [[ $_pages -gt 4 ]]
then
	echo MORE THAN 4 PAGES
	exit 1
elif [[ $_pages -eq 4 ]]
then
	pdfjam "$1" '4,1,2,3' --outfile "$1" --nup 2x1 --landscape --paper a5paper
elif [[ $_pages -eq 3 ]]
then
	pdfjam "$1" '{},1,2,3' --outfile "$1" --nup 2x1 --landscape --paper a5paper
fi
