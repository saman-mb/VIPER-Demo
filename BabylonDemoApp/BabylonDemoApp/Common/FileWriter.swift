//
//  FileWriter.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 28/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

enum FileWriterError: Error
{
    case missingDocumentsDirectoy
}

protocol FileWritable
{
    func write(data: Data, toFileNamed fileName: String) throws
}

class FileWriter: FileWritable
{
    func write(data: Data, toFileNamed fileName: String) throws
    {
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileWriterError.missingDocumentsDirectoy
        }
        let fileUrl = documentDirectoryUrl.appendingPathComponent(fileName)
        try data.write(to: fileUrl, options: [])
    }
}
