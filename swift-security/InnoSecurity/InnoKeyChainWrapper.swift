//
//  InnoKeyChainWrapper.swift
//  swift-security
//
//  Created by Harika Annam on 7/14/17.
//  Copyright © 2017 Innominds Mobility. All rights reserved.
//

import UIKit

let serviceKey = "serviceName"

// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
public class InnoKeyChainWrapper: NSObject {
    public func savePassword(accountname: NSString, password: NSString) {
        self.save(service: serviceKey as NSString, data: password, userAccount: accountname)
    }
    private func save(service: NSString, data: NSString, userAccount: NSString) {
        let dataFromString: NSData = data.data(
            using: String.Encoding.utf8.rawValue, allowLossyConversion: false)! as NSData
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(
            objects: [kSecClassGenericPasswordValue, service, userAccount],
            forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue])
        keychainQuery[kSecValueDataValue as String] = dataFromString as AnyObject?
        // Add the new keychain item
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        if status != errSecSuccess {    // Always check the status
            print("Write failed: \(status)")
            //updatePassword(token: data)
        }
    }
    public func loadPassword(accountname: NSString) -> NSString? {
        return self.load(service: serviceKey as NSString, userAccount: accountname)
    }
    private func load(service: NSString, userAccount: NSString) -> NSString? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(
            objects: [kSecClassGenericPasswordValue, service, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue],
            forKeys: [kSecClassValue, kSecAttrServiceValue,
                      kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        var dataTypeRef: AnyObject?
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: NSString? = nil
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                contentsOfKeychain = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue)
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        return contentsOfKeychain
    }
    public func updatePassword(accountname: NSString, password: NSString) {
        self.update(service: serviceKey as NSString, data: password, userAccount: accountname)
    }
    private func update(service: NSString, data: NSString, userAccount: NSString) {
        let dataFromString: NSData = data.data(
            using: String.Encoding.utf8.rawValue, allowLossyConversion: true)! as NSData
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(
             objects: [kSecClassGenericPasswordValue, service, userAccount],
             forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue])
        let SecValueData: String! = kSecValueData as String
        let updateDictionary = [SecValueData: dataFromString]
        let status = SecItemUpdate(keychainQuery as CFDictionary, updateDictionary as CFDictionary)
        if status != errSecSuccess {
            print("Update failed: \(status)")
        }
    }
    public func removePassword(accountname: NSString) {
        return self.delete(service: serviceKey as NSString, userAccount: accountname)
    }
    private func delete(service: NSString, userAccount: NSString) {
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(
            objects: [kSecClassGenericPasswordValue, service, userAccount],
            forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue])
        // Delete any existing items
        let status = SecItemDelete(keychainQuery as CFDictionary)
        if status != errSecSuccess {
            print("Delete failed: \(status)")
        }
    }
    public func getAllKeyChainItemsOfClass(_ serviceName: String) -> NSMutableArray {
        let query: NSMutableDictionary = NSMutableDictionary(
            objects: [kSecClassGenericPasswordValue, serviceName],
            forKeys: [kSecClassValue, kSecAttrServiceValue])
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse
        // Fetch matching items from the keychain.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        // If no items were found, return an empty array.
        guard status != errSecItemNotFound else { return [] }
        // Throw an error if an unexpected status was returned.
        //   guard status == noErr else {  }
        // Cast the query result to an array of dictionaries.
        let resultData = queryResult as? [[String : AnyObject]]
        //print("resultData  \(String(describing: queryResult))")
        let finalResult = NSMutableArray()
        for result in resultData! {
            guard let accountName = result["acct"] as? NSString else {
                return finalResult
            }
            var dict = ["password": self.loadPassword(accountname: accountName), "name": result["acct"]]
            finalResult.add(dict)
            dict.removeAll()
        }
        return finalResult
    }
    public func renameAccount(_ newAccountName: String, _ oldAccountName: String) {
        // Try to update an existing item with the new account name.
        var attributesToUpdate = [String: AnyObject]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName as AnyObject?
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(
            objects: [kSecClassGenericPasswordValue, serviceKey, oldAccountName],
            forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue])
        let status = SecItemUpdate(keychainQuery as CFDictionary, attributesToUpdate as CFDictionary)
        if status != errSecSuccess {
            print("renameAccount failed: \(status)")
        }
    }
}
