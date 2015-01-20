Web Linking
===========

[![Build Status](http://img.shields.io/travis/kylef/WebLinking.swift/master.svg?style=flat)](https://travis-ci.org/kylef/WebLinking.swift)

Swift implementation of Web Linking ([RFC5988](https://tools.ietf.org/html/rfc5988)).

## Example

Given the following `Link` header on an `NSHTTPURLResponse`.

```
Link: <https://api.github.com/user/repos?page=3&per_page=100>; rel="next",
      <https://api.github.com/user/repos?page=50&per_page=100>; rel="last"
```

We can find the next link on a response:

```swift
if let link = response.findLink(relation: "next") {
  println("We have a next link with the URI: \(link.uri).")
}
```

Or introspect all available links:

```swift
for link in response.links {
  println("We have a link with the relation: \(link.relationType) to \(link.uri).")
}
```

## License

Web Linking is licensed under the MIT license. See [LICENSE](LICENSE) for more
info.
