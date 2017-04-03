//
//  ServiceLocatorTests.swift
//  Alicerce
//
//  Created by Luís Afonso on 26/01/2017.
//  Copyright © 2017 Mindera. All rights reserved.
//

import XCTest

@testable import Alicerce

class ServiceLocatorTests : XCTestCase {
    
    var serviceLocator = ServiceLocator()
    
    override func setUp() {
        super.setUp()
        
        serviceLocator = ServiceLocator()
    }

    // MARK: - Register (normal)
    // MARK: Success
    
    func testRegister_UsingTypeInference_ShouldRegisterServices() {
        
        let testServiceString = "Test Register Service"
        let testServiceDouble = 1.0
        let testServiceInt = 1
        
        do {
            
            // Register services
            try serviceLocator.register(service: testServiceString)
            try serviceLocator.register(service: testServiceDouble)
            try serviceLocator.register(service: testServiceInt)
            
            // Get registered services
            let rStringService: String = try serviceLocator.get()
            let rDoubleService: Double = try serviceLocator.get()
            let rIntService: Int = try serviceLocator.get()
            
            // Validate registered services
            XCTAssertEqual(rStringService, testServiceString)
            XCTAssertEqual(rDoubleService, testServiceDouble)
            XCTAssertEqual(rIntService, testServiceInt)
            
        } catch let error {
            XCTFail("💥: Register failed with error: \(error)")
        }
    }
    
    func testRegister_UsingAName_ShouldRegisterService() {
        
        let testServiceString = "Test Register Service"
        let serviceName = "TestServiceName"
        
        do {
            
            // Register services
            let registeredServiceName = try serviceLocator.register(name: serviceName, service: testServiceString)
            
            // Get registered services
            let rStringService: String = try serviceLocator.get(name: serviceName)
            
            // Validate registered services
            XCTAssertEqual(rStringService, testServiceString)
            XCTAssertEqual(registeredServiceName, serviceName)
            
        } catch let error {
            XCTFail("💥: Register failed with error: \(error)")
        }
    }

    // MARK: Failure

    func testRegister_UsingTypeInference_ShouldFailWithDuplicatedService() {

        let testService = "Test Register Service"

        var serviceName: String?

        do {

            // Register the first service
            serviceName = try serviceLocator.register(service: testService)

            // Register the same service, should fail with duplicateService
            try serviceLocator.register(service: testService)

        } catch ServiceLocatorError.duplicateService(let duplicatedServiceName) {
            XCTAssertEqual(duplicatedServiceName, serviceName)
        } catch let error {
            XCTFail("💥: Got unexpected error `\(error)`")
        }
    }

    func testRegister_UsingName_ShouldFailWithDuplicatedService() {

        let testService = "Test Register Service"
        let serviceName = "TestServiceName"

        do {

            // Register the first service using a custom name
            try serviceLocator.register(name: serviceName, service: testService)

            // Register the same service using the same name, should fail with duplicateService
            try serviceLocator.register(name: serviceName, service: testService)

        } catch ServiceLocatorError.duplicateService(let duplicatedServiceName) {
            XCTAssertEqual(duplicatedServiceName, serviceName)
        } catch let error {
            XCTFail("💥: Got unexpected error `\(error)`")
        }
    }

    func testRegister_UsingTypeInference_ShouldFailWithDuplicateLazyService() {

        let testService = "Test Register Service"
        let testServiceLazy: () -> (String) = {
            return "Test Register Service"
        }

        var serviceName: String?

        do {

            // Register the first service (which should be lazy)
            serviceName = try serviceLocator.register(testServiceLazy)

            // Register the a normal service, should fail with duplicateLazyService
            try serviceLocator.register(service: testService)

        } catch ServiceLocatorError.duplicateLazyService(let duplicatedServiceName) {
            XCTAssertEqual(duplicatedServiceName, serviceName)
        } catch let error {
            XCTFail("💥: Got unexpected error `\(error)`")
        }

    }

