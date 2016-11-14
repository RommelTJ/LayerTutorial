//
//  LayerMainViewController.swift
//  LayerTutorial
//
//  Created by Rommel Rico on 11/7/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import LayerKit

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

let KeyboardHeight: CGFloat = 255.0
let MaxCharacterLimit = 66
let MIMETypeImagePNG = "image/png"

class LayerMainViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: LayerMainViewController Properties
    var layerClient: LYRClient?
    var conversation: LYRConversation?
    var queryController: LYRQueryController?
    var sendingImage: Bool = false
    var photo: UIImage? //this is where the selected photo will be stored
    
    @IBOutlet weak var typingIndicatorLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var dateFormatter: DateFormatter {
        struct Static {
            static let instance : DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                return formatter
            }()
        }
        return Static.instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: IBActions
    
    @IBAction func pushedSend(_ sender: Any) {
        print("PUSHED SEND")
        // Send Message
        sendMessage(messageTextView.text)
        
        // Lower the keyboard
        moveViewUpToShowKeyboard(false)
        messageTextView.resignFirstResponder()
    }
    
    @IBAction func pushedCamera(_ sender: Any) {
        messageTextView.text = ""
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func pushedClear(_ sender: Any) {
        let alert = UIAlertController(title: "Delete message?", message: "This action will clear all your current messages. Are you sure you want to do this?", preferredStyle: .alert)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.clearMessages()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true) {
            self.tableView.reloadData()
        }
    }
    
    func sendMessage(_ messageText: String) {
        // Send a message
        var messagePart: LYRMessagePart?
        messageImage.image = nil
        
        // If no conversations exist, create a new conversation object with a single participant
        if self.conversation == nil {
            fetchLayerConversation()
        }
        
        // If we are sending an image
        if (sendingImage) {
            let image: UIImage = self.photo! //get photo
            let imageData: Data = UIImagePNGRepresentation(image)!
            messagePart = LYRMessagePart(mimeType: MIMETypeImagePNG, data: imageData)
            sendingImage = false
        } else {
            //Creates a message part with text/plain MIME Type
            messagePart = LYRMessagePart(text: messageText)
        }
        
        // Creates and returns a new message object with the given conversation and array of message parts
        let message: LYRMessage?
        do {
            message = try layerClient!.newMessage(with: [messagePart!], options: nil)
        } catch let error as NSError {
            print("Error creating the new message object in sendMessage: \(error.localizedDescription).")
            message = nil
        }
        
        // Sends the specified message
        var error: NSError?
        let success: Bool
        do {
            try conversation!.send(message!)
            success = true
        } catch let error1 as NSError {
            error = error1
            success = false
        }
        if success {
            // If the message was sent by the participant, show the sentAt time and mark the message as read
            print("Message queued to be sent: \(messageText)")
            messageTextView.text = ""
            
        } else {
            print("Message send failed: \(error)")
        }
        self.photo = nil
        
        if queryController == nil {
            setupQueryController()
        }
    }
    
    // MARK:- Fetching Layer Content
    
    func fetchLayerConversation() {
        // Fetches all conversations between the authenticated user and the supplied participant
        
        let query: LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
        query.predicate = LYRPredicate(property: "participants", predicateOperator: LYRPredicateOperator.isEqualTo, value: [ LQSCurrentUserID, LQSParticipantUserID, LQSParticipant2UserID ] as AnyObject)
        query.sortDescriptors = [ NSSortDescriptor(key: "createdAt", ascending: false) ]
        
        var error: Error? = nil
        var conversations: NSOrderedSet?
        do {
            conversations = try layerClient?.execute(query)
        } catch let error1 as NSError {
            error = error1
            conversations = nil
        }
        
        if conversations == nil || conversations!.count <= 0 {
            var convError: NSError? = nil
            do {
                let participants: Set<String> = Set([LQSParticipantUserID, LQSParticipant2UserID])
                self.conversation = try layerClient!.newConversation(withParticipants: participants, options: nil)
            } catch let error as NSError {
                convError = error
                self.conversation = nil
            }
            if self.conversation == nil {
                print("New Conversation creation failed: \(convError)")
            }
        }
        
        if error == nil {
            print("\(conversations!.count) conversations with participants \([LQSCurrentUserID, LQSParticipantUserID, LQSParticipant2UserID])")
        } else {
            print("Query failed with error \(error)")
        }
        
        
        // Retrieve the last conversation
        if conversations != nil && conversations!.count > 0 {
            self.conversation = conversations!.lastObject as! LYRConversation?
            print("Get last conversation object: \(conversation!.identifier)")
            // setup query controller with messages from last conversation
            if queryController == nil {
                setupQueryController()
            }
        }
    }
    
    func setupQueryController() {
        // Query for all the messages in conversation sorted by position
        let query: LYRQuery = LYRQuery(queryableClass: LYRMessage.self)
        query.predicate = LYRPredicate(property: "conversation", predicateOperator: LYRPredicateOperator.isEqualTo, value: self.conversation)
        query.sortDescriptors = [ NSSortDescriptor(key: "position", ascending: true) ]
        
        // Set up query controller
        do {
            queryController = try layerClient!.queryController(with: query)
            queryController!.delegate = self
        } catch let error as NSError {
            print("Error setting up query controller: \(error.localizedDescription).")
        }
        
        var error: NSError?
        let success: Bool
        do {
            try queryController!.execute()
            success = true
        } catch let error1 as NSError {
            error = error1
            success = false
        }
        if success {
            print("Query fetched \(queryController!.numberOfObjects(inSection: 0)) message objects")
        } else {
            print("Query failed with error: \(error)")
        }
        
        tableView.reloadData()
        do {
            try conversation!.markAllMessagesAsRead()
        } catch _ {
            print("Could not mark all messages as read")
        }
    }
    
    // MARK: Helper Methods
    
    func scrollToBottom() {
        let messages: Int = numberOfMessages()
        
        if self.conversation != nil && messages > 0 {
            let numberOfRowsInSection = tableView.numberOfRows(inSection: 0)
            if numberOfRowsInSection > 0 {
                let ip: IndexPath = IndexPath(row: numberOfRowsInSection - 1, section: 0)
                tableView.scrollToRow(at: ip, at: UITableViewScrollPosition.top, animated: true)
            }
        }
    }
    
    func setNavbarColorFromConversationMetadata(_ metadata: NSDictionary?) {
        // For more information about Metadata, check out https://developer.layer.com/docs/integration/ios#metadata
        if let metadata = metadata as? [String : CGFloat] {
            
            if metadata[BackgroundColorMetadata.Key.rawValue] == nil {
                return
            }
            let redColor: CGFloat = metadata[BackgroundColorMetadata.Red.rawValue]! as CGFloat
            let blueColor: CGFloat = metadata[BackgroundColorMetadata.Blue.rawValue]! as CGFloat
            let greenColor: CGFloat = metadata[BackgroundColorMetadata.Green.rawValue]! as CGFloat
            navigationController!.navigationBar.barTintColor = UIColor(red: redColor, green: greenColor, blue: blueColor, alpha: 1.0)
        }
    }
    
    func numberOfMessages() -> Int {
        let message: LYRQuery = LYRQuery(queryableClass: LYRMessage.self)
        
        let messageList: NSOrderedSet?
        do {
            messageList = try layerClient?.execute(message)
        } catch _ {
            messageList = nil
        }
        
        return messageList != nil ? messageList!.count : 0
    }
    
    func clearMessages() {
        let message: LYRQuery = LYRQuery(queryableClass: LYRMessage.self)
        
        let messageList: NSOrderedSet?
        do {
            messageList = try layerClient!.execute(message)
        } catch _ {
            messageList = nil
        }
        
        if (messageList?.count)! > 0 {
            
            for obj in messageList! {
                let message: LYRMessage = obj as! LYRMessage
                
                // Deletes a conversation
                var error: NSError? = nil
                let success = message.delete(.allParticipants, error: &error)
                print("Message is: \(message.parts)")
                
                if success {
                    print("The message has been deleted")
                }else {
                    print("Error")
                }
            }
            
            
        }
        photo = nil
        sendingImage = false
    }
    
}

