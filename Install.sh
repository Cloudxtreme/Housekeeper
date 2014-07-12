#!/bin/bash
echo

# Check dependancies
echo 'Checking Housekeeper dependancies...'

## Ensure Ruby is installed
ruby_version=$(ruby -v)

if [ $? -ne 0 ]; then
    echo 'No Ruby found. Installing latest stable version...'
    \curl -sSL https://get.rvm.io | bash -s stable --ruby
else
    echo 'Ruby found.'
fi

## Check Ruby is up-to-date
echo 'Ruby version check yet to be implemented.'

## Ensure required gems are installed
required_gems=(colorize net/smtp yaml logger)

for g in ${required_gems[@]}; do
    gem_test_response=$(gem which $g)
    if [ -z "$gem_test_response" ]; then
        echo "$g Gem not found. Installing..."
        gem install $g
    else
        echo "$g Gem found."
    fi
done

echo
exit 0