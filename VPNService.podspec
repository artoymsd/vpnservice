Pod::Spec.new do |spec|

  spec.name         = "VPNService"
  spec.version      = "1.0.1"
  spec.summary      = "A short description of VPNService."

  spec.description  = <<-DESC
  A lib for establish VPN connection
                   DESC

  spec.homepage     = "https://github.com/artoymsd/vpnservice"

  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  spec.author       = { "Artem Sidorenko" => "artoymsd@gmail.com" }

  spec.swift_version   = "5.0"

  spec.platform     = :ios, "10.0"
  spec.ios.deployment_target = "10.0"
  
  spec.source       = { :git => "git@github.com:artoymsd/vpnservice.git", :tag => "#{spec.version}" }

  spec.source_files  = "VPNService"

  spec.framework  = "NetworkExtension"
end
