#!/bin/bash

for i in {10.0.8.35,10.0.8.36}
	
do
   rsync -azprP --exclude=cache/ --exclude=logs/ /data/app/123.com/ @$i::123.com/

done
