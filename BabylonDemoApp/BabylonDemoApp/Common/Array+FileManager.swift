//
//  JSON.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 27/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

enum JSONError: Error
{
    case missingDocumentsDirectoy
}

extension Array where Element: Encodable
{
    func writeToFileOnDisk(named fileName: String) throws
    {
        do {
            guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                throw JSONError.missingDocumentsDirectoy
            }
            let fileUrl = documentDirectoryUrl.appendingPathComponent(fileName)
            let jsonData = try JSONEncoder().encode(self)
            try jsonData.write(to: fileUrl, options: [])
        }
        
    }
}

