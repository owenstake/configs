#!/bin/bash

case "$1" in
	*.pdf) pdftotext "$1" ;;
	*.md) glow -s dark "$1" ;;
	*.zip) zipinfo "$1" ;;
	*.tar*) tar -tvf "$1" ;;
	*.tgz) tar -tvf "$1" ;;
	*) bat --color=always --italic-text=always --style=numbers,changes,header --line-range :500 "$1" ;;
esac
