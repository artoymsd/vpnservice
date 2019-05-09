//
//  VPNConfig.swift
//  StarVPN-New
//
//  Created by Artem Sidorenko on 18/01/2019.
//  Copyright © 2019 Artem Sidorenko. All rights reserved.
//

import Foundation

public struct VPNConfig {
    
    var serverAddress: String
    var username: String
    var password: Data
    var groupName: String
    var sharedSecret: Data
    
    public init(serverAddress: String, username: String, password: Data, groupName: String, sharedSecret: Data) {
        self.serverAddress = serverAddress
        self.username = username
        self.password = password
        self.groupName = groupName
        self.sharedSecret = sharedSecret
    }
    
}
