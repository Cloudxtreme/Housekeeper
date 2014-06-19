# File:     apt_get_dist_upgrade.rb
# Author:   Daniel Middleton (daniel-middleton.com)
# License:  GPL
# Desc:     Housekeeper Plugin to run an apt-get dist-upgrade on a Linux-based system

class Apt_get_dist_upgrade

  ###################################################################################
  # Method to dist-upgrade the system

  def Perform_apt_get_dist_upgrade

    # Run Dist-Upgrade
    print_line('Starting Dist-Upgrade...', 'info')

    dist_upgrade_response = system('sudo apt-get -y dist-upgrade')

    if dist_upgrade_response != true

      report_error("#{__method__}")

    else

      print_line('Dist-Upgrade successfully completed.', 'success')

    end

  end

end