    func testRegister_UsingName_ShouldFailWithDuplicateLazyService() {

        let testService = "Test Register Service"
        let testServiceLazy: () -> (String) = {
            return "Test Register Service"
        }
        let testServiceName = "TestServiceName"

        do {

            // Register the first service (which should be lazy)
            try serviceLocator.register(name: testServiceName, testServiceLazy)

            // Register the a normal service, should fail with duplicateLazyService
            try serviceLocator.register(name: testServiceName, service: testService)

        } catch ServiceLocatorError.duplicateLazyService(let duplicatedServiceName) {
            XCTAssertEqual(duplicatedServiceName, testServiceName)
        } catch let error {
            XCTFail("💥: Got unexpected error `\(error)`")
        }
        
    }

    // MARK: - Register (lazy)
    // MARK: Success
    
    func testLazyRegister_UsingTypeInference_ShouldRegisterService() {

        let testLazyServiceString: () -> (String) = {
            return "Test Register Service"
        }
        let testLazyServiceDouble: () -> (Double) = {
            return 1.0
        }
        
        do {
            
            // Register services
            try serviceLocator.register(testLazyServiceString)
            try serviceLocator.register(testLazyServiceDouble)

            // Get registered services
            let rStringService: String = try serviceLocator.get()
            let rDoubleService: Double = try serviceLocator.get()

            // Validate registered services
            XCTAssertEqual(rStringService, testLazyServiceString())
            XCTAssertEqual(rDoubleService, testLazyServiceDouble())

        } catch let error {
            XCTFail("💥: Register failed with error: \(error)")
        }
    }
    
    func testLazyRegister_UsingName_ShouldRegisterService() {
        
        let testLazyServiceString: () -> (String) = {
            return "Test Register Service"
        }
        let serviceName = "TestServiceName"
        
        do {
            
            // Register services
            let registeredServiceName = try serviceLocator.register(name: serviceName, testLazyServiceString)
            
            // Get registered services
            let rStringService: String = try serviceLocator.get(name: serviceName)
            
            // Validate registered services
            XCTAssertEqual(rStringService, testLazyServiceString())
            XCTAssertEqual(registeredServiceName, serviceName)
            
        } catch let error {
            XCTFail("💥: Register failed with error: \(error)")
        }
    }

    // MARK: - Failure

    func testLazyRegister_UsingTypeInference_ShouldFailWithDuplicateLazyService() {

        let testLazyServiceString: () -> (String) = {
            return "Test Register Service"
        }

        var serviceName: String?

        do {

            // Register the first lazy service
            serviceName = try serviceLocator.register(testLazyServiceString)

            // Register the same lazy service should fail with duplicateService
            try serviceLocator.register(testLazyServiceString)

        } catch ServiceLocatorError.duplicateLazyService(let duplicatedServiceName) {
            XCTAssertEqual(serviceName, duplicatedServiceName)
        } catch {
            XCTFail("💥: Lazy Register failed with error: \(error)")
        }
    }

    func testLazyRegister_UsingName_ShouldFailWithDuplicateLazyService() {

        let testLazyServiceString: () -> (String) = {
            return "Test Register Service"
        }
        let serviceName = "TestServiceName"

        do {

            // Register the first lazy service using name
            try serviceLocator.register(name: serviceName, testLazyServiceString)

            // Register the same lazy service, using the same name, should fail with duplicateService
            try serviceLocator.register(name: serviceName, testLazyServiceString)

        } catch ServiceLocatorError.duplicateLazyService(let duplicatedServiceName) {
            XCTAssertEqual(serviceName, duplicatedServiceName)
        } catch {
            XCTFail("💥: Lazy Register failed with error: \(error)")
        }
    }

