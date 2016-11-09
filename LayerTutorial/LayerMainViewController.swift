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
    
    @IBAction func pushedClear(_ sender: Any) {
        print("TODO: Implement pushedClear")
    }

}

extension LayerMainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("TODO: Implement numberOfRowsInSection")
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
        print("TODO: Implement configureCell")
        cell.messageLabel.text = "Hello World"
        cell.deviceLabel.text = "Platform @ 32142314235"
    }
    
}

extension LayerMainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("TODO: Implement heightForRowAt")
        return 70
    }
}

extension LayerMainViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("TODO: Implement textViewDidBeginEditing")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("TODO: Implement textViewDidEndEditing")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("TODO: Implement textView shouldChangeTextIn range")
        return false
    }
    
    func moveViewUpToShowKeyboard(_ movedUp: Bool) {
        print("TODO: Implement moveViewUpToShowKeyboard")
    }
}
