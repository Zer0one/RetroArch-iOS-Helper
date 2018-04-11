#!/bin/bash

OLDIFS=$IFS
IFS=$'\n'
shopt -s nullglob

foldpre="DD0DC67C-66FC-4782-AD1D-E7B3DF4552A7"
foldnew="E99E052A-2F73-43C9-981F-4FDF77CFE8E0"
# direq="equal2next"

for d in $(ls -d */); do
	cd "${d%%/}"
	for f in *.{cfg,lpl}; do
		mv "$f" "$f.sed"
		echo "Updating file: $f"
		sed s:$foldpre:$foldnew: "$f.sed" > "$f"
		rm "$f.sed"
	done
	cd ..
done


# if [ -z $(ls -A "./$dir1/$direq") ]; then
#    rmdir "$dir1/$direq"
# fi


# for d in $(ls -d */); do
#	cd "${d%%/}"
#	for f in *.chd; do
#		echo "Converting Game: ${f%.*}\n"
#		"$exdir/chdman" extractcd -i "$f" -o "${f%.*}.cue"
#		#	echo "\n"
#		#	echo "${f%%.*}"
#		#	echo "${f#*.}"
#	done
#	cd ..
# done

IFS=$OLDIFS