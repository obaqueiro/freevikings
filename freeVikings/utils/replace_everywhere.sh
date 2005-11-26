#!/bin/sh
# replace_everywhere.sh
# igneus 26.11.2005
#
# Usage:
#      replace_everywhere.sh <directory> <patern-to-be-replaced> <new-pattern>
#
# Goes recursively through the directory and in all the files replaces
# pattern-to-be-replaced by new-pattern. Well, it isn't very safe...
# I use it to rename classes.

for f in $1/*; do
    if [ -f $f ]; then
	sed_expr=s/$2/$3/g
	sed -i -e $sed_expr $f
    elif [ -d $f ]; then
	# fork out a new instance of this program to go through
	# a subdirectory:
	echo "Entering subdirectory $f"
	. $0 $f $2 $3
    fi
done
