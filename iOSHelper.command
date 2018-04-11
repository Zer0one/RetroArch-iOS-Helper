#!/bin/bash

### Init
cd -- "$(dirname "$0")"

OLDIFS=$IFS
IFS=$'\n'
shopt -s nullglob

### Variable declaration
## Control script flow 
nextstep="true"

## File with new folder info
updfold="_UPDATE"
updfile="content_history.lpl"
updext=".lpl"

## New folder info
foldShar="" # AA000AA0-AAA0-0000-AA00-000000000000
foldPriv="" # BB111BB1-BBB1-1111-BB11-111111111111

### Rename RetroArch history file 
if [ ! -e "$updfold/$updfile" ]; then
	echo "File di aggiornamento \"$updfile\" non trovato nella cartella \"$updfold\""
	nextstep="false"
else
	updfileorig=$updfile
	updfile=${updfile%.*}.upd
	mv "$updfold/$updfileorig" "$updfold/$updfile"
fi

### Load new folders name from RetroArch History file
if [ $nextstep == "true" ]; then
    foldShar=$(sed -n '1h;1!H;${g;s:^.*\/var\/mobile\/Containers\/Data\/Application\/\([0-9A-Z]\{8\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{12\}\).*:\1:p;}' "$updfold/$updfile")
    foldPriv=$(sed -n '1h;1!H;${g;s:^.*\/var\/containers\/Bundle\/Application\/\([0-9A-Z]\{8\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{12\}\).*:\1:p;}' "$updfold/$updfile")
    # echo $foldShar
    # echo $foldPriv

    if [ -n $foldShar -a -n $foldPriv ]; then
    	echo "Update folder extraction complete"
    else
    	echo "Update folder extraction failed"
    	nextstep="false"
    fi
fi 

### Inject new folders name into target files
v150="false"
if [ $nextstep == "true" ]; then
	if [ -e "config" ]; then
		mv "./RetroArch/config/config" "./RetroArch/config/retroarch.cfg"
		v150="true"
	fi
	
	for f in $(find . -name '*retroarch.cfg' -or -name '*.lpl' -or -name '*.conf'); do
		echo "Updating file: $f"

		mv "$f" "$f.sed"
		sed s:"[0-9A-Z]\{8\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{12\}":$foldShar: "$f.sed" > "$f"

		mv "$f" "$f.sed"
		sed s:"\(^.*\/var\/containers\/Bundle\/Application\/\)\([0-9A-Z]\{8\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{12\}\)\(.*\)":"\1$foldPriv\3": "$f.sed" > "$f"

	    rm "$f.sed"
	done

	
	for f in $(find ./RetroArch/shaders -maxdepth 1 -name '*.glslp'); do
		echo "Updating file: $f"

		mv "$f" "$f.sed"
		sed s:"[0-9A-Z]\{8\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{12\}":$foldShar: "$f.sed" > "$f"

		mv "$f" "$f.sed"
		sed s:"\(^.*\/var\/containers\/Bundle\/Application\/\)\([0-9A-Z]\{8\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{12\}\)\(.*\)":"\1$foldPriv\3": "$f.sed" > "$f"

	    rm "$f.sed"
	done
	
	if [ $v150 == "true" ]; then	
		mv "./RetroArch/config/retroarch.cfg" "./RetroArch/config/config" > /dev/null 2>&1
	fi
fi

mv "$updfold/$updfile" "$updfold/$updfileorig"
updfile=$updfileorig

# Finish
IFS=$OLDIFS