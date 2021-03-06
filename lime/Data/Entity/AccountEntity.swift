//
//  AccountEntity.swift
//  lime
//
//  Created by 下村一将 on 2017/11/13.
//  Copyright © 2017年 kazu. All rights reserved.
//

import Foundation
import Unbox

public struct AccountEntity: Unboxable {
	var userId: Int
	var uuid: String
	
	public init(unboxer: Unboxer) throws {
		userId = try unboxer.unbox(key: "user-id")
		uuid = try unboxer.unbox(key: "uuid")
	}
	
	init(userId:Int, uuid: String) {
		self.userId = userId
		self.uuid = uuid
	}
}
