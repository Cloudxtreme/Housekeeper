# File:         Housekeeper.rb
# Author:       Daniel Middleton (daniel-middleton.com)
# Description:  Housekeeper is a modular plugin-based script runner application

################################## Configuration #################################

# Relative location of config file
config_file = "conf/housekeeper.conf"

###################################################################################
############################## No need to edit below ##############################

# Required libraries
require('colorize')
require('net/smtp')
require('yaml')
require('logger')

# Generated absolute location of config file
Config_file_full_path = "#{File.expand_path File.dirname(__FILE__)}/#{config_file}"

# Program version
Housekeeper_version   = '1.0'

# Create logging object
log_path = "#{File.expand_path File.dirname(__FILE__)}/logs/housekeeper.log"
$logger = Logger.new(log_path, 0, 100 * 1024 * 1024)

###################################################################################
# Method to take any string input and puts it with prepended timestamp

def print_line(input, type)

  output = "[Housekeeper] : #{Time.now} : #{input}"

  if type == 'success'

    puts output.green
    $logger.info(input)

  elsif type == 'info'

    puts output.blue
    $logger.info(input)

  elsif type == 'warn'

    puts output.yellow
    $logger.warn(input)

  elsif type == 'error'

    puts output.blue
    $logger.error(input)

  else

    puts output.red
    $logger.unknown(output)

  end

  return output

end

###################################################################################
# Method to send an email notification if something fails

def send_email(content)

  print_line('Sending email notification...', 'info')

  message = <<MESSAGE_END
From: Housekeeper <#{$from_email_addr}>
To: Housekeeper Admin <#{$to_email_addr}>
Subject: Housekeeper Alert

#{content}

MESSAGE_END

  begin

    Net::SMTP.start("#{$smtp_server_addr}") do |smtp|

      smtp.send_message message, "#{$from_email_addr}", "#{$to_email_addr}"

    end

    print_line('Email notification sent.', 'success')

  rescue

    print_line('More fuck, email notification could not be sent. You should tell an admin about this.', 'error')

  end

end

###################################################################################
# Method to print a generic error, send an email notification and exit

def report_error(method)

  content = "Fuck...it seems there was a problem during \'#{method}\'."

  # Print error terminal
  print_line("#{content}", 'error')

  # Send email notification
  send_email("#{content}")

  # Print exit notice terminal
  print_line('Exiting...', 'error')

  # Exit
  exit(1)

end

###################################################################################
# Method to ensure Housekeeper's dependencies are met

def precheck

  # Check Ruby version
  print_line("Housekeeper was tested on Ruby #{$tested_ruby_version}", 'info')

  if RUBY_VERSION != $tested_ruby_version

    print_line("Your Ruby version is #{RUBY_VERSION}. This is not supported but may work fine. If not, use Ruby #{$tested_ruby_version}", 'warn')

  else

    print_line("Your Ruby version is also #{RUBY_VERSION}. Good to go.", 'success')

  end

  # Check Sudo password
  print_line('Checking sudo credentials...', 'info')

  sudo_check_response = system("echo '#{$sudo_password}' | sudo -S echo 'Sudo OK!'")

  if sudo_check_response != true

    report_error("#{__method__} - Check Sudo Credentials")

  else

    print_line('Sudo credentials verified.', 'success')

  end

  # Check SMTP connectivity
  print_line('Checking SMTP connectivity for error reporting...', 'info')

  print_line('This check is to be implemented in the next release. Skipping...', 'success')

end

###################################################################################
# Method to load and apply config from housekeeper.conf

def load_config

  print_line("Loading config from \'#{Config_file_full_path}\'...", 'info')

  begin

    config = YAML.load_file("#{Config_file_full_path}")

    # System settings
    $sudo_password       =   get_password_arg.to_s.chomp
    $tested_ruby_version =   config["config"]["system"]["tested_ruby_version"]

    # Email notification settings
    $smtp_server_addr    =   config["config"]["email"]["smtp_server_addr"]
    $to_email_addr       =   config["config"]["email"]["to_email_addr"]
    $from_email_addr     =   config["config"]["email"]["from_email_addr"]

    # Plugins
    $plugins            =    config["config"]["plugins"]

  rescue

    print_line("Could not load config from \'#{Config_file_full_path}\'. You should tell an admin about this. Exiting...", 'error')
    exit(1)

  end

  # Print config because we can
  print_line('-----------------------------------------------------', 'info')
  print_line("Sudo Password: *** hidden ***", 'info')
  print_line("Tested Ruby Version: #{$tested_ruby_version}", 'info')
  print_line("SMTP Server Address: #{$smtp_server_addr}", 'info')
  print_line("To Email Address: #{$to_email_addr}", 'info')
  print_line("From Email Address: #{$from_email_addr}", 'info')
  print_line('-----------------------------------------------------', 'info')

  print_line("Successfully loaded config from \'#{Config_file_full_path}\'.", 'success')

end

###################################################################################
# Method to print the welcome graphic

def welcome

  puts "\n"
  puts " /  |                     /"
  puts "(___| ___       ___  ___ (     ___  ___  ___  ___  ___"
  puts "|   )|   )|   )|___ |___)|___)|___)|___)|   )|___)|   )"
  puts "|  / |__/ |__/  __/ |__  | \\  |__  |__  |__/ |__  |"
  puts "\n"
  puts "################################################################################"
  puts "# Housekeeper v#{Housekeeper_version}                                                             #"
  puts "# Housekeeper is a modular plugin-based script runner application.             #"
  puts "# Written and maintained by Daniel Middleton (daniel-middleton.com) under GPL. #"
  puts "################################################################################"
  puts "\n"
  print_line("I\'m the Housekeeper. Please bare with me while I tidy your shit up...", 'info')

end

###################################################################################
# Method to orchestrate the show

def main

  # Print welcome
  welcome

  # Load config
  load_config

  # Check dependencies and enter su session
  precheck

  # Run each plugin in order
  print_line('Parsing Plugin config to execute...', 'info')

  # For each Plugin, extract config and execute
  begin

    $plugins.each_key do |plugin|

      struct_name = $plugins["#{plugin}"]

      name        =   struct_name['name']
      file_path   =   struct_name['file_path']
      class_name  =   struct_name['class_name']
      method_name =   struct_name['method_name']

      print_line('-----------------------------------------------------', 'info')
      print_line("Loading \'#{name}\' plugin...", 'info')
      print_line("Plugin path: \'#{file_path}\'", 'info')
      print_line("Class name: \'#{class_name}\'", 'info')
      print_line("Method name: \'#{method_name}\'", 'info')

      # Require Plugin
      require_relative("#{file_path}")

      print_line("\'#{name}\' plugin successfully loaded.", 'success')
      print_line('-----------------------------------------------------', 'info')

      # Run the Plugin
      Object.const_get(class_name).new.public_send(method_name)

    end

  rescue

    report_error("#{__method__} - Error while executing Plugin.")

  end

  print_line('All Plugins executed successfully.', 'success')

end

###################################################################################
# Method to get Sudo Password as argument

def get_password_arg

  begin

    sudo_password = "#{ARGV.join( ' ' )}"

    if sudo_password == ''

      puts ''
      puts 'Usage: Housekeeper.rb \'Sudo Password\' (quotes compulsory)'
      puts ''
      exit(1)

    end

    return sudo_password

  rescue

    report_error("#{__method__} - Error while parsing argument.")

  end

end

###################################################################################
# Execute program

# Check sudo password argument is not empty
get_password_arg

# Run
main

# Print finish output and exit
print_line('Housekeeper successfully finished. Exiting...', 'success')
puts "\n"
exit(0)
