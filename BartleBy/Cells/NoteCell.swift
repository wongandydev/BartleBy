//
//  NoteCell.swift
//  BartleBy
//
//  Created by Andy Wong on 12/23/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
    var dateLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupContentView()
    }
    
    private func setupContentView() {
        dateLabel = UILabel()
        self.contentView.addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints({ make in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
