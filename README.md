# Utilities for Bulk Loading Open Annotations into Triannon and Fedora4

[![Build Status](https://travis-ci.org/sul-dlss/annotations2triannon.svg?branch=master)](https://travis-ci.org/sul-dlss/annotations2triannon)

## A work in progress

- rapidly evolving code (as of early 2015)
- no gems published yet
- no stable API

## Open Annotation Resources

- http://www.openannotation.org/spec/core/
- http://austese.net/lorestore/validate.html

## Triannon Resources

- https://github.com/sul-dlss/triannon-service
    - README has useful info

- Triannon gem
    - https://github.com/sul-dlss/triannon
    - has annotation specific graph manipulations:
        - https://github.com/sul-dlss/triannon/blob/master/lib/triannon/graph.rb
    - also RDF vocabs, four small gems for easy ruby RDF vocabulary access:
        - https://github.com/sul-dlss?query=rdf
    - also has specs that show posting annos and looking at http return codes, etc
        - https://github.com/sul-dlss/triannon/blob/master/spec/integration
    - http status codes:
        - https://github.com/sul-dlss/triannon/search?utf8=%E2%9C%93&q=status

