#!/bin/bash
echo -e "\e[44m[Input]\e[0m Enter the size of the chess board: "
read value

echo -e "\n\n\e[42m[OUTPUT]\e[0m REQUESTED CHESS-BOARD \e[42m[OUTPUT]\e[0m"

for ((row = 1; row <= value; row++)); do
  for ((col = 1; col <= value; col++)); do
    sumOfRowAndCol=$(($(($row + $col)) % 2))
    if [ $sumOfRowAndCol -eq 0 ]; then
      echo -e -n "\033[47m" " "
    else
      echo -e -n "\033[40m" " "
    fi
  done
  echo -ne "\033[0m" " "
  echo
done

echo -n -e "\033[0m"
