#!/bin/sh
# -*- coding: utf-8 -*-


cat test/input.txt | perl -I lib test.pl | diff -q - test/output.txt && echo "ok" || echo "failed"

exit 1
