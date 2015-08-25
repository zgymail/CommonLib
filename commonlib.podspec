Pod::Spec.new do |s|
  s.name         = 'CommonLib'
  s.version      = '0.2.4'
  s.summary      = 'CommonLib by all project'
  s.description  = <<-DESC
                   CommonLib by all project,desc
                   DESC
  s.homepage     = 'https://github.com/zgymail/CommonLib/wiki'
  s.license      = 'MIT'
  s.author             = {'zgy_mail' => 'zgy_mail@126.com' }
  s.platform     = :ios,'7.0'
  s.source       =  { :git => 'https://github.com/zgymail/CommonLib.git', :tag => "#{s.version}" }
  s.requires_arc = true
  s.subspec 'Base' do |ds|
    ds.dependency 'Reachability'
    ds.dependency 'AFNetworking','~>2.5.4'
    ds.frameworks = 'UIKit', 'Foundation','CoreGraphics'
    ds.libraries = 'z', 'xml2'
    ds.source_files = 'Base/*.{h,m,mm}','Base/**/*.{h,m,mm}'
  end

  s.subspec 'SpriteKit' do |ds|
    ds.dependency 'ProtocolBuffers', '~> 1.9.7'
    ds.dependency 'ZipArchive', '~> 1.4.0'
    ds.dependency 'CommonLib/Base'
    ds.framework = 'SpriteKit','UIKit', 'Foundation','CoreGraphics'
    ds.libraries = 'z', 'xml2'
    ds.source_files ='SpriteKit/*.{h,m,mm}','SpriteKit/**/*.{h,m,mm}'
  end
end
