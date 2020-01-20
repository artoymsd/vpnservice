//
//  VPNService.swift
//
//  Created by Artem Sidorenko on 18/01/2019.
//  Copyright © 2019 Artem Sidorenko. All rights reserved.
//

import Foundation
import NetworkExtension

public final class VPNService: IVPNService {
  
  weak public var delegate: VPNServiceDelegate?
  var vpnManager: NEVPNManager
  
  public var currentVPNState: NEVPNStatus {
    return vpnManager.connection.status
  }
  
  public init(vpnManager: NEVPNManager) {
    self.vpnManager = vpnManager
    vpnManager.loadFromPreferences { _ in }
    NotificationCenter.default.addObserver(self, selector: #selector(vpnStatusDidChange(_:)), name: .NEVPNStatusDidChange, object: nil)
  }
  
  public init() {
    self.vpnManager = NEVPNManager.shared()
    vpnManager.loadFromPreferences { _ in }
    NotificationCenter.default.addObserver(self, selector: #selector(vpnStatusDidChange(_:)), name: .NEVPNStatusDidChange, object: nil)
  }
  
  public func connect(vpnConfig: VPNConfig, completion: @escaping(Error?) -> Void) {
    guard vpnManager.connection.status != .connected, vpnManager.connection.status != .connecting else {return}
    
    vpnManager.loadFromPreferences { loadError in
      if loadError == nil {
        self.saveVPNPreference(vpnConfig: vpnConfig) { saveError in
          if saveError == nil {
            self.vpnManager.loadFromPreferences { error in
              if error == nil {
                do {
                  try self.vpnManager.connection.startVPNTunnel()
                  completion(nil)
                } catch NEVPNError.configurationInvalid {
                  //TODO
                } catch NEVPNError.configurationDisabled {
                  //TODO
                } catch let connectionError {
                  NSLog("NEVPNManager error \(connectionError)")
                  completion(connectionError)
                }
              } else {
                completion(error)
              }
            }
          } else {
            completion(saveError)
          }
        }
      } else {
        completion(loadError)
      }
    }
  }
  
  public func disconnect(completion: @escaping (Error?) -> Void) {
    guard vpnManager.connection.status != .disconnected, vpnManager.connection.status != .disconnecting else {return}
    self.vpnManager.isOnDemandEnabled = false
    
    self.vpnManager.saveToPreferences { error in
      if error == nil {
        self.vpnManager.connection.stopVPNTunnel()
      }
      completion(error)
    }
  }
  
  public func removeProfile(completion: @escaping (Error?) -> Void) {
    vpnManager.removeFromPreferences { (error) in
      completion(error)
    }
  }
  
  public func vpnProtocol(completion: @escaping (NEVPNProtocol?) -> Void) {
    vpnManager.loadFromPreferences { error in
      completion(self.vpnManager.protocolConfiguration)
    }
  }
  
  public func vpnConnectedDate(completion: @escaping (Date?) -> Void) {
    vpnManager.loadFromPreferences { (error) in
      completion(self.vpnManager.connection.connectedDate)
    }
  }
  
  @objc func vpnStatusDidChange(_ notification: Notification) {
    let vpnStatus = vpnManager.connection.status
    switch vpnStatus {
      
    case .connecting:
      delegate?.connecting()
      
    case .connected:
      let connectRule = NEOnDemandRuleConnect()
      connectRule.interfaceTypeMatch = .any
      
      self.vpnManager.onDemandRules = [connectRule]
      self.vpnManager.isOnDemandEnabled = true
      self.vpnManager.isEnabled = true
      self.vpnManager.saveToPreferences { _ in}
      
      delegate?.connected()
      
    case .disconnecting:
      delegate?.disconnecting()
      
    case .disconnected:
      self.vpnManager.isEnabled = false
      delegate?.disconnected()
      
    case .reasserting:
      delegate?.reasserting()
      
    case .invalid:
      delegate?.invalid()
    @unknown default:
      break
    }
  }
  
  fileprivate func saveVPNPreference(vpnConfig: VPNConfig, completion: @escaping(Error?) -> Void) {
    let newProtocol = NEVPNProtocolIPSec()
    
    newProtocol.serverAddress             = vpnConfig.serverAddress
    newProtocol.authenticationMethod      = NEVPNIKEAuthenticationMethod.sharedSecret
    newProtocol.sharedSecretReference     = vpnConfig.sharedSecret
    newProtocol.username                  = vpnConfig.username
    newProtocol.passwordReference         = vpnConfig.password
    newProtocol.useExtendedAuthentication = true
    newProtocol.disconnectOnSleep         = false
    
    self.vpnManager.protocolConfiguration = newProtocol
    self.vpnManager.isEnabled = true
    self.vpnManager.saveToPreferences { error in
      if error == nil {
        completion(nil)
      } else {
        completion(error)
      }
    }
  }
  
  fileprivate func deleteConfiguration(completion: @escaping(Error?) -> Void) {
    self.vpnManager.removeFromPreferences { removeError in
      if removeError == nil {
        completion(nil)
      } else {
        completion(removeError)
      }
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: .NEVPNStatusDidChange, object: nil)
  }
}
