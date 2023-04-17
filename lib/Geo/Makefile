# -*- Makefile -*-

all: Coords.pm

Coords.pm: Coords.pm.src WGS2TKY2.html
	perl ../../bin/mkcoordspm.pl $< > $@

WGS2TKY2.html: 
	wget -O $@ https://web.archive.org/web/2010/http://homepage3.nifty.com/Nowral/02_DATUM/WGS2TKY2.html
