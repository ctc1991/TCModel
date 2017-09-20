Pod::Spec.new do |s|
  s.name         = "TCModel"
  s.version      = "1.0.0"
  s.summary      = "ctc's model."
  s.description  = <<-DESC
  A class to handle json and model.
                   DESC

  s.homepage     = "https://github.com/ctc1991/TCModel"
  s.license      = "MIT"
  s.author       = { "ctc" => "ctc1991@foxmail.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/ctc1991/TCModel.git", :tag => s.version.to_s} 
  s.source_files = 'TCModel/**/*'
  s.framework = "Foundation"
  s.requires_arc = true
end
