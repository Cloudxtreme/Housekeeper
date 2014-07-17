#!/bin/bash

# Config
tested_ruby_version=2.1.1
required_gems=(colorize net/smtp yaml logger)

echo

###############################################################################
# Check dependancies

echo 'Checking Housekeeper dependancies...'
echo

## Ensure Git is installed
echo 'Checking Git is installed...'
git_version=$(git --version)

if [ $? -ne 0 ]; then
    read -p 'No Git found. Can I install the latest stable version? (yes/no): ' install_git_kb_reply

	case ${install_git_kb_reply} in
		'yes')
    		sudo apt-get install git
    		if [ $? -ne 0 ]; then
        		echo 'Could not install Git. Aborting...'
        		exit 1
    		fi
    	;;

		'no')
			echo 'Git will not be installed. Aborting...'
			exit 0
		;;

		*)
		    echo "Invalid response. Expecting 'yes' or 'no'. Aborting..."
		    exit 1
		;;
	esac
else
    echo 'Git is already installed.'
fi

## Ensure Ruby is installed and at compatible version
echo 'Checking Ruby is installed...'
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
else
    echo 'Found existing Ruby installation.'
fi

echo 'Checking Ruby is a compatible version...'

bad_version=$(awk "BEGIN{ print "${ruby_version}"<"${tested_ruby_version}" }")

if [ ${bad_version} == 1 ]; then
    read -p "Ruby $ruby_version is not compatible with Housekeeper. Can I install the latest stable version using RVM? (yes/no): " upgrade_ruby_kb_reply

    case ${upgrade_ruby_kb_reply} in
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
else
    echo "Compatible Ruby $tested_ruby_version installation found."
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
        echo "$g Gem is already installed."
    fi
done

###############################################################################
# Install Housekeeper

echo 'Changing to your home directory...'
cd $HOME > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Unable to enter '$HOME' directory. Aborting..."
    exit 1
else
    CURRENT_DIR=$(pwd)
    echo "Now in '$CURRENT_DIR'"
fi

## Git clone Housekeeper repo
echo 'Cloning Housekeeper repository...'
git clone https://github.com/daniel-middleton/Housekeeper.git
if [ $? -ne 0 ]; then
    echo "Unable to Git clone in '$HOME' directory. Aborting..."
    exit 1
else
    echo "Housekeeper successfully cloned to '$HOME/Housekeeper'"
fi

## Add Housekeeper shell alias
echo "Adding 'housekeeper' Shell alias..."
echo "alias housekeeper='ruby ~/Housekeeper/Housekeeper.rb' # Housekeeper alias added by Install.sh" >> ~/.bashrc
if [ $? -ne 0 ]; then
    echo "Unable to add Housekeeper to your PATH. Please do this manually."
else
    echo "Successfully added and loaded 'housekeeper' Shell alias."
fi

echo
echo "Installation complete. Please update '~/Housekeeper/conf/housekeeper.conf' and open a new Shell to use the 'housekeeper' command."
echo

exit 0