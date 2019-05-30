//
//  ViewController.swift
//  Slackbot
//
//  Created by Heejung Yang on 30/05/2019.
//  Copyright © 2019 Knowre. All rights reserved.
//

import UIKit
import SlackKit
import StorageManager

class ViewController: UIViewController {

    let bot = SlackKit()
    let token: String = "xoxb-638614531538-651872418503-L4MSggpPKJGHtVutMIX0ZNWq"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let slackbot = Bob(token: token)
        RunLoop.main.run()
    }


}

class Bob {

    let bot: SlackKit
    let menuManager = MenuManager()
    
    init(token: String) {
        bot = SlackKit()
        bot.addRTMBotWithAPIToken(token)
        bot.addWebAPIAccessWithToken(token)
        bot.notificationForEvent(.message) { [weak self] (event, client) in
            guard let message = event.message else { return }
            self?.handleMessage(message)
        }
    }
    
    func handleMessage(_ message: Message) {
        if let text = message.text, let channel = message.channel {
            if text.starts(with: "점심") {
                let selectedMenu = menuManager.find()
                let attachments = Attachment(attachment: ["title": "오늘은 어디갈까?!", "color": "#FFBB00","text": selectedMenu])
                bot.webAPI? .sendMessage(channel: channel, text: "두둥!!", attachments: [attachments], success: nil, failure: nil)
                return
            } else if text.starts(with: "등록"), text.count > 2 {
                let menu = String(text.split(separator: " ")[1])
                guard !menuManager.isExist(menu) else {
                    bot.webAPI?.sendMessage(channel: channel, text: "이미 존재하는 메뉴입니다.", success: nil, failure: nil)
                    return
                }
                menuManager.store(menu)
                bot.webAPI?.sendMessage(channel: channel, text: "\(menu) 추가 완료!", success: nil, failure: nil)
                return
            }
            
        }
       
    }
    
}

class MenuManager {
    
    private let fileName: String = "sample"
    
    func isExist(_ foodName: String) -> Bool {
        do {
            let foods: [String] = try StorageManager.default.arrayValue(fileName)
            guard foods.contains(foodName) else {
                return false
            }
             print(foods)
        } catch {
            print("Error: isExist")
        }
       
        return true
    }
    
    func store(_ foodName: String) {
        do {
            try StorageManager.default.append(foodName, in: fileName) 
        } catch {
            print("Error: store")
        }
    }
    
    func find() -> String {
        do {
            let foods: [String] = try StorageManager.default.arrayValue(fileName)
            let randomIndex = Int.random(in: 0..<foods.count)
            return foods[randomIndex]
        } catch {
            print("Error: find")
        }
        return "데이터 없음"
    }
}
