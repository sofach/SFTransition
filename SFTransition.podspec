Pod::Spec.new do |s|

  s.name         = "SFTransition"
  s.version      = "1.0.0"
  s.summary      = "custom transition animation"

  s.description  = <<-DESC
                   custom transition animation, implement by category
                   DESC

  s.homepage     = "https://github.com/sofach/SFTransition"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  s.author             = { "sofach" => "sofach@126.com" }

  s.platform     = :ios
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/sofach/SFTransition.git", :tag => "1.0.0" }

  s.source_files  = "SFTransition/lib/*.{h,m}"

  s.requires_arc = true

end
