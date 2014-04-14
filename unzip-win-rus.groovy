#!/usr/bin/env groovy

// Solved problem: http://www.opennet.ru/tips/info/2494.shtml (recipes from there does not work, patches does not tested)

	if (!args[0]){
	println 'You must provide single argument - archive name'
	}

def ant = new AntBuilder()   // create an antbuilder

ant.unzip(
	src: args[0],
	dest: '.',
	overwrite: 'true',
	encoding: 'Cp866'
)