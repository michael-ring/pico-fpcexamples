#!/bin/sh
for file in * ; do
  if [ -d $file -a $file != "templates" -a $file != "units" -a $file != "esp_images" ]; then
    ./genlpi.sh $file
  fi
done

