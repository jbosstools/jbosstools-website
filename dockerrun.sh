#!/bin/bash
#
echo "Run this:"
cat readme.adoc | grep dock | tail -1 | sed -e "s/\\$//"
echo ""
echo "Then when docker is running, start the website like this:"
echo "    rake clean preview"
echo ""
echo "Then open a browser:"
echo "    google-chrome http://localhost:4242/"