    func testLazyRegister_UsingTypeInference_ShouldFailWithDuplicateService() {

        let testLazyServiceString: () -> (String) = {
            return "Test Register Service"
        }
        let testService = "Test Register Service"

        var serviceName: String?

        do {

            // Register a service, should fail with duplicateService
            serviceName = try serviceLocator.register(service: testService)

            // Register the first lazy service
            try serviceLocator.register(testLazyServiceString)

        } catch ServiceLocatorError.duplicateService(let duplicatedServiceName) {
            XCTAssertEqual(serviceName, duplicatedServiceName)
        } catch {
            XCTFail("💥: Lazy Register failed with error: \(error)")
        }
    }

    func testLazyRegister_UsingName_ShouldFailWithDuplicateService() {

        let testLazyServiceString: () -> (String) = {
            return "Test Register Service"
        }
        let testService = "Test Register Service"
        let serviceName = "TestServiceName"

        do {

            // Register a service, using name, should fail with duplicateService
            try serviceLocator.register(name: serviceName, service: testService)

            // Register the first lazy service using name
            try serviceLocator.register(name: serviceName, testLazyServiceString)

        } catch ServiceLocatorError.duplicateService(let duplicatedServiceName) {
            XCTAssertEqual(serviceName, duplicatedServiceName)
        } catch {
            XCTFail("💥: Lazy Register failed with error: \(error)")
        }
    }

    // MARK: - Get
    // MARK: Success
    
    func testGet_UsingName_ShouldReturnService() {
        
        let testServiceString = "Test Register Service"
        let testServiceDouble = 1.0
        
        do {
            
            // Register services
            let stringServiceName = try serviceLocator.register(service: testServiceString)
            let doubleServiceName = try serviceLocator.register(service: testServiceDouble)
            
            
            // Get registered services
            let rDoubleService: Double = try serviceLocator.get(name: doubleServiceName)
            let rStringService: String = try serviceLocator.get(name: stringServiceName)

            
            // Validate registered services
            XCTAssertEqual(rStringService, testServiceString)
            XCTAssertEqual(rDoubleService, testServiceDouble)
            
        } catch let error {
            XCTFail("💥: Get failed with error: \(error)")
        }
    }
    
    func testGet_UsingTypeInference_ShouldReturnService() {
        
        let testServiceString = "Test Register Service"
        let serviceName = "String"
        
        do {
            
            // Register services
            try serviceLocator.register(name: serviceName, service: testServiceString)
            
            // Get registered services
            let rStringService: String = try serviceLocator.get()
            
            // Validate registered services
            XCTAssertEqual(rStringService, testServiceString)
            
        } catch let error {
            XCTFail("💥: Get failed with error: \(error)")
        }
    }
    
    func testGetLazyInitRegistered_UsingName_ShouldReturnService() {
        
        let testLazyServiceString: () -> (String) = {
            return "Test Register Service"
        }
        let serviceName = "String"
        
        do {
            
            // Register services
            try serviceLocator.register(name: serviceName, testLazyServiceString)
            
            // Get registered services
            let rStringService: String = try serviceLocator.get(name: serviceName)
            
            // Validate registered services
            XCTAssertEqual(rStringService, testLazyServiceString())
            
        } catch let error {
            XCTFail("💥: Get failed with error: \(error)")
        }
    }

    // MARK: Failure

    func testGet_UsingTypeInference_ShouldFailWithInexistingService() {

        do {

            // Try to fetch any service. Shouldn't return nothing.
            let _: String = try serviceLocator.get()

        } catch  ServiceLocatorError.inexistentService {
            // Expected result
        } catch {
            XCTFail("💥: Get failed with error: \(error)")
        }
    }

    func testGet_UsingName_ShouldFailWithInexistingService() {

        let serviceName = "TestServiceName"

        do {

            // Try to fetch any service. Shouldn't return nothing.
            let _: String = try serviceLocator.get(name: serviceName)

        } catch  ServiceLocatorError.inexistentService {
            // Expected result
        } catch {
            XCTFail("💥: Get failed with error: \(error)")
        }
    }

