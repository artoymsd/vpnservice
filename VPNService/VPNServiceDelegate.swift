//
//  VPNServiceDelegate.swift
//  StarVPN-New
//
//  Created by Artem Sidorenko on 18/01/2019.
//  Copyright © 2019 Artem Sidorenko. All rights reserved.
//

import Foundation

public protocol VPNServiceDelegate: class {
  func connecting()
  func connected()
  func disconnecting()
  func disconnected()
  func reasserting()
  func invalid()
}

extension VPNServiceDelegate {
  func reasserting() {}
  func invalid() {}
}
