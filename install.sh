#!/bin/bash
#############################################
#
# Installation script for Ruby 1.9 (http://www.ruby-lang.org).
#
# Script will download specified Ruby version and set of necessary libraries
# and will compile and install it.
#
# Copyright (c) 2010 Vanilladesk Ltd., http://www.vanilladesk.com
#
#############################################

##### CONFIGURATION - TO BE MODIFIED IF NECESSARY
# Ruby version to be used
ruby_version="1.9.2-p0"

# Archive file "tarball" name
ruby_tar="ruby-$ruby_version.tar.gz"

# URL to be used to download Ruby archive
ruby_download="ftp://ftp.ruby-lang.org//pub/ruby/1.9/$ruby_tar"

#--------------------------------------------
# color codes

C_BLACK='\033[0;30m'
C_RED='\033[1;31m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[1;34m'
C_MAGENTA='\033[1;35m'
C_CYAN='\033[1;36m'
C_WHITE='\033[1;37m'
C_GRAY='\033[;37m'
C_DEFAULT='\E[0m'

#-------------------------------------------

function cecho ()  {
  # Description
  #   Colorized echo
  #
  # Parameters:
  #   $1 = message
  #   $2 = color
  
  message=${1:-""}   # Defaults to default message.
  color=${2:-$C_BLACK}           # Defaults to black, if not specified.
  
  echo -e "$color$message$C_DEFAULT"  
  
  return
} 

# ----------------------------------------

function rename_ruby_tools {

  local ruby_tools="ruby irb erb testrb gem rake ri rdoc"
  local t=""
  local t_path=""
  local old_ver="$1"
  
  if [ ! "$old_ver" ]; then
    return
  fi
  
  echo "Renaming existing Ruby tools..."
  for t in $ruby_tools
  do
    t_path="`which $t`"
	[ "$t_path" ] && echo ".." $t_path to $t_path$old_ver && sudo mv $t_path $t_path$old_ver
  done

}

# -----------------------------------------------

##### OTHER VARIABLES - TO BE KEPT AS THEY ARE
# get old ruby version number
if [ "`which ruby`" ]; then
  old_ruby_ver=(`ruby -v`)
  old_ruby_ver="${old_ruby_ver[1]}"
  echo "Ruby version $old_ruby_ver is installed."
fi

work_fld="/var/tmp/ruby"
orig_fld="$PWD"
tar_install_fld="/usr/local/src"

# if existing ruby version is the same as the one being installed?
if [ "$ruby_version" == $"old_ruby_ver" ]; then
  cecho "Warning: Existing version $old_ruby_ver of Ruby is the same as the one you are about to install $ruby_version." $C_MAGENTA
  exit 1
fi

# is sudo installed?
if [ ! "`which sudo`" ]; then
  cecho "Error: SUDO package not installed." $C_RED
  exit 1
fi 

# is APT installed?
if [ ! "`which apt-get`" ]; then
  cecho "Error: APT-GET package not installed." $C_RED
  exit 1
fi 

# update installation packages
cecho "Updating list of available package repositories." $C_GREEN
sudo apt-get update

cecho "Installing necessary packages." $C_GREEN
sudo apt-get -y install sudo sed \
   zlib1g-dev libyaml-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev\
   git-core gcc make build-essential
if [ $? -ne 0 ]; then
  cecho "Fatal error: Can't install required packages." $C_RED
  exit 1
fi

cecho "Creating temporary folder." $C_GREEN 
# create work folder in case it does not exist
[ -d $work_fld ] || sudo mkdir $work_fld

# test if we are able to write to work folder
sudo touch $work_fld/test
if [ $? -ne 0 ]; then
  cecho "Fatal error: can't open work folder $work_fld" $C_RED
  exit 1
fi

cd $work_fld

# remove install archive in case it does exist just to be sure it is correct
[ -e $ruby_tar ] && sudo rm $ruby_tar > /dev/nul

# download archive
cecho "Downloading Ruby archive." $C_GREEN 
sudo wget $ruby_download
if [ $? -ne 0 ]; then
  cecho "Fatal error: can not download $ruby_download." $C_RED
  exit 1
fi

# extract original source archive to predefined folder
cecho "Extracting downloaded Ruby archive." $C_GREEN 
sudo tar xzf $ruby_tar -C $tar_install_fld
if [ $? -ne 0 ]; then
  cecho "Fatal error: can not extract archive $ruby_tar to folder $tar_install_fld." $C_RED
  exit 1
else
  echo "Archive extracted."
fi

ruby_src_fld=$tar_install_fld/${ruby_tar%.tar.gz}

if [ ! -d $ruby_src_fld ]; then
  cecho "Fatal error: expected folder does not exist $ruby_src_fld" $C_RED
  exit 1
fi

if [ ! -e "$ruby_src_fld/configure" ]; then
  cecho "Fatal error: configure not found in $ruby_src_fld" $C_RED
  exit 1
fi

############################### Files should be already there ###############

pushd $ruby_src_fld

cecho "Preparing Ruby source for compilation." $C_GREEN 
sudo ./configure
if [ $? -ne 0 ]; then
  cecho "Fatal: Something went wrong while running 'configure'. Please check." $C_RED
  exit 2
fi

cecho "Compiling Ruby." $C_GREEN 
sudo make
if [ $? -ne 0 ]; then
  cecho "Fatal: Something went wrong while running 'make'. Please check." $C_RED
  exit 2
fi

# seems that everything is going fine so far, so right now it is time to 
# handle old ruby version
if [ "$old_ruby_ver" ]; then
  cecho "Renaming existing installed Ruby tools." $C_GREEN 
  rename_ruby_tools "$old_ruby_ver"
fi

cecho "Installing Ruby." $C_GREEN 
sudo make install
if [ $? -ne 0 ]; then
  cecho "Fatal: Something went wrong while running 'make install'. Please check." $C_RED
  exit 2
fi

popd

# clean up
cecho "Cleaning up." $C_GREEN 
sudo rm -R $work_fld

cecho "----------------------------------------" $C_CYAN
cecho "Ruby $ruby_version has been successfully installed." $C_CYAN
if [ "$old_ruby_ver"]; then
  cecho "You can still continue using your previous version by adding \ 
        version to the tool you want to use, e.g. ruby$old_ruby_ver" $C_CYAN
fi
cecho "----------------------------------------" $C_CYAN