    func testGet_UsingTypeInference_ShouldFailWithServiceTypeMismatch() {

        let testService = ""
        let serviceName = "Double"

        do {

            // Register a String type service
            try serviceLocator.register(name: serviceName, service: testService)

            // Get a Double type service
            let _: Double = try serviceLocator.get()

        } catch let ServiceLocatorError.serviceTypeMismatch(expected: expectedType, found: foundType) {
            print("expected: \(expectedType) but found: \(foundType)")
            assertMismatchTypes(expected: expectedType,
                                found: foundType,
                                registeredService: String.self,
                                getService: Double.self)
        } catch {
            XCTFail("💥: Get failed with error: \(error)")
        }
    }

    func testGet_UsingName_ShouldFailWithServiceTypeMismatch() {

        let testService = ""
        let serviceName = "TestServiceName"

        do {

            // Register a String type service
            try serviceLocator.register(name: serviceName, service: testService)

            // Get a Double type service
            let _: Double = try serviceLocator.get(name: serviceName)

        } catch let ServiceLocatorError.serviceTypeMismatch(expected: expectedType, found: foundType) {
            assertMismatchTypes(expected: expectedType,
                                found: foundType,
                                registeredService: type(of: testService),
                                getService: Double.self)
        } catch {
            XCTFail("💥: Get failed with error: \(error)")
        }
    }

    func testGet_UsingTypeInference_ShouldFailWithLazyServiceTypeMismatch() {

        let testLazyService: () -> (Double) = {
            return 1.0
        }

        do {

            // Register a String type service
            try serviceLocator.register(testLazyService)

            // Get a Double type service
            let _: Double = try serviceLocator.get()

        } catch let ServiceLocatorError.lazyServiceTypeMismatch(expected: expectedType, found: foundType) {
            print("expected: \(expectedType) but found: \(foundType)")
            assertMismatchTypes(expected: expectedType,
                                found: foundType,
                                registeredService: type(of: testLazyService),
                                getService: Double.self)
        } catch {
            XCTFail("💥: Get failed with error: \(error)")
        }
    }

    func testGet_UsingName_ShouldFailWithLazyServiceTypeMismatch() {

        let testLazyService: () -> (String) = {
            return "😎"
        }
        let serviceName = "TestServiceName"

        do {

            // Register a String type service
            try serviceLocator.register(name: serviceName, testLazyService)

            // Get a Double type service
            let _: String = try serviceLocator.get(name: serviceName)

        } catch let ServiceLocatorError.serviceTypeMismatch(expected: expectedType, found: foundType) {
            print("expected: \(expectedType) but found: \(foundType)")
            assertMismatchTypes(expected: expectedType,
                                found: foundType,
                                registeredService: String.self,
                                getService: String.self)
        } catch {
            XCTFail("💥: Get failed with error: \(error)")
        }
    }

    // MARK: - Unregister
    // MARK: Success
    
    func testUnregister_UsingTypeInference_ShouldRemoveService() {
        
        let testServiceString = "Test Register Service"
        
        do {
            
            // Register services
            try serviceLocator.register(service: testServiceString)
            
            // Get registered services
            let rStringService: String = try serviceLocator.get()
            
            // Check if it contains
            XCTAssertEqual(rStringService, testServiceString)

            try serviceLocator.unregister(type(of: testServiceString))
            
            let _: String = try serviceLocator.get()
            
        } catch ServiceLocatorError.inexistentService {
            // Expected result
        } catch let error {
            XCTFail("💥: Unregister failed with error: \(error)")
        }
    }
    
    func testUnregister_UsingServiceName_ShouldRemoveService() {
        
        let testServiceString = "Test Register Service"
        let serviceName = "ServiceName"
        
        do {
            
            // Register services
            try serviceLocator.register(name: serviceName, service: testServiceString)
            
            // Get registered services
            let rStringService: String = try serviceLocator.get(name: serviceName)
            
            // Check if it contains
            XCTAssertEqual(rStringService, testServiceString)

            try serviceLocator.unregister(type(of: testServiceString), name: serviceName)
            
            let _: String = try serviceLocator.get(name: serviceName)
            
        } catch ServiceLocatorError.inexistentService {
            // Expected result
        } catch let error {
            XCTFail("💥: Unregister failed with error: \(error)")
        }
    }

