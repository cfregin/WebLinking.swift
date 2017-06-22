import XCTest
import WebLinking

class LinkTests: XCTestCase {
  var link:Link!

  override func setUp() {
    super.setUp()
    link = Link(uri: "/style.css", parameters: ["rel": "stylesheet", "type": "text/css"])
  }

  func testHasURI() {
    XCTAssertEqual(link.uri, "/style.css")
  }

  func testHasParameters() {
    XCTAssertEqual(link.parameters, ["rel": "stylesheet", "type": "text/css"])
  }

  func testHasRelationType() {
    XCTAssertEqual(link.relationType, "stylesheet")
  }

  func testHasReverseRelationType() {
    let link = Link(uri: "/style.css", parameters: ["rev": "document"])
    XCTAssertEqual(link.reverseRelationType, "document")
  }

  func testHasType() {
    XCTAssertEqual(link.type, "text/css")
  }

  // MARK: Equatable

  func testEquatable() {
    let otherLink = Link(uri: "/style.css", parameters: ["rel": "stylesheet", "type": "text/css"])
    XCTAssertEqual(link, otherLink)
  }

  // MARK: Hashable

  func testHashable() {
    let otherLink = Link(uri: "/style.css", parameters: ["rel": "stylesheet", "type": "text/css"])
    XCTAssertEqual(link.hashValue, otherLink.hashValue)
  }
}

class LinkHeaderTests: XCTestCase {
  var link:Link!

  override func setUp() {
    super.setUp()
    link = Link(uri: "/style.css", parameters: ["rel": "stylesheet", "type": "text/css"])
  }

  func testConversionToHeader() {
    XCTAssertEqual(link.header, "</style.css>; rel=\"stylesheet\"; type=\"text/css\"")
  }

  func testParsingHeader() {
    let parsedLink = Link(header: "</style.css>; rel=\"stylesheet\"; type=\"text/css\"")
    XCTAssertEqual(parsedLink, link)
  }

  func testParsingLinksHeader() {
    let links = parseLink(header: "</style.css>; rel=\"stylesheet\"; type=\"text/css\"")
    XCTAssertEqual(links[0], link)
    XCTAssertEqual(links.count, 1)
  }

  func testResponseLinks() {
    let url = URL(string: "http://test.com/")!
    let headers = [
      "Link": "</style.css>; rel=\"stylesheet\"; type=\"text/css\"",
    ]
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers)!
    let link = Link(uri: "http://test.com/style.css", parameters: ["rel": "stylesheet", "type": "text/css"])

    XCTAssertEqual(response.links, [link])
  }

  func testResponseFindLinkParameters() {
    let url = URL(string: "http://test.com/")!
    let headers = [
      "Link": "</style.css>; rel=\"stylesheet\"; type=\"text/css\", </style.css>; rel=\"stylesheet\"; type=\"text/css\"",
    ]
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers)!
    let link = Link(uri: "http://test.com/style.css", parameters: ["rel": "stylesheet", "type": "text/css"])
    let foundLink = response.findLink(["rel": "stylesheet"])!

    XCTAssertEqual(foundLink, link)
  }

  func testResponseFindLinkRelation() {
    let url = URL(string: "http://test.com/")!
    let headers = [
      "Link": "</style.css>; rel=\"stylesheet\"; type=\"text/css\", </style.css>; rel=\"stylesheet\"; type=\"text/css\"",
    ]
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers)!
    let link = Link(uri: "http://test.com/style.css", parameters: ["rel": "stylesheet", "type": "text/css"])
    let foundLink = response.findLink(relation: "stylesheet")!

    XCTAssertEqual(foundLink, link)
  }
  
  
  func testResponseFindLinkParametersIncludingComma(){
    let url = URL(string: "http://test.com/")!
    let headers = ["Link":"</api/products?page=2&per_page=20&productType=BOOK,MOVIE&state=ACTIVE>; rel=\"next\",</api/products?page=167&per_page=20&productType=BOOK,MOVIE&state=ACTIVE>; rel=\"last\",</api/products?page=1&per_page=20&productType=BOOK,MOVIE&state=ACTIVE>; rel=\"first\""]
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers)!
    
    let nextLink = Link(uri: "http://test.com/api/products?page=2&per_page=20&productType=BOOK,MOVIE&state=ACTIVE", parameters: ["rel": "next"])
    let foundNextLink = response.findLink(relation: "next")!
    XCTAssertEqual(foundNextLink, nextLink)
    XCTAssertEqual("http://test.com/api/products?page=2&per_page=20&productType=BOOK,MOVIE&state=ACTIVE", foundNextLink.uri)
    
    let lastLink = Link(uri: "http://test.com/api/products?page=167&per_page=20&productType=BOOK,MOVIE&state=ACTIVE", parameters: ["rel": "last"])
    let foundLastLink = response.findLink(relation: "last")
    XCTAssertEqual(foundLastLink, lastLink)
    XCTAssertEqual("http://test.com/api/products?page=167&per_page=20&productType=BOOK,MOVIE&state=ACTIVE", foundLastLink?.uri)
    
    
    let firstLink = Link(uri: "http://test.com/api/products?page=1&per_page=20&productType=BOOK,MOVIE&state=ACTIVE", parameters: ["rel": "first"])
    let foundFirstLink = response.findLink(relation: "first")
    XCTAssertEqual(foundFirstLink, firstLink)
    
  }
}

class LinkHTMLTests: XCTestCase {
  var link:Link!

  override func setUp() {
    super.setUp()
    link = Link(uri: "/style.css", parameters: ["rel": "stylesheet", "type": "text/css"])
  }

  func testConversionToHTML() {
    let html = "<link rel=\"stylesheet\" type=\"text/css\" href=\"/style.css\" />"
    XCTAssertEqual(link.html, html)
  }
}
