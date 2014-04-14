#!/bin/bash

ionice -c3 mvn2 clean install -Dmaven.test.skip=true "$@"
