# site from https://github.com/naoya/HBFav2/blob/development/2.5/app/cocoa/ui_device.rb

class UIDevice
  def ios7?
    return @is_ios7 unless @is_ios7.nil?

    version = UIDevice.currentDevice.systemVersion
    if (version.compare("7.0", options:NSNumericSearch) == NSOrderedSame or
        version.compare("7.0", options:NSNumericSearch) == NSOrderedDescending)
      return @is_ios7 = true
    end
    return @is_ios7 = false
  end

  def ios6?
    !ios7?
  end
end
