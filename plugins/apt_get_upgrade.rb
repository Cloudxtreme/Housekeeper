# File:     apt-get-upgrade.rb
# Author:   Daniel Middleton (daniel-middleton.com)
# License:  GPL
# Desc:     Housekeeper Plugin to run an apt-get upgrade on a Linux-based system

class Apt_get_upgrade

  ##################################################################################
  # Method to upgrade the system

  def Perform_apt_get_upgrade

    # Run Upgrade
    print_line('Starting Upgrade...', 'info')

    upgrade_response = system('sudo apt-get -y upgrade')

    if upgrade_response != true

      report_error("#{__method__}")

    else

      print_line('Upgrade successfully completed.', 'success')

    end

  end

end