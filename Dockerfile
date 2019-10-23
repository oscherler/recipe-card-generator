FROM pandoc/core:2.7.3

# remove entrypoint that defaults to pandoc
ENTRYPOINT []

# install PHP and JSON extension to run Pandoc filters in PHP
RUN apk add --no-cache php php-json

# install Prince dependencies, libraries and fonts
RUN apk add --no-cache libcurl tiff libpng giflib pixman lcms2 fontconfig freetype libgomp msttcorefonts-installer && update-ms-fonts && fc-cache -f
# install Prince
RUN wget -O - 'https://www.princexml.com/download/prince-12.5.1-alpine3.10-x86_64.tar.gz' | tar xz && cd prince-12.5.1-alpine3.10-x86_64 && echo /usr/local | ./install.sh

# install Ghostscript
RUN apk add --no-cache ghostscript
