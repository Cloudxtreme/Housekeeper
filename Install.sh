#!/bin/bash

# Config
tested_ruby_version=2.1.1
required_gems=(colorize net/smtp yaml logger)
install_directory='~/Housekeeper'

echo

###############################################################################
# Check dependancies

echo 'Checking Housekeeper dependancies...'
echo

## Ensure Ruby is installed and at compatible version
ruby_version=$(ruby -e 'print RUBY_VERSION') > /dev/null 2>&1

if [ $? -ne 0 ]; then
    read -p 'No Ruby found. Can I install the latest stable version using RVM? (yes/no): ' install_ruby_kb_reply
	
	case ${install_ruby_kb_reply} in
		'yes')
    		\curl -sSL https://get.rvm.io | bash -s stable --ruby
    		if [ $? -ne 0 ]; then
        		echo 'Could not install Ruby using RVM. Aborting...'
        		exit 1
    		fi
    	;;

		'no')
			echo 'Ruby will not be installed. Aborting...'
			exit 0
		;;

		*)
		    echo "Invalid response. Expecting 'yes' or 'no'. Aborting..."
		    exit 1
		;;
	esac
fi

bad_version=$(awk "BEGIN{ print "${ruby_version}"<"${tested_ruby_version}" }")

if [ ${bad_version} == 1 ]; then
    echo "Ruby $ruby_version is not compatible with Housekeeper. Installing latest stable version..."

    \curl -sSL https://get.rvm.io | bash -s stable --ruby
    if [ $? -ne 0 ]; then
        echo 'Could not install Ruby using RVM. Aborting...'
        exit 1
    fi
else
    echo "Ruby $tested_ruby_version found."
fi

## Ensure required gems are installed
for g in ${required_gems[@]}; do
    gem_test_response=$(gem which ${g}) > /dev/null 2>&1
    if [ -z "$gem_test_response" ]; then
        echo "$g Gem not found. Installing..."

        gem install ${g}
        if [ $? -ne 0 ]; then
            echo "Could not install $g Gem. Aborting..."
            exit 1
        fi
    else
        echo "$g Gem found."
    fi
done

###############################################################################
# Install Housekeeper

## Create and enter installation directory
mkdir $install_directory
if [ $? -ne 0 ]; then
    echo "Unable to create '$install_directory' directory. Aborting..."
    exit 1
fi

cd $install_directory
if [ $? -ne 0 ]; then
    echo "Unable to enter '$install_directory' directory. Aborting..."
    exit 1
fi

## Git clone Housekeeper repo
git clone https://github.com/daniel-middleton/Housekeeper.git
if [ $? -ne 0 ]; then
    echo "Unable to Git clone in '$install_directory' directory. Aborting..."
    exit 1
fi

echo
echo "Installation complete.\nPlease update 'conf/housekeeper.conf' and use 'ruby Housekeeper.rb' to run.\nIt is also advisable to add Housekeeper as a shell alias."
echo

exit 0