extension LayerMainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return number of objects in queryController
        if queryController == nil {
            return 0
        }
        let rows = queryController!.numberOfObjects(inSection: UInt(0))
        print("Rows \(rows)")
        return Int(rows)
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
        // Get Message Object from queryController
        let message = queryController!.object(at: indexPath) as? LYRMessage
        let messagePart: LYRMessagePart = message!.parts[0] 
        
        //If it is type image
        if messagePart.mimeType == "image/png" {
            cell.messageLabel.text = "";
            if messagePart.data != nil {
                cell.updateWithImage(image: UIImage(data: messagePart.data!)!)
            }
            
        } else {
            cell.removeImage() //just a safegaurd to ensure  that no image is present
            cell.assignText(text: NSString(data: messagePart.data!, encoding: String.Encoding.utf8.rawValue) as! String)
        }
        var timestampText = ""
        
        // If the message was sent by current user, show Receipent Status Indicator
        if message!.sender.userID == LQSCurrentUserID {
            switch message!.recipientStatus(forUserID: LQSParticipantUserID) {
            case LYRRecipientStatus.sent:
                cell.messageStatus.image = UIImage(named: MessageStateImage.Sent.rawValue)
                timestampText = "Sent: \(dateFormatter.string(from: message!.sentAt!))"
            case LYRRecipientStatus.delivered:
                cell.messageStatus.image = UIImage(named: MessageStateImage.Delivered.rawValue)
                timestampText = "Delivered: \(dateFormatter.string(from: message!.sentAt!))"
            case LYRRecipientStatus.read:
                cell.messageStatus.image = UIImage(named: MessageStateImage.Read.rawValue)
                timestampText = "Read: \(dateFormatter.string(from: message!.receivedAt!))"
            case LYRRecipientStatus.invalid:
                print("Participant: Invalid")
            default:
                break
            }
        } else {
            do {
                try message!.markAsRead()
            } catch let error {
                print("Could not read message and mark as read: \(error.localizedDescription).")
            }
            timestampText = "Received: \(dateFormatter.string(from: message!.sentAt!))"
        }
        
        if message!.sender.userID != nil {
            cell.deviceLabel.text = "\(message!.sender.userID) @ \(timestampText)"
        }else {
            cell.deviceLabel.text = "Platform @ \(timestampText)"
        }
    }
    
}

