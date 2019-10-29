//
//  JSON.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 27/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

extension Array where Element: Encodable
{
    func writeToFileToDocuments(named fileName: String, fileWriter: FileWritable = DocumentsFacade()) throws
    {
        do {
            let jsonData = try JSONEncoder().encode(self)
            try fileWriter.write(data: jsonData, toFileNamed: fileName)
        }
    }
}

