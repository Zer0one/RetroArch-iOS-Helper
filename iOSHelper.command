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

## New folder info
foldShared="" # AA000AA0-AAA0-0000-AA00-000000000000
foldPrivat="" # BB111BB1-BBB1-1111-BB11-111111111111

## RetroArch Shader folder
foldRetroShad="shaders_glsl"

### Rename Update file name to avoid modification 
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
    foldShared=$(sed -n '1h;1!H;${g;s:^.*\/var\/mobile\/Containers\/Data\/Application\/\([0-9A-Z]\{8\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{12\}\).*:\1:p;}' "$updfold/$updfile")
    foldPrivat=$(sed -n '1h;1!H;${g;s:^.*\/var\/containers\/Bundle\/Application\/\([0-9A-Z]\{8\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{12\}\).*:\1:p;}' "$updfold/$updfile")
    # echo $foldShared
    # echo $foldPrivat

    if [ -n $foldShared -a -n $foldPrivat ]; then
    	echo "Update folder extraction complete"
    else
    	echo "Update folder extraction failed"
    	nextstep="false"
    fi
fi 

### Inject new folders name into target files
if [ $nextstep == "true" ]; then
	## Update folder name into RetroArch Config, RetroArch Playlist and DOSBox confing file
	for f in $(find . -name '*retroarch.cfg' -or -name '*.lpl' -or -name '*.conf'); do
		echo "Updating file: $f"

		mv "$f" "$f.sed"
		sed s:"[0-9A-Z]\{8\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{12\}":$foldShared: "$f.sed" > "$f"

		mv "$f" "$f.sed"
		sed s:"\(^.*\/var\/containers\/Bundle\/Application\/\)\([0-9A-Z]\{8\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{12\}\)\(.*\)":"\1$foldPrivat\3": "$f.sed" > "$f"

	    rm "$f.sed"
	done

	## Update folder name into RetroArch Shader preset
	for f in $(find ./RetroArch/$foldRetroShad -maxdepth 1 -name '*.glslp'); do
		echo "Updating file: $f"

		mv "$f" "$f.sed"
		sed s:"[0-9A-Z]\{8\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{12\}":$foldShared: "$f.sed" > "$f"

		mv "$f" "$f.sed"
		sed s:"\(^.*\/var\/containers\/Bundle\/Application\/\)\([0-9A-Z]\{8\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{4\}-[0-9A-Z]\{12\}\)\(.*\)":"\1$foldPrivat\3": "$f.sed" > "$f"

	    rm "$f.sed"
	done
fi

### Retore original Update file name
mv "$updfold/$updfile" "$updfold/$updfileorig"

### Finish
IFS=$OLDIFS