#!/usr/bin/sh

for i in `ls *.po | sed s'|.po||'` ; do
	msgmerge --update --no-fuzzy-matching --no-wrap --backup=none ./$i.po pacli.pot
done
