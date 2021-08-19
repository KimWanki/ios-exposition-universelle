## 🗼만국박람회 프로젝트

#### 팀원 : 루얀, 엘렌, 지스
#### 기간 : 2021년 7월 5일 → 2021년 7월 16일

<br>

### 실행 화면
---

<br>

|  <center>실행화면1</center> |  <center>실행화면2</center> |
|:---------:|:--------:|
|![1](https://user-images.githubusercontent.com/57824307/129994192-c3c7fd5a-a586-40ca-94f8-b40737103c42.gif) | ![2](https://user-images.githubusercontent.com/57824307/129994197-1d5d3da6-ea6d-4b0b-949e-23e8f39e2824.gif) |
<br>

### Project UML
<br>

![image](https://user-images.githubusercontent.com/80380535/124548574-e2533100-de68-11eb-9df1-d957983ed941.png)

UML 작성 시 Codable을 채택했으나, Encodable 프로토콜은 실제로 사용핮 않아 Decodable 프로토콜만 사용하도록 변경했습니다.

<br>

#### 코드 리뷰 
--- 
[Json 포맷과 매칭할 타입 구현](https://github.com/yagom-academy/ios-exposition-universelle/pull/81)

[Json 데이터 파싱 미 TableView 구현](https://github.com/yagom-academy/ios-exposition-universelle/pull/98)


💡프로젝트에서의 경험

- [x] Codable protocol 
- [x] JSON 데이터 파싱 후 테이블뷰 표시
- [x] TableView delegate, datasource
- [x] 테이블 뷰 셀의 재사용 및 전반적 동작 방식 이해


<br><br>

## issue & what I learn

### 프로젝트 진행 중 커뮤니케이션

1. **페어 프로그래밍 방식**으로 navigator과 driver을 번갈아가며 코드를 작성했습니다. 함께 하는 팀원의 요청에 따라 코드를 작성하며, 서로 간의 의견이 조율되지 않을 경우, 각 방식으로 서로의 코드를 driver로 따라가며 코드를 완성해보면서 서로의 코드 진행 방향으 이해하며 프로젝트를 진행했습니다. 동료의 의견을 존중하고, 배려하며, 비방하지 않았습니다. 최종적으로 모두가 효율적인 코드 작성이라고 생각되는 방향으로 진행했습니다.

2. 프로젝트 중 팀원의 건강 악화로 예상했던 일자보다 조금 늦어졌습니다. 하지만 혼자 하는 것이 아니기 때문에 프로젝트를 잠시 중단했고, 이후 프로젝트를 진행하면서 요구되는 내용을 미리 학습하고, 이후 팀원이 지금 진행되고 있는 프로젝트에서의 흐름을 잃지 않도록, 필요하다면 설명을 더하고, 제가 **찾은 자료나 관련된 키워드를 공유**했습니다. 팀원 모두가 충분히 이해를 할 수 있는 상태에서 프로젝트 진행을 목표로 했습니다.
<br>

### 💡 뷰 사이 데이터 이동 방법 중 델리게이트를 활용

```swift
protocol SendExhibitionItemDelegate: AnyObject {
    func sendSelectedItem() throws -> ExhibitionItem
}
```

```swift
final class ExhibitionItemDetailViewController: UIViewController {
    weak var delegate: SendExhibitionItemDelegate?
    private var exhibitionItem: ExhibitionItem?
    
  func receiveData() {
        do {
            self.exhibitionItem = try delegate?.sendSelectedItem()
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: SendExhibitionItemDelegate
extension ExhibitionItemListTableViewController: SendExhibitionItemDelegate {
    func sendSelectedItem() throws -> ExhibitionItem {
        guard let selectedRow = exhibitionTableView.indexPathForSelectedRow?.row else {
            throw DelegateError.KeyNotFound
        }
        return exhibitionItems[selectedRow]
    }
}
```

뷰 간 데이터 이동을 위한 여러 방법 중 델리게이트 패턴을 적용해보았습니다. 
테이블 뷰의 세부사항을 나타내는 `ExhibitionItemDetailViewController` 에서 `delegate`를 두고,  `ExhibitionItemListTableViewController`에 명령을 할 수 있도록 하는 방향으로 코드를 작성했습니다. 대리자에게 `sendSelectedItem()`을 요청하면, 대리자에 의해 로드 전 뷰로부터 데이터를 받아올 수 있도록 설계하였습니다.

<br>

#### 💡decoding UnitTest

데이터를 서버에서 받아오지 않고, 가지고 있는 Json 데이터를 가지고 있는 형식으로 작성했습니다.
```swift
func test_ExpositionInformation_타입으로_디코딩을_성공한다() {
    // given
    let jsonData = try! JSONEncoder().encode(expositionInformation)
    // when
    let decodedResult = try! expositionInformationManager.decodejsonData(jsonData: jsonData)
    // then
    XCTAssertEqual(decodedResult, expositionInformation)
}
```

하지만 실제 데이터에 의존적인 테스트 코드를 작성할 경우, 데이터 값이 하나만 바뀌더라도 테스트는 실패하기 때문에 이 부분에 의존적이지 않도록 테스트 코드에서 Encodable을 채택해 extension으로 encode 메서드를 구현했고, 이를 바탕으로 dummyData를 가지고, 테스트를 진행했습니다.  

```swift
func test_ExpositionInformation_타입으로_디코딩을_성공한다() {
    // given
    let jsonData = try! JSONEncoder().encode(expositionInformation)
    // when
    let decodedResult = try! expositionInformationManager.decodejsonData(jsonData: jsonData)
    // then
    XCTAssertEqual(decodedResult, expositionInformation)
}

extension ExpositionInformation: Encodable {
    enum CodingKeys: CodingKey {
        case title
        case visitors
        case location
        case duration
        case description
    }
    
    public func encode(to encoder: Encoder) throws {
        var value = encoder.container(keyedBy: CodingKeys.self)
        try value.encode(title, forKey: .title)
        try value.encode(visitors, forKey: .visitors)
        try value.encode(location, forKey: .location)
        try value.encode(duration, forKey: .duration)
        try value.encode(description, forKey: .description)
    }
}
```
