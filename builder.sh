#!/bin/bash - 
#===============================================================================
#
#          FILE: builder.sh
# 
#         USAGE: ./builder.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 08/05/2019 01:53
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -ex


author="Shawn Wilson"
license="CC-by-SA-NC"

declare -a pics=(img/*.jpg)
declare -a allpics=(img/*.jpg thumbs/*.jpg)

thumbnail() {
  for file in $@; do
    convert -thumbnail 200 "$file" "${file/img/thumbs}"
  done
}

copyright() {
  for file in $@; do
    exiftool -Copyright="$license" "$file"
  done
}

artist() {
  for file in $@; do
    exiftool -Artist="$author" "$file"
  done
}

clean() {
  rm -f thumbs/*
}

postclean() {
  rm -f {img,thumbs}/*_original
}

git-add() {
  git add {img,thumbs}/*
}

git-commit() {
  git commit -am "[Automatic] Makefile update."
}

build-index() {

  if [[ -z $@ ]]; then
    files=(${pics[@]})
  else
    files=($@)
  fi

  cp -f index.html.tmpl index.html
  for file in ${files[@]}; do
    sed -i "/<!-- BUILDER IMAGE REPLACEMENT -->/ i $(gallery-file-html "$file")" index.html
  done
}

gallery-file-html() {
  echo -n " \
      <a \
        href=\\"https://media.githubusercontent.com/media/ag4ve/misc-pics/master/${1}\\" \
        title=\\"${2:-Untitled}\\" \
      > \
        <img \
          src=\\"https://media.githubusercontent.com/media/ag4ve/misc-pics/master/${1/img/thumbs}\\" \
          alt=\\"${2:-Untitled}\\" \
        /> \
      </a> \
  "
}

help() {
  echo -ne \
    "This is a dead simple bash builder script that lets you do\n" \
    "whatever you want - call rm on something as an argument if\n" \
    "you want - I won't stop you\n" \
    "\n" \
    "thumbnail    Generates thumbnail images of the original\n" \
    "copyright    Adds a copyright to images [EXIF]\n" \
    "artist       Adds photographer's name as the artist [EXIF]\n" \
    "clean        Try to clean up\n" \
    "postclean    Post run cleanup\n" \
    "git-add      Adds all files\n" \
    "git-commit   Commits everything with an automated message\n" \
    "\n"
}

if [[ -z $@ ]]; then
  clean
  thumbnail ${pics[@]}
  copyright ${allpics[@]}
  artist ${allpics[@]}
  postclean
  git-add
else
  for i in $@; do
    eval $i
  done
fi
