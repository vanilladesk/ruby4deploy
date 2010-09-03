#!/bin/bash
#############################################
#
# Installation script for Phusion Passenger (http://www.modrails.com).
#
# Script will download specified Phusion Passenger version and set of necessary libraries
# and will compile and install it.
#
# Copyright (c) 2010 Vanilladesk Ltd., http://www.vanilladesk.com
#
#############################################

# is sudo installed?
if [ ! "`which sudo`" ]; then
  echo "Error: SUDO package not installed."
  exit 1
fi 

# is gem installed?
if [ ! "`which gem`" ]; then
  echo "Error: Gem package not installed. Check your ruby-gems installation."
  exit 1
fi 

# install passenger as gem
sudo gem install passenger
if [ $? -ne 0 ]; then
  echo "Error: Phusion Passenger installtion failed."
  exit 1
fi 

echo "----------------------------------------"
echo "Phusion Passenger has been successfully installed."
echo "----------------------------------------"


