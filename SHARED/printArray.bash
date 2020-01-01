#!/bin/bash

function printArray(){
OLD_IFS=$IFS
IFS=$'\n'

echo "$*"

IFS=$OLD_IFS
}
