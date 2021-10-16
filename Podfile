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
  pod 'AlamofireImage'
  
  #Reactivex
  pod 'RxSwift'
  pod 'RxCocoa'
  
  #UI
  pod 'BusyNavigationBar'
  pod 'Pageboy'
  pod 'SwipeCellKit'
  pod 'SideMenu'
  pod 'Bulletin'
  pod 'BulletinBoard'
  pod 'SPAlert'
  pod 'OpenLocationCode'
  pod 'FloatingPanel'
  pod 'ParallaxHeader'
  pod 'Squircle'
  pod 'KafkaRefresh'
  pod 'SkeletonView'
  pod 'collection-view-layouts/TagsLayout'
  pod 'MIBlurPopup'
  pod 'Cosmos'
  pod 'Google-Maps-iOS-Utils'
  pod 'SnapKit'
  #DI
  pod 'Swinject'
  pod 'Repeat'

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
      end
    end
end