    func testUnregister_UsingTypeInference_ShouldFailWithInexistingService() {

        do {

            let _: String = try serviceLocator.get()

        } catch ServiceLocatorError.inexistentService {
            // Expected result
        } catch let error {
            XCTFail("💥: Unregister failed with error: \(error)")
        }
    }

    func testUnregister_UsingName_ShouldFailWithInexistingService() {

        let serviceName = "TestServiceName"

        do {

            let _: String = try serviceLocator.get(name: serviceName)

        } catch ServiceLocatorError.inexistentService {
            // Expected result
        } catch let error {
            XCTFail("💥: Unregister failed with error: \(error)")
        }
    }


    func testUnregister_UsingTypeInference_ShouldFailWithTypeMismatch() {

        let testService = ""
        let testServiceDouble = 1.0
        let serviceName = "Double"

        do {

            // Register a service with the name to "force" the "type"
            try serviceLocator.register(name: serviceName, service: testService)

            // Unregister the service using type inference, shoud fail because different type
            try serviceLocator.unregister(type(of: testServiceDouble))

        } catch let ServiceLocatorError.serviceTypeMismatch(expected: expectedType, found: foundType) {
            assertMismatchTypes(expected: expectedType,
                                found: foundType,
                                registeredService: String.self,
                                getService: Double.self)
        } catch let error {
            XCTFail("💥: Unregister failed with error: \(error)")
        }
    }

    func testUnregister_UsingName_ShouldFailWithTypeMismatch() {

        let testService = ""
        let testServiceDouble = 1.0
        let serviceName = "TestServiceName"

        do {

            // Register a String type service with a name
            try serviceLocator.register(name: serviceName, service: testService)

            // Get a Double type service with the same name
            try serviceLocator.unregister(type(of: testServiceDouble), name: serviceName)

        } catch ServiceLocatorError.serviceTypeMismatch(expected: let expectedType, found: let foundType) {
            XCTAssertTrue(type(of: expectedType) != type(of: foundType))
        } catch let error {
            XCTFail("💥: Unregister failed with error: \(error)")
        }
    }
    
    func testUnregisterAll_ShouldRemoveAllServices() {

        let testServiceString = "Test Register Service"
        let testServiceDouble = 1.0
        let testLazyServiceInt: () -> (Int) = {
            return 1
        }

        func fail(with error: Error) {
            XCTFail("💥: UnregisterAll test failed with error: \(error)")
        }

        do {

            // Register services
            try serviceLocator.register(service: testServiceString)
            try serviceLocator.register(service: testServiceDouble)
            try serviceLocator.register(testLazyServiceInt)

            // Check if all the services are loaded, even lazy ones
            let rStringService: String = try serviceLocator.get()
            let rDoubleService: Double = try serviceLocator.get()
            let rIntService: Int = try serviceLocator.get()

            // Validate that it contains registered services
            XCTAssertEqual(rStringService, testServiceString)
            XCTAssertEqual(rDoubleService, testServiceDouble)
            XCTAssertEqual(rIntService, testLazyServiceInt())

            serviceLocator.unregisterAll()

        } catch let error {
            fail(with: error)
        }

        func checkServiceRemoved<T>(_ type: T) {
            do {
                let _: T = try serviceLocator.get()

            } catch ServiceLocatorError.inexistentService {
                return
            } catch let error {
                fail(with: error)
            }
        }

        // Test that services were all removed

        checkServiceRemoved(Int.self)
        checkServiceRemoved(String.self)
        checkServiceRemoved(Double.self)
    }

    // MARK: - Helper Methods
    // MARK: Private
    private func assertMismatchTypes<RS, GS>(expected: Any.Type,
                                             found: Any.Type,
                                             registeredService: RS.Type,
                                             getService: GS.Type) {
        XCTAssert(expected != found)
        XCTAssert(expected == GS.self)
        XCTAssert(found == RS.self)
    }
}
