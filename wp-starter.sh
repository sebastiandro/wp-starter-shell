#!/bin/sh
cd /Applications/MAMP/htdocs

# Welcome Message
printf "Hi friends! Let's create a new Wordpress installation. \n"

# Read Root dir
printf "What would you like to name your root directory? \n"
printf "Directory name: "
read NEWDIR

# Submodule Y/N
printf "Would you like to use Wordpress as a Submodule? [y|n] "
read SUBMODULE

if [ "$SUBMODULE" = "y" ]; then
	git clone --recursive https://github.com/sebbehebbe/wp-start.git $NEWDIR
	cd $NEWDIR
	perl -pi -w -e "s/sitename/$NEWDIR/g;" wp-config.php
else 
	git clone https://github.com/WordPress/WordPress.git $NEWDIR
	cd $NEWDIR
	cp wp-config-sample.php wp-config.php
fi

# Wordpress Version
printf "What version of Wordpress do you want to use? "
read WPVER

if [ "$SUBMODULE" = "y" ]
	then
	cd cms
	git checkout $WPVER
	cd ..
	git remote rm origin
else
	git checkout $WPVER
	rm -rf .git
fi

# Wordpress Themes
printf "Would you like to add your own theme from a git repository? [y|n] "
read OWNTHEME

if [ "$OWNTHEME" = 'y' ]; then
	printf "Git repository clone URL: "
	read GIT_THEME
	cd wp-content/themes/
	git clone $GIT_THEME
	cd ../../../
else
	printf "Would you like to use my TacoTaco™ starter theme? [y|n] "
	read TACOTHEME
	if [ "$TACOTHEME" = "y" ]; then
		cd wp-content/themes/
		git clone https://github.com/sebbehebbe/taco.git taco
		cd taco
		rm -rf .git
		cd ../../../
	fi
fi

# Database Credentials
printf "Let's set up the server! \n"

printf "MySQL User: "
read MYSQLUSER

printf "MySQL Password: "
read MYSQLPASSWORD

# Default Credentials
if [ "$MYSQLUSER" = "" ]; then
	set MYSQLUSER = "root"
fi

if [ "$MYSQLPASSWORD" = "" ]; then
	set MYSQLPASSWORD = "root"
fi

# Setup Database
printf "What would you like to name your database? \n"
printf "Database name: "
read DBNAME

echo "CREATE DATABASE $DBNAME; GRANT ALL ON $DBNAME.* TO '$MYSQLUSER'@'localhost';" | /Applications/MAMP/Library/bin/mysql -u$MYSQLUSER -p$MYSQLPASSWORD

# Setup wp-config.php

perl -pi -w -e "s/database_name_here/$DBNAME/g;" wp-config.php
perl -pi -w -e "s/username_here/$MYSQLUSER/g;" wp-config.php
perl -pi -w -e "s/password_here/$MYSQLPASSWORD/g;" wp-config.php

if [ "$SUBMODULE" = "y" ]; then
	open http://localhost:8888/$NEWDIR/cms/wp-admin/install.php
else
	open http://localhost:8888/$NEWDIR/wp-admin/install.php
fi