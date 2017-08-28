#!/bin/sh

mkdir -p build

file_name="junit-guideline-$(git describe --abbrev=0 --tags)-$(date +'%Y%m%d-%H%M%S')"

gitbook pdf . build/${file_name}.pdf
