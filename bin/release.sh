#! /bin/bash
filename="listgen"$(date +"%Y%m%d").tar.gz
tar -pczf $filename listgen
