Pod::Spec.new do |s|
  s.name         = "WANetworkRouting"
  s.version      = "1.0.0"
  s.summary      = "A routing library to fetch objects from an API and map them to your app"
  s.homepage     = "https://github.com/Wasappli/WANetworkRouting"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Marian Paul" => "marian@wasapp.li" }
  s.ios.deployment_target = "7.0"
  s.watchos.deployment_target = "2.0"
  s.source       = { :git => "https://github.com/Wasappli/WANetworkRouting.git", :tag => "1.0.0" }
  s.source_files = "Files/*.{h,m}"
  s.requires_arc = true
  s.dependency   'AFNetworking', '~> 3.1'
  s.dependency   'WAMapping', '~> 0.0.7'
end
