//
//  PostCellViewModel.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 27/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct PostViewModel
{
    var title: String
    var subTitle: String
}

class PostTableViewCell: UITableViewCell
{
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    var disposeBag = DisposeBag()
    var viewModel: BehaviorRelay<PostViewModel?> = BehaviorRelay(value: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLabelBindings()
    }
    
    private func setupLabelBindings()
    {
        viewModel
               .bind { viewModel in
                   self.titleLabel.text = viewModel?.title
                   self.subTitleLabel.text = viewModel?.subTitle
               }
               .disposed(by: disposeBag)
    }
    
}
