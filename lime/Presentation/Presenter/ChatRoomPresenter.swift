//
//  ChatRoomPresenter.swift
//  lime
//
//  Created by 下村一将 on 2017/10/26.
//  Copyright © 2017 kazu. All rights reserved.
//

import Foundation
import RxSwift
import SkyWay

protocol ChatRoomPresenter {
	func loadChatRoom(index: Int)
	func sendMessage(message: String)
	func viewWillDisappear()
	func callButtonTapped()
	func setStream(local: SKWVideo, remote: SKWVideo)
}

class ChatRoomPresenterImpl: ChatRoomPresenter {
	weak var viewInput: ChatRoomViewInput?
	let wireframe: ChatRoomWireframe
	let useCase: ChatRoomUseCase
	
	fileprivate let disposeBag = DisposeBag()
	var chatRoomModel: ChatRoomModel?
	
	public required init(viewInput: ChatRoomViewInput, wireframe: ChatRoomWireframe, useCase: ChatRoomUseCase) {
		self.viewInput = viewInput
		self.useCase = useCase
		self.wireframe = wireframe
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	func loadChatRoom(index: Int) {
		useCase.loadChatRoom(index: index)
			.subscribe(
				onNext: { [weak self] cml in
					self?.chatRoomModel = cml
					// Notice: chatRoomModelのラベルがないと'extra argument onerror in call'が出るぞ
					self?.loadedChatRoom(chatRoomModel: cml)
					//Todo
					self?.wireframe.viewController?.title = self?.chatRoomModel?.userScreenName
				}, onError: {
					print($0)
			}, onCompleted: nil, onDisposed: nil
			)
			.disposed(by: disposeBag)
	}
	
	func sendMessage(message: String) {
		self.wireframe.viewController?.bottomView.chatTextField.text = ""
		let date = Date()
		let calendar = Calendar.current
		
		let myUUID = UIDevice.current.identifierForVendor?.uuidString ?? ""
		
		self.useCase.sendChat(chat:
			ChatEntity(text: message,
					   time: "\(calendar.component(.hour, from: date)):\(calendar.component(.minute, from: date))",
				chatRoomId: self.chatRoomModel!.id, uuid: myUUID))
			.subscribe(
				onNext: { [weak self] chatRoom in
					self?.loadedChatRoom(chatRoomModel: chatRoom)
				}
			)
			.disposed(by: self.disposeBag)
		

		
//		var accountEntity: AccountEntity?
//		useCase.getAccountInfo()
//			.subscribe(onNext: { ae in
//				accountEntity = ae
//
//
//			})
//			.disposed(by: disposeBag)
	}
	
	func viewWillDisappear() {
		useCase.viewWillDisappear()
	}
	
	func callButtonTapped() {
		useCase.callButtonTapped()
	}
	
	func setStream(local: SKWVideo, remote: SKWVideo) {
		useCase.setStream(local: local, remote: remote)
	}
}

extension ChatRoomPresenterImpl {
	fileprivate func loadedChatRoom(chatRoomModel: ChatRoomModel) {
		self.viewInput?.setChatRoom(chatRoomModel)
	}
	
	@objc func keyboardWillShow(notification: Notification) {
		if let userInfo = notification.userInfo {
			if let keyboardFrameInfo = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
				
				if keyboardFrameInfo.cgRectValue.height <= 70 {
					return
				}
				
				self.wireframe.viewController?.tableViewButtomConstraint.constant = keyboardFrameInfo.cgRectValue.height - 35
				if let vc = self.wireframe.viewController {
					if vc.chats.count > 0 {
						let indexPath = IndexPath(row: vc.chats.count-1, section: 0)
						DispatchQueue.main.async {
							vc.tableView.scrollToRow( at: indexPath, at: .bottom, animated: true)
						}
					}
				}
			}
		}
	}
	
	@objc func keyboardWillHide(notification: Notification) {
		self.wireframe.viewController?.tableViewButtomConstraint.constant = 35
	}
}
