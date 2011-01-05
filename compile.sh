#!/bin/bash

haxe src/xdoc.hxml
haxelib run xcross xdoc.n

mv xdoc-* bin/

rm xdoc.n