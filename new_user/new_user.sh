#!/bin/bash
USERNAME=$1
useradd $USERNAME
echo "$USERNAME:ChangeMe123" | chpasswd
passwd --expire $USERNAME
