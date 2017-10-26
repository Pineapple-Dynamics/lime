//
//  ChatRoomListModel.swift
//  lime
//
//  Created by 下村一将 on 2017/10/21.
//  Copyright © 2017 kazu. All rights reserved.
//

import Foundation

struct ChatRoomListModel {
	var chatRoomList: [ChatRoomModel] = []
}

struct ChatRoomModel: ChatRoomViewModel {
	var userScreenName: String
	var date: String
	var currentText: String
	var chats: [ChatEntity]
	
	init(chatRoomModel: ChatRoomEntity) {
		self.currentText = chatRoomModel.currentText
		// Todo:
		self.date = "Today"
		self.userScreenName = chatRoomModel.friend.screenName
		self.chats = chatRoomModel.chats
	}
}

struct ChatsModel {
	
}
