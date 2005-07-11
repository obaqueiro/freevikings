#!/bin/sed -f

# replace.sed
# igneus 16.7.2005
# Jednoradkovy skriptik napsany pro rychle prejmenovani jedne methody.
# Editor sed aktivne neovladam, takze si skript schovam, kdybych jej nekdy
# upotrebil pro dalsi velke nahrazovani.

s/Image\.new/Image.load/g
