#!/bin/bash

key=$1

funcs=$( ag"\@Callback\(" -A 1)

funcs

ag -rl "Agent" | xargs ag  "\@Callback\(" -A 1 