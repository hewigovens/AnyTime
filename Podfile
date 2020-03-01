platform :ios, '13'
install! 'cocoapods', :generate_multiple_pod_projects => true
target 'AnyTime' do
  use_frameworks! :linkage => :static

  pod 'Colours'
  pod 'SnapKit'
  pod 'Reusable'
  pod 'SwiftyUserDefaults'
  pod 'FontAwesomeKit/IonIcons'
  pod 'NotificationBannerSwift'

  pod 'SwiftLint'
  pod 'Crashlytics'
  pod 'Fabric'
  pod 'FLEX', :configuration => ['Debug']

  target 'AnyTimeTests' do
    inherit! :search_paths
    # Pods for testing
  end
end
