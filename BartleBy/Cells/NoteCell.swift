//
//  NoteCell.swift
//  BartleBy
//
//  Created by Andy Wong on 12/23/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class NoteCell: UICollectionViewCell {
    var dateLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContentView()
        self.backgroundColor = .backgroundColorReversed
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 10
    }
    
    private func setupContentView() {
        dateLabel = UILabel()
        dateLabel.textColor = .backgroundColor
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
