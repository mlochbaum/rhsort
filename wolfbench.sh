#! /bin/sh

if [ ! -d wolfsort ]
then
  git clone https://github.com/scandum/wolfsort.git
  cd wolfsort/src
  git apply ../../wolfbench.diff
  wget https://raw.githubusercontent.com/orlp/pdqsort/b1ef26a55cdb60d236a5cb199c4234c704f46726/pdqsort.h
  wget https://raw.githubusercontent.com/skarupke/ska_sort/2c14d4bf7b667032ed28a481065f721385e33849/ska_sort.hpp
else
  cd wolfsort/src
fi
g++ -O3 -w -fpermissive bench.c -o ../../runwolfbench
echo "Created ./runwolfbench"
