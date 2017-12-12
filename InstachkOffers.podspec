Pod::Spec.new do |s|
  s.name             = 'InstachkOffers'
  s.version          = '0.1.1'
  s.summary          = 'Instachk SDK to render nearby offers'
  s.description      = <<-DESC
Instachk offers SDK lets you display nearby offers
                       DESC

  s.homepage         = 'https://github.com/instachk/ios-offers-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'InstaChk' => 'contact@instachk.today' }
  s.source           = { :git => 'https://github.com/instachk/ios-offers-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.3'

  s.source_files = 'InstachkOffers/Classes/**/*'
  
  s.resource_bundles = {
    'InstachkOffers' => ['InstachkOffers/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Starscream', '~> 2.0.3'
end
