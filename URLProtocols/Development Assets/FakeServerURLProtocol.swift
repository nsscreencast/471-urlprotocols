//
//  FakeServerURLProtocol.swift
//  URLProtocols
//
//  Created by Ben Scheirman on 1/6/21.
//

import Foundation

class FakeServerURLProtocol: URLProtocol {
    override class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = task.currentRequest else { return false }
        guard let url = request.url else { return false }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.host == "test.host"
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    struct Route {
        let path: String
        let file: String
        
        var contentType: String {
            if file.hasSuffix("json") {
                return "application/json"
            } else {
                return "text/plain"
            }
        }
    }
    
    let routes: [Route] = [
        Route(path: "/api/account", file: "account.json"),
        Route(path: "/api/account/165/members", file: "members.json"),
        Route(path: "/api/account/165/projects", file: "projects.json"),
    ]
    
    private func matchingRoute(url: URL) -> Route? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        return routes.first(where: { route in
            route.path == components.path
        })
    }
    
    override func startLoading() {
        guard let url = request.url else { return }
        
        if let route = matchingRoute(url: url) {
            respondWith(url: url, status: 200, file: route.file, contentType: route.contentType)
        } else {
            respondWithNotFound(url: url)
        }
    }
    
    override func stopLoading() {
    }
    
    private func respondWith(url: URL, status: Int, file: String, contentType: String) {
        let fileURL = Bundle.main.url(forResource: file, withExtension: nil)!
        let data = try! Data(contentsOf: fileURL)
        
        let response = HTTPURLResponse(url: url,
                                       statusCode: status,
                                       httpVersion: nil,
                                       headerFields: [
                                        "Content-Type": contentType
                                       ])!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    private func respondWithNotFound(url: URL) {
        let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: "Not Found".data(using: .utf8)!)
        client?.urlProtocolDidFinishLoading(self)
    }
}
