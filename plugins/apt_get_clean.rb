# File:     apt_get_clean.rb
# Author:   Daniel Middleton (daniel-middleton.com)
# License:  GPL
# Desc:     Housekeeper Plugin to run an apt-get clean on a Linux-based system

class Apt_get_clean

  ###################################################################################
  # Method to cleanup packages

  def Perform_apt_get_clean

    # Run AutoRemove
    print_line('Starting Clean...', 'info')

    clean_response = system('sudo apt-get -y clean')

    if clean_response != true

      report_error("#{__method__}")

    else

      print_line('Clean successfully completed.', 'success')

    end

  end

end