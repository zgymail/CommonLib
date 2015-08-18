Pod::Spec.new do |s|
  s.name         = 'CommonLib'
  s.version      = '0.2.0'
  s.summary      = 'CommonLib by all project'
  s.description  = <<-DESC
                   CommonLib by all project,desc
                   DESC
  s.homepage     = 'http://www.baidu.cn'
  s.license      = 'MIT'
  s.author             = {'zgy_mail' => 'zgy_mail@126.com' }
  s.platform     = :ios,'7.0'
  s.source       =  { :git => 'https://github.com/zgymail/CommonLib.git', :tag => '0.2.0' }
  s.requires_arc = true
  s.subspec 'Base' do |ds|
    ds.frameworks = 'UIKit', 'Foundation','CoreGraphics'
    ds.libraries = 'z', 'xml2'
    ds.source_files = 'Base/*.{h,m,mm}','Base/**/*.{h,m,mm}'
    ds.dependency 'ZipArchive', '~> 1.4.0'
    ds.dependency 'ProtocolBuffers', '~> 1.9.7'
    ds.dependency 'Reachability'
    ds.dependency 'AFNetworking','~>2.5.4'
    ds.dependency 'KeychainItemWrapper','~> 1.2'
  end

  s.subspec 'SpriteKit' do |ds|
    ds.framework = 'SpriteKit'
    ds.dependency 'CommonLib/Base'
    ds.source_files ='SpriteKit/*.{h,m,mm}'
  end

  # s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
end
