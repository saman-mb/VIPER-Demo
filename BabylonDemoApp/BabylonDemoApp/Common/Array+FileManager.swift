//
//  JSON.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 27/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
import PromiseKit

extension Array where Element: Codable
{
    private func writeToFileToDocuments(named fileName: String, fileWriter: FileWritable) throws
    {
        do {
            let jsonData = try JSONEncoder().encode(self)
            try fileWriter.write(data: jsonData, toFileNamed: fileName)
        }
    }
    
    static func loadFromFile(named fileName: String, fileReader: FileReadable) -> Promise<[Element]>
       {
           return Promise { seal in
               do {
                   let data = try fileReader.loadData(fromFileName: fileName)
                   let posts = try JSONDecoder().decode([Element].self, from: data)
                   seal.fulfill(posts)
               }
               catch {
                   seal.reject(error)
               }
           }
       }
       
    func writeToFile(named fileName: String, fileWriter: FileWritable) -> Promise<[Element]>
       {
           return Promise { seal in
               do {
                   try writeToFileToDocuments(named: fileName, fileWriter: fileWriter)
                   seal.fulfill(self)
               }
               catch {
                   seal.reject(error)
               }
           }
       }
}

