#!/bin/bash
#
echo "Run this:"
cat readme.adoc | grep dock | tail -1 | sed -e "s/\\$//"
