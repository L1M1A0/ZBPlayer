#source 'https://github.com/CocoaPods/Specs.git'


#platform :macos, '10.9'

#target 'ZBPlayer' do
#  pod 'VLCKit', '3.3'
#end

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

# wcdb地址：https://github.com/Tencent/wcdb/wiki/Objc-%e5%ae%89%e8%a3%85%e4%b8%8e%e5%85%bc%e5%ae%b9%e6%80%a7
# VLCKit地址：https://github.com/videolan/vlckit

#注：注意每个平台需要的的最低仓库的版本，wcdb要求的最低版本是10.13
#注：更新版本仓库的cocopods代码参考wcdb主页：pod repo update，pod install --verbose
#注：VCLKit 只使用3.3版本，其他后续版本文件都太大了，使用pod update，更新仓库就不会更新此版本， 这样就可以提交到github（更小）。 若使用pod install等，更新之后再更新会来此版本，就会报错，到时需要使用更新版本的（主要是文件太大了，如果本地没有保留，则需要更新cocoapods等，比较花时间，不能直接下载就能用）

target 'ZBPlayer' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ZBPlayer
  
  platform :macos, '10.13'
  pod 'WCDB.objc', '2.1.8'
  pod 'VLCKit', '3.3'
  pod 'AFNetworking', '4.0'
  pod 'Masonry', '1.1'
end


