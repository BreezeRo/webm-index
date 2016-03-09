# webm-index

This is a simple webm index thingy.

## Requirements

* A sane web server (i.e. not Apache or IIS)
* Ruby 2.0+ (no external gems required)
* CoffeeScript
* cron (for rebuilding the index)

## Usage

1. Copy `config.yml.example` to `config.yml` and modify it to your needs.
2. Copy the example `nginx.conf.example` to your web server.
3. Build the entire website with the `build.sh` build script.
4. Each time you place some new WebM files in your WebM directory, re-run `gen_website.rb`.

## Extra features

Ignore some WebMs by `touch`ing the WebM file with `.ignore` appended to the file name.  For
example, if you want to ignore the WebM `rms.webm`, you'd just run `touch rms.webm.ignore`
from the terminal.

Add some metadata by creating a `webm_file.webm.desc` file.  The description file is a YAML
file which looks like this:

``` yaml
---
title: My super awesome WebM
description: A longer description for the super awesome WebM.
song: Scooter - Hyper Hyper
```

Each tag is optional.

