#!/usr/bin/env sh

time=1
red='\033[0;31m'
green='\033[0;32m'
blue='\033[0;34m'
nc='\033[0m'

# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

sleep $time
rotation=2

logo(){

  case "$rotation" in
    0) color="$blue";;
    1) color="$green";;
    2) color="$red";;
  esac

  printf "%s${color}\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
DDDDDDD    OOOOOOOOO  CCCCCCCCC  K     KKK  EEEEEEEEE  RRRRRRRRR
D     DD   OO     OO  C          K  KKKK    EE         R       R
D      DD  OO     OO  C          KKKK       EEEEEEEEE  R   RRRRR
D      DD  OO     OO  C          KKKK       EE         R  RR
D     DD   OO     OO  C          K  KKKK    EE         R   RR
DDDDDDD    OOOOOOOOO  CCCCCCCCC  K     KKK  EEEEEEEEE  R     RRR
                      PPPPPPPP   RRRRRRRRR  OOOOOOOOO   SSSSSSSS  OOOOOOOOO  DDDDDDD    YY     YY
                      P       P  R       R  OO     OO  SS         OO     OO  D     DD    YY   YY
                      PPPPPPPP   R   RRRRR  OO     OO   SSSSSSS   OO     OO  D      DD     YYY
                      P          R  RR      OO     OO         SS  OO     OO  D      DD      Y
                      P          R   RR     OO     OO        SS   OO     OO  D     DD       Y
                      P          R     RRR  OOOOOOOOO  SSSSSSS    OOOOOOOOO  DDDDDDD        Y
                                                                Infrastructure by Gui Bressan
\n\n\n\n\n\n\n\n\n${nc}"

  case "$rotation" in
    2) printf "\n\n\n";;
    1) printf "\n\n";;
    0) printf "\n";;
  esac

  sleep $time

  rotation=$((rotation-1))

}

logo; logo; logo
