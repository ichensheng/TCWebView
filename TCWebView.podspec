Pod::Spec.new do |s|
  s.name         = "TCWebView"
  s.version      = "0.1.0"
  s.summary      = "App内嵌浏览器"
  s.homepage     = "https://github.com/ichensheng/TCWebView"
  s.license      = "MIT"
  s.author             = { "ichensheng" => "cs200521@163.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/ichensheng/TCWebView.git", :tag => "0.1.0" }
  s.source_files  = "TCWebView/Classes/**/*.{h,m}"
	s.resources 	 = "TCWebView/Classes/**/*.bundle"
  s.requires_arc = true
  s.dependency "NJKWebViewProgress", "0.2.3"
	s.dependency "Masonry", "~> 1.0.0"
	s.dependency "TCCategories", "~> 0.1.1"
end
