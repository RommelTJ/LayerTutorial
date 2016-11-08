
//
//  LayerChatCell.swift
//  LayerTutorial
//
//  Created by Rommel Rico on 11/8/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit

class LayerChatCell: UITableViewCell {

    // MARK: LayerChatCell properties
    var messageImageView: UIImageView!
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var messageStatus: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        messageImageView = UIImageView()
        messageImageView.tag = 1
        messageImageView.frame = CGRect(x: 100, y: 30, width: 150, height: 90)
        addSubview(self.messageImageView)
    }
    
    func updateWithImage(image: UIImage) {
        messageImageView.image = image
    }
    
    func removeImage() {
        guard messageImageView.image != nil else { return }
        messageImageView.image = nil
    }
    
    func assignText(text: String) {
        messageLabel.text = text
    }

}
