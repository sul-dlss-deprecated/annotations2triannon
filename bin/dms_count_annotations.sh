#!/bin/bash

sed -e 's#.*:#:#' -e '/^[^0-9]*$/d' -e 's/: //' -e 's/,//' log/dms_annotation_text_counts.json | paste -s -d+ | bc
