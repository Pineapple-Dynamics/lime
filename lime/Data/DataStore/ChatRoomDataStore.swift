//
//  ChatRoomDataStore.swift
//  lime
//
//  Created by 下村一将 on 2017/10/26.
//  Copyright © 2017 kazu. All rights reserved.
//

import RxSwift

public protocol ChatRoomDataStore {
	func getChatRoom(index: Int) -> Observable<ChatRoomEntity>
	func sendChat(chat: ChatEntity) -> Observable<ChatRoomEntity>
}

class ChatRoomDataStoreImpl: ChatRoomDataStore {
//	var chatRoom: ChatRoomEntity
	let api = LimeAPI()
	let disposeBag = DisposeBag()
	
	var chatRooms: [ChatRoomEntity] = []
	var index = 1
	init() {
		var chats: [ChatEntity] = []
		chats.append(ChatEntity(text: "今何してる？", time: "12:23", chatRoomId: 0, speakerId: 10))
		chats.append(ChatEntity(text: "本読んでたよ〜", time: "12:33", chatRoomId: 0, speakerId: 2))
		chats.append(ChatEntity(text: """
この本まじ面白くて、
読み出すと本当止まらないんだよね笑
今度かそっか？😉
""", time: "12:33", chatRoomId: 0, speakerId: 2))
		//		for i in 1...10000 {
		//			chats.append(ChatEntity(text: "りぷらい\(i)", time: "12:33", chatRoomId: 0, speakerId: 2))
		//			chats.append(ChatEntity(text: "じぶんのちゃっと\(i)", time: "12:33", chatRoomId: 0, speakerId: 10))
		//		}
		chats.append(ChatEntity(text: "いっつも本読んでるね", time: "12:43", chatRoomId: 0, speakerId: 10))
		
		let friend = UserEntity(userId: "userId", screenName: "たろー", name: "name", statusText: "nemui")
		chatRooms.append(ChatRoomEntity(id: 1, friend: friend, currentText: "currentTxt", chats: chats))
		let friend2 = UserEntity(userId: "userId", screenName: "対話BOT", name: "name", statusText: "nemui")
		chatRooms.append(ChatRoomEntity(id: 2, friend: friend2, currentText: "currentTxt", chats: []))
	}
	
	func getChatRoom(index: Int) -> Observable<ChatRoomEntity> {
		self.index = index
		return Observable.create({ (observer) -> Disposable in
			observer.onNext(self.chatRooms[index])
			
//			var count = 0
//			Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
//				
//				if !timer.isValid {
//					timer.fire()
//				}
//				self.chatRoom.chats.append(ChatEntity(text: "じぶんのテキスト", time: "12:33", chatRoomId: 0, speakerId: 10))
//				self.chatRoom.chats.append(ChatEntity(text: "あいてのテキスト", time: "12:33", chatRoomId: 0, speakerId: 2))
//				observer.onNext(self.chatRoom)
//				count += 1
//			})
			
			return Disposables.create()
		})
	}
	
	
	func sendChat(chat: ChatEntity) -> Observable<ChatRoomEntity> {
		return Observable.create( {observer in
			self.chatRooms[self.index].chats.append(chat)
			observer.onNext(self.chatRooms[self.index])
			
// サーバに送信
//			self.api.send(LimeAPI.ChatSendRequest(chat: chat))
//				.subscribe{print($0)}
//				.disposed(by: self.disposeBag)
			
			if self.index==1{
				//返信ボット
				ChatAPI().sendChat(chatText: chat.text)
					.subscribe(onNext: { str in
						let reply = ChatEntity(text: str, time: chat.time, chatRoomId: chat.chatRoomId, speakerId: 2)
						self.chatRooms[self.index].chats.append(reply)
						
						observer.onNext(self.chatRooms[self.index])
					})
					.disposed(by: self.disposeBag)
			} else if self.index==0 {
				
			}
			
			return Disposables.create()
		})
	}
}
