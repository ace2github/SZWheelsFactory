Pod::Spec.new do |s|
  s.name         = "SZWheels"
  s.version      = "0.0.1"
  s.summary      = "SZWheels"

  s.description  = <<-DESC
    SZWheels轮子仓库，收藏评审自己开发的轮子
                   DESC

  s.homepage     = "https://github.com/ace2github/SZWheelsFactory"
  s.license      = 'MIT'

  s.author             = { "ChaohuiChen" => "173141667@qq.com" }

  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/ace2github/SZWheelsFactory.git", :tag => s.version }

  s.default_subspec='All'

  s.subspec 'InitDataChain' do |ss|
      ss.source_files = 'SZWheels/InitDataChain/**/*'
      ss.dependency 'SZCategories'
  end

  s.subspec 'All' do |ss|
     ss.dependency 'SZWheels/InitDataChain'
  end

end
