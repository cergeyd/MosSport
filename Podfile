# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MosSportMap' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  # ignore all warnings from all pods
  inhibit_all_warnings!
  # Pods for MosSportMap
  pod 'Device'

  #Networking
  pod 'Alamofire'
  
  #Reactivex
  pod 'RxSwift'
  pod 'RxCocoa'
  
  #UI
  pod 'BusyNavigationBar'
  pod 'Pageboy'
  pod 'SwipeCellKit'
  pod 'Bulletin'
  pod 'SPAlert'
  pod 'Squircle'
  pod 'collection-view-layouts/TagsLayout'
  pod 'Google-Maps-iOS-Utils'
  pod 'libxlsxwriter'
  pod "SwiftCSV"
  
  #DI
  pod 'Swinject'

  #Code generation (resources)
  pod 'R.swift'
  
  #Storage
  pod 'KeychainAccess'

end

install! 'cocoapods', :deterministic_uuids => false

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        config.build_settings['LD_NO_PIE'] = 'NO'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
end
