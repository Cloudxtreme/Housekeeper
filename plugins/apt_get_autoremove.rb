# File:     apt_get_autoremove.rb
# Author:   Daniel Middleton (daniel-middleton.com)
# License:  GPL
# Desc:     Housekeeper Plugin to run an apt-get autoremove on a Linux-based system

class Apt_get_autoremove

  ###################################################################################
  # Method to cleanup packages

  def Perform_apt_get_autoremove

    # Run AutoRemove
    print_line('Starting AutoRemove...', 'info')

    autoremove_response = system('sudo apt-get -y autoremove')

    if autoremove_response != true

      report_error("#{__method__}")

    else

      print_line('AutoRemove successfully completed.', 'success')

    end

  end

end