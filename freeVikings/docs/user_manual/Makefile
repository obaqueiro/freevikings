# This only works on my (igneus) home system - please modify TEMPLATE
# to where you have XSLT templates.

TEMPLATE=/home/igneus/dist/docbook-xsl-1.74.0/xhtml/onechunk.xsl

all: index.html

index.html: usermanual.xml
	xsltproc $(TEMPLATE) usermanual.xml
