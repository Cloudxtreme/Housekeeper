# File:     apt_get_update.rb
# Author:   Daniel Middleton (daniel-middleton.com)
# License:  GPL
# Desc:     Housekeeper Plugin to run an apt-get update on a Linux-based system

class Apt_get_update

  ###################################################################################
  # Method to update the system

  def Perform_apt_get_update

    # Run Update
    print_line('Starting Update...', 'info')

    update_response = system('sudo apt-get -y update')

    if update_response != true

      report_error("#{__method__}")

    else

      print_line('Update successfully completed.', 'success')

    end

  end

end