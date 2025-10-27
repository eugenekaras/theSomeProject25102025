//
//  APIServiseTests.swift
//  ChallengeTests
//
//  Created by Yauheni Karas on 27/10/2025.
//

import XCTest
@testable import Challenge

final class APIServiseTests: XCTestCase {
    
    func testFetchUsersNoInternet() {
        let mockSession = MockSession()
        let monitor = MockMonitor(isConnected: false)
        let apiService = APIService(session: mockSession, networkMonitor: monitor)
        let expectation = self.expectation(description: "fetchUsers noInternet")
        
        apiService.fetchUsers(page: 1) { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                if case .noInternet = error { } else { XCTFail("Expected noInternet") }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchUsersHttpError() {
        let mockSession = MockSession()
        let monitor = MockMonitor()
        mockSession.data = Data()
        mockSession.response = HTTPURLResponse(url: URL(string: "https://randomuser.me/api/")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        
        let apiService = APIService(session: mockSession, networkMonitor: monitor)
        let expectation = self.expectation(description: "fetchUsers http error")
        
        apiService.fetchUsers(page: 1) { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                if case .httpError(let code) = error {
                    XCTAssertEqual(code, 404)
                } else { XCTFail("Expected httpError") }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchUsersDecodingError() {
        let mockSession = MockSession()
        let monitor = MockMonitor()
        mockSession.data = "invalid json".data(using: .utf8)
        mockSession.response = HTTPURLResponse(url: URL(string: "https://randomuser.me/api/")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let apiService = APIService(session: mockSession, networkMonitor: monitor)
        let expectation = self.expectation(description: "fetchUsers decoding error")
        
        apiService.fetchUsers(page: 1) { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                if case .decodingError = error { } else { XCTFail("Expected decodingError") }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }

    final class MockSession: URLSessionProtocol {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
            completionHandler(data, response, error)
            return MockDataTask()
        }
    }

    final class MockDataTask: URLSessionDataTaskProtocol {
        func resume() {}
    }

    final class MockMonitor: NetworkMonitorProtocol {
        var isConnected: Bool
        init(isConnected: Bool = true) { self.isConnected = isConnected }
        func startMonitoring() {}
        func stopMonitoring() {}
    }
}
