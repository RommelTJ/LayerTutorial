//
//  LayerMainViewController.swift
//  LayerTutorial
//
//  Created by Rommel Rico on 11/7/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit

enum BackgroundColorMetadata: String {
    case Key = "backgroundColor"
    case Red = "backgroundColor.red"
    case Blue = "backgroundColor.blue"
    case Green = "backgroundColor.green"
}

enum BackgroundColor: String {
    case Red = "red"
    case Blue = "blue"
    case Green = "green"
}

enum MessageStateImage: String {
    case Sent = "message-sent"
    case Delivered = "message-delivered"
    case Read = "message-read"
}

let LayerChatCellReuseIdentifier = "layerChatCell"

class LayerMainViewController: UIViewController {

    // MARK: LayerMainViewController Properties
    @IBOutlet weak var typingIndicatorLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pushedSend(_ sender: Any) {
        print("TODO: Implement pushedSend")
    }
    
    @IBAction func pushedCamera(_ sender: Any) {
        print("TODO: Implement pushedCamera")
    }

}

extension LayerMainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: LayerChatCellReuseIdentifier, for: indexPath) as? LayerChatCell
        
        if cell == nil {
            cell = LayerChatCell(style: UITableViewCellStyle.default, reuseIdentifier: LayerChatCellReuseIdentifier)
        }
        configureCell(cell!, forRowAtIndexPath: indexPath)
        
        return cell!
    }
    
    func configureCell(_ cell: LayerChatCell, forRowAtIndexPath indexPath: IndexPath) {
        // TODO: Implement this method for realz
        cell.messageLabel.text = "Hello World"
        cell.deviceLabel.text = "Platform @ 32142314235"
    }
    
}

extension LayerMainViewController: UITableViewDelegate {
    
}
