//
//  Chapter3.swift
//  LanguageProcessing100knock2015
//
//  Created by koichi tanaka on 2017/10/10.
//  Copyright © 2017年 koichi tanaka. All rights reserved.
//

import Foundation

struct WikiItem: Codable {
    let title: String
    let text: String
}

struct Section {
    let name: String
    let level: Int
}

struct Chapter3 {
    //20. JSONデータの読み込み
    //Wikipedia記事のJSONファイルを読み込み，「イギリス」に関する記事本文を表示せよ．問題21-29では，ここで抽出した記事本文に対して実行せよ．
    static func q20(input: String) -> WikiItem {
        return ukWikiItem(input: input)
    }
    
    //21. カテゴリ名を含む行を抽出
    //記事中でカテゴリ名を宣言している行を抽出せよ．
    static func q21(input: String) -> [String] {
        let ukWiki = ukWikiItem(input: input)
        let linesHasCategory = ukWiki.text.components(separatedBy: CharacterSet.newlines).filter{ $0.contains("Category") }
        return linesHasCategory
    }
    
    //22. カテゴリ名の抽出
    //記事のカテゴリ名を（行単位ではなく名前で）抽出せよ．
    static func q22(input: String) -> Set<String> {
        let linesHasCategory = q21(input: input)
        let categoryNameMatches = linesHasCategory.map { (line) -> String in
            let regex =
            """
            \\[Category:\
            (\
            .+[^\\]]\
            )\
            \\]
            """
            return line.matches(regex: regex)[1]
        }
        var categoryNames = [String]()
        categoryNameMatches.forEach { (s) in
            if s.contains("|") {
                categoryNames.append(contentsOf: s.components(separatedBy: "|"))
            } else {
                categoryNames.append(s)
            }
        }
        return Set(categoryNames)
    }
    
    //23. セクション構造
    //記事中に含まれるセクション名とそのレベル（例えば"== セクション名 =="なら1）を表示せよ．
    static func q23(input: String) -> String {
        let ukWiki = ukWikiItem(input: input)
        let lines = ukWiki.text.components(separatedBy: CharacterSet.newlines)
        let sections = lines.flatMap { (line) -> Section? in
            let matche = line.matches(regex: "^(={2,})\\s*(.+?)\\s*={2,}$")
            if !matche.isEmpty {
                return Section(name: matche[2], level: (matche.first?.count)! - 1)
            } else {
                return nil
            }
        }
        return sections.map{ "\($0.name), \($0.level)" }.joined(separator: "\n")
    }
  
    //24. ファイル参照の抽出
    //記事から参照されているメディアファイルをすべて抜き出せ．
    static func q24(input: String) -> String {
        let ukWiki = ukWikiItem(input: input)
        let matches = ukWiki.text.matches(regex: "(ファイル:(.+?)|File:(.+?))[|]")
        let matchedFileIndeices = stride(from: 2, to: matches.count, by: 3).map{$0}
        
        return matches.enumerated().reduce("") { (combined, pair) -> String in
            if matchedFileIndeices.contains(pair.offset) {
                return "\(combined)\(pair.element)\n"
            } else {
                return combined
            }
        }
    }

}

extension Chapter3 {
    /// 入力されたjsonからタイトルがイギリスのものを探し先頭の1件を返す
    static func ukWikiItem(input: String) -> WikiItem {
        let lines = input.components(separatedBy: CharacterSet.newlines).filter{ !$0.isEmpty }
        let decoder = JSONDecoder()
        let ukWiki = lines.map{
            return try! decoder.decode(WikiItem.self, from: $0.data(using: .utf8)!)
            }.filter{ $0.title == "イギリス" }
            .first!
        return ukWiki
    }
}

extension String {
    
    /// 入力された正規表現文字列にマッチした結果を配列で返す
    ///
    ///     //（例）下記のように正規表現を引数に渡して利用します。
    ///     let matches = "Swift Moji 9876".matches(regex: "^(.+)\\s(\\d{4})")
    ///
    ///     // 戻り値の先頭はマッチ結果の完全なキャプチャを返します。
    ///     matches.first // "Swift Moji 9876"
    ///
    ///     // 個別のキャプチャされたグループは[1]以降に格納されます。
    ///     matches[1] // "Swift Moji"
    ///     matches.last // "2017"
    ///
    /// - Parameter regex: 正規表現文字列
    /// - Returns: マッチ結果
    func matches(regex: String!) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let results = regex.matches(in: self,
                                        options: [],
                                        range: NSRange(location: 0, length: self.count))
            var matches = [String]()
            
            for result in results {
                for i in 0..<result.numberOfRanges {
                    let range = Range.init(result.range(at: i), in: self)
                    if let r = range {
                        matches.append(String(self[r]))
                    }
                }
            }
            
            return matches
        } catch let error as NSError {
            assertionFailure("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
