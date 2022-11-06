#!/usr/bin/env groovy

/**
* ZIP archives created in Windows have CP866 encoding page for file and folder names.
* So, extracting them in Linux will lead to broken filenames.
* This simple script solves this problem with very simple way.
* Solved problem: http://www.opennet.ru/tips/info/2494.shtml (recipes from there does not work, patches does not tested)
**/

@Grab(group='org.apache.groovy', module='groovy-ant', version='4.0.6')
import groovy.ant.AntBuilder

if (!args.length){
	println 'You must provide single argument - archive name'
	System.exit(1)
}


new AntBuilder().unzip(
	src: args[0],
	dest: '.',
	overwrite: 'true',
	encoding: 'Cp866'
)