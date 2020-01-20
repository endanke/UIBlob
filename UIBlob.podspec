Pod::Spec.new do |spec|
  spec.name         = "UIBlob"
  spec.version      = "0.0.5"
  spec.summary      = "UIBlob"
  spec.requires_arc = true
  spec.homepage     = "https://github.com/endanke/UIBlob"
  spec.license      = { :type => 'MIT' }
  spec.author       = { "Daniel Eke" => "hello@ekedaniel.hu" }
  spec.source       = { :git => 'https://github.com/endanke/UIBlob.git', :tag => spec.version.to_s }
  spec.platform         = :ios
  spec.swift_version    = '4.2'
  spec.ios.deployment_target = '9.0'
  spec.source_files     = 'UIBlob/*{.h,.swift}'
end