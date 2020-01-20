//
//  IVPNService.swift
//
//  Created by Artem Sidorenko on 18/01/2019.
//  Copyright © 2019 Artem Sidorenko. All rights reserved.
//

import Foundation
import NetworkExtension

public protocol IVPNService: class {
  
  var delegate: VPNServiceDelegate? { get set }
  var currentVPNState: NEVPNStatus { get }
  
  func connect(vpnConfig: VPNConfig, completion: @escaping(Error?) -> Void)
  func disconnect(completion: @escaping(Error?) -> Void)
  
  func removeProfile(completion: @escaping (Error?) -> Void)
  func vpnProtocol(completion: @escaping (NEVPNProtocol?) -> Void)
  
  func vpnConnectedDate(completion: @escaping (Date?) -> Void)
}
