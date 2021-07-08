//
//  Expo1900Tests.swift
//  Expo1900Tests
//
//  Created by WANKI KIM on 2021/07/08.
//

import XCTest

@testable import Expo1900
class Expo1900Tests: XCTestCase {
    var jsonDecoder: JSONDecoder?
    
    let expectedResult = ExpositionInformation(title: "hi", visitors: 123, location: "location", duration: "duration", description: "description")
    
    let wrongResult = [ExpositionInformation(title: "hi", visitors: 123, location: "location", duration: "duration", description: "description"),
                       ExpositionInformation(title: "hi", visitors: 123, location: "location", duration: "duration", description: "description"),
                       ExpositionInformation(title: "hi", visitors: 123, location: "location", duration: "duration", description: "description")]
 
    override func setUp() {
        jsonDecoder = JSONDecoder()
    }
    
    func test_ExpositionInformation타입으로_디코딩을_성공한다() {
        //given
        let data = try! JSONEncoder().encode(expectedResult)
        
        //when
        let expositionInformation = try! jsonDecoder?.decode(ExpositionInformation.self, from: data)
        
        //then
        XCTAssertEqual(expositionInformation, expectedResult)
        
    }
    
    func test_타입이달라ExpositionInformation타입으로_디코딩을_실패한다() {
        //given
        let data = try! JSONEncoder().encode(expectedResult)
        
        //when
        let expositionInformation = try? jsonDecoder?.decode(Olaf.self, from: data)
        
        //then
        XCTAssertNotEqual(expositionInformation, nil)
    }
    
    
    func test_items을_디코딩을_성공한다() {
        guard let dataAsset = NSDataAsset(name: "items") else { return }
        
        let exhibitionItem = try? jsonDecoder?.decode([ExhibitionItem].self, from: dataAsset.data)
        XCTAssertNotNil(exhibitionItem, "items 디코딩 성공!")
    }
}

extension ExpositionInformation: Encodable {
    fileprivate enum CodingKeys: CodingKey {
        case title, visitors, location, duration, description
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(visitors, forKey: .visitors)
        try container.encode(location, forKey: .location)
        try container.encode(duration, forKey: .duration)
        try container.encode(description, forKey: .description)
    }
}



extension ExpositionInformation: Equatable {
    public static func == (lhs: ExpositionInformation, rhs: ExpositionInformation) -> Bool {
        return lhs.title == rhs.title &&
            lhs.visitors == rhs.visitors &&
            lhs.location == rhs.location &&
            lhs.duration == rhs.duration &&
            lhs.description == rhs.description
    }
}

struct Olaf: Decodable {
    let title = "Olaf"
    let visitors = 0
    let locations = "제천"
    let duration = "hi"
    let description = "let it go"
}

extension Olaf: Equatable {
    public static func == (lhs: Olaf, rhs: Olaf) -> Bool {
        return lhs.title == rhs.title &&
            lhs.visitors == rhs.visitors &&
            lhs.locations == rhs.locations &&
            lhs.duration == rhs.duration &&
            lhs.description == rhs.description
    }
}
