//
//  PostCellViewModel.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 27/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit

struct PostViewModel
{
    var title: String
    var subTitle: String
}

class PostTableViewCell: UITableViewCell
{
    @IBOutlet var title: UILabel!
    @IBOutlet var subTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with viewModel: PostViewModel)
    {
        title.text = viewModel.title
        subTitle.text = viewModel.subTitle
    }
}
