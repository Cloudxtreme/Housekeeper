# File:     apt_get_autoclean.rb
# Author:   Daniel Middleton (daniel-middleton.com)
# License:  GPL
# Desc:     Housekeeper Plugin to run an apt-get autoclean on a Linux-based system

class Apt_get_autoclean

  ###################################################################################
  # Method to cleanup packages

  def Perform_apt_get_autoclean

    # Run AutoRemove
    print_line('Starting AutoClean...', 'info')

    autoclean_response = system('sudo apt-get -y autoclean')

    if autoclean_response != true

      report_error("#{__method__}")

    else

      print_line('AutoClean successfully completed.', 'success')

    end

  end

end