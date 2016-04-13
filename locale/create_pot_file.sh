#!/usr/bin/sh

xgettext --from-code=UTF-8 \
	--package-name=Pacli -L shell \
	--files-from=files_to_translate --keyword=translatable --output=pacli.pot 
