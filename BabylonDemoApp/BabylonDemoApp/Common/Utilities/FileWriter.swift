//
//  FileWriter.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 28/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

enum DocumentsManagerError: Error
{
    case missingDocumentsDirectoy
    case unableToFindFileNamed(String)
}

protocol FileWritable
{
    func write(data: Data, toFileNamed fileName: String) throws
}

protocol FileReadable
{
    func loadData(fromFileName: String) throws -> Data
}

typealias FileInteractor = FileReadable & FileWritable

class DocumentsFacade: FileInteractor
{
    func loadData(fromFileName fileName: String) throws -> Data
    {
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw DocumentsManagerError.unableToFindFileNamed(fileName)
        }
        let fileUrl = documentDirectoryUrl.appendingPathComponent(fileName)
        return try Data(contentsOf: fileUrl)
    }
    
    func write(data: Data, toFileNamed fileName: String) throws
    {
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw DocumentsManagerError.missingDocumentsDirectoy
        }
        let fileUrl = documentDirectoryUrl.appendingPathComponent(fileName)
        try data.write(to: fileUrl, options: [])
    }
}