extension LayerMainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = queryController?.object(at: indexPath) as! LYRMessage?
        if message == nil {
            return 70
        }
        let messagePart = message!.parts[0]
        
        //If it is type image
        if messagePart.mimeType == "image/png" {
            return 130
        } else {
            return 70
        }
    }
}

extension LayerMainViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Sends a typing indicator event to the given conversation.
        conversation?.sendTypingIndicator(LYRTypingIndicatorAction.begin)
        moveViewUpToShowKeyboard(true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        conversation?.sendTypingIndicator(LYRTypingIndicatorAction.finish)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            messageTextView.resignFirstResponder()
            moveViewUpToShowKeyboard(false)
            return false
        }
        
        let limit: Int = MaxCharacterLimit
        return !(messageTextView.text.characters.count > limit && text.characters.count > range.length)
    }
    
    func moveViewUpToShowKeyboard(_ movedUp: Bool) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        var rect: CGRect = view.frame
        if movedUp {
            if rect.origin.y == 0 {
                rect.origin.y = view.frame.origin.y - KeyboardHeight
            }
        } else {
            if rect.origin.y < 0 {
                rect.origin.y = view.frame.origin.y + KeyboardHeight
            }
        }
        view.frame = rect
        UIView.commitAnimations()
    }
}

extension LayerMainViewController: LYRQueryControllerDelegate {
    
    func queryControllerWillChangeContent(_ queryController: LYRQueryController) {
        tableView.beginUpdates()
    }
    
    func queryController(_ controller: LYRQueryController, didChange object: Any, at indexPath: IndexPath?, for type: LYRQueryControllerChangeType, newIndexPath: IndexPath?) {
        // Automatically update tableview when there are change events
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
            tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func queryControllerDidChangeContent(_ queryController: LYRQueryController) {
        tableView.endUpdates()
        scrollToBottom()
    }
}

extension LayerMainViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.sendingImage = true
        var image = info[UIImagePickerControllerEditedImage] as! UIImage!
        
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as! UIImage!
        }
        self.photo = image
        dismiss(animated: true, completion: nil)
        
        messageImage.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        self.sendingImage = false
    }
    
}
