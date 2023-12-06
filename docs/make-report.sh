#!/bin/bash

pandoc -H fix.tex frontpage.md report.md -o report.pdf --bibliography=references.bib --csl=https://raw.githubusercontent.com/citation-style-language/styles/master/apa.csl