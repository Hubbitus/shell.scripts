#!/bin/bash

(sleep 3; echo "One")

(sleep 2; echo "Two" )&

(sleep 1; echo "Three" )&

wait
