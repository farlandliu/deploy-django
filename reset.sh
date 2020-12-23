#!/bin/bash

echo "Warning !!!"
echo "  The scripts will remove database data"
echo

APPNAME=$1

if [ "$APPNAME" == "" ] ; then
	echo "Usage:"
	echo "  $ ./reset.sh  <project> "
	echo
	exit 1
fi

echo -n "Want to  delete $APPNAME conf files and database? (y/n)? "
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo Yes
else
    echo No
fi

GROUPNAME=webapps
# app folder name under /webapps/<appname>_project
APPFOLDER=$1
APPFOLDERPATH=/$GROUPNAME/$APPFOLDER

# remove nginx conf
echo "removing nginx conf for $APPNAME"
rm -rf /etc/nginx/sites-enabled/$APPNAME
service nginx reload

# remove supervisor conf
echo "removing supervisor conf for $APPNAME"
rm -rf /etc/supervisor/$APPNAME.conf
service supervisord restart

# drop database;
echo "removing database for $APPNAME"
cat > /tmp/tm.sql << EOF
drop database $APPNAME;
drop user $APPNAME;
EOF

su -l postgres << 'EOF'
psql -f /tmp/tm.sql
EOF
echo "removing files $APPFOLDERPATH "
rm -rf $APPFOLDERPATH