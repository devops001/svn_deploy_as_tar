#!/usr/bin/ksh
# Purpose:  Creates an unversioned (no .svn dirs) backup (tar.gz) 
#           of an svn repository.
#############################################################

REVISION=$1

NAME=fax     #<- beginning of tar file name
REPO=file:///home/prodctl/repos/easylink/fax
TMP_WDIR=$HOME/fax.$$
DESTINATION_HOST=FaxHost002

#############################################################

function puts {
  printf "%-20s%s\n" $1 $2
}

#############################################################

svn co $REPO $TMP_WDIR
cd $TMP_WDIR
VERSION=$(svnversion)

#############################################################
## use the requested version if one was requested:
#############################################################

if [[ ! -z $REVISION ]]; then
  if [[ "$REVISION" -ne "$VERSION" ]]; then
    echo "#################################################################"
    echo "newest version is $VERSION however we will attempt to use"
    echo "the requested version: $REVISION"
    echo "#################################################################"
    echo
    svn up -r$REVISION
    VERSION=$(svnversion)
    if [[ "$REVISION" -ne "$VERSION" ]]; then
      echo "sorry, requested version $REVISION didn't work."
      echo "leaving working dir for you to investigate:"
      echo "$TMP_WDIR"
      exit 1
    fi 
  fi
fi

#############################################################
## pack it up and send it off
#############################################################

puts "Version:" $VERSION

OLD_TAR=$(ls -d $HOME/${NAME}_*.tar.gz 2>/dev/null |grep -v unversioned)
if [[ -e $OLD_TAR ]]; then
  puts "Removing:"  $OLD_TAR
  rm -f $OLD_TAR
fi

OLD_DIR=$(ls -d $HOME/${NAME}_* 2>/dev/null)
if [[ -e $OLD_DIR ]]; then
  puts "Removing:"  $OLD_DIR
  rm -fr $OLD_DIR
fi

NEW_DIR="$HOME/${NAME}_r$VERSION"
puts "Creating:" $NEW_DIR
cp -R $TMP_WDIR $NEW_DIR

VERSION_FILE=$NEW_DIR/VERSION
puts "Creating:" $VERSION_FILE
svn log -v -rHEAD:0 > $VERSION_FILE

puts "Unversioning:" $NEW_DIR
for i in $(find $NEW_DIR -type d -name .svn); do rm -fr $i; done

NEW_TAR="$HOME/${NAME}_r$VERSION.tar"
puts "Creating:"  $NEW_TAR
cd $NEW_DIR
tar cf $NEW_TAR * .profile

NEW_GZIP="$NEW_TAR.gz"
puts "Compressing:" $NEW_GZIP
gzip $NEW_TAR

puts "Removing:" $NEW_DIR
cd $HOME
rm -fr $NEW_DIR

rm -fr $TMP_WDIR

puts "Finished:" $NEW_GZIP

puts "Copying_To:" $DESTINATION_HOST
scp $NEW_GZIP $DESTINATION_HOST:$NEW_GZIP

rm $NEW_GZIP

