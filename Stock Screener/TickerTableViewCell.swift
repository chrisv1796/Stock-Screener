//
//  TickerTableViewCell.swift
//  Stock Screener
//
//  Created by Christian Vila on 1/7/18.
//  Copyright © 2018 NAPPSEntertaiment. All rights reserved.
//

import UIKit

class TickerTableViewCell: UITableViewCell {

    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
