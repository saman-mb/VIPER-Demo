//
//  PostDetailInteractor.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 30/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
import BabylonApiService

class PostDetailInteractor
{
    private let api: BabylonApi
    private let fileWriter: FileWritable
    private let fileReader: FileReadable
    
    init(api: BabylonApi, fileInteractor: FileInteractor)
    {
        self.api = api
        self.fileWriter = fileInteractor
        self.fileReader = fileInteractor
    }
}
