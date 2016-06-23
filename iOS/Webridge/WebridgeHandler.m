//
//  WebridgeHandler.m
//  Webridge
//
//  Created by linyize on 16-6-23.
//  Copyright (c) 2016年 islate. All rights reserved.
//

#import "WebridgeHandler.h"

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "SlateWebView.h"

@interface WebridgeHandler ()

@property (nonatomic, strong) NSMutableDictionary *contacts;

@end

@implementation WebridgeHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contacts = [NSMutableDictionary new];
    }
    return self;
}

- (void)readAddressBookContacts:(ABAddressBookRef)addressBook
{
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
    for(int i = 0; i < CFArrayGetCount(results); i++)
    {
        NSMutableDictionary *personDict = [NSMutableDictionary new];
        
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        
        // 读取firstname
        NSString *personName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if (!personName) {
            continue;
        }
        
        [personDict setObject:personName forKey:@"name"];
        
        NSString *phoneNumber = nil;
        
        // 读取电话
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phone) > 0) {
            phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
        }
        
        if (phoneNumber) {
            [personDict setObject:phoneNumber forKey:@"phone"];
        }
        
        
        // 读取生日
        NSDate *birthday = (__bridge NSDate*)ABRecordCopyValue(person, kABPersonBirthdayProperty);
        if (birthday) {
            [personDict setObject:[NSString stringWithFormat:@"%@", birthday] forKey:@"birthday"];
        }
        
        [_contacts setObject:personDict forKey:personName];
    }
    
    CFRelease(results);
}

#pragma mark - WBWebridgeDelegate

// 异步返回
- (void)nativeGetPhoneContacts:(id)params completion:(SlateWebridgeCompletionBlock)completion webView:(SlateWebView *)webView
{
    if (_contacts.count > 0)
    {
        if (completion)
        {
            completion(_contacts, nil);
        }
        return;
    }
    
    CFErrorRef err;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        
        // ABAddressBook doesn'tgaurantee execution of this block on main thread, but we want our callbacks tobe
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!granted) {
                
                NSLog(@"error: %@", error);
                
                if (completion)
                {
                    completion(nil, (__bridge NSError *)error);
                }
                
            } else {
                
                [self readAddressBookContacts:addressBook];
                
                if (completion)
                {
                    completion(_contacts, nil);
                }
            }
            
            CFRelease(addressBook);
            
        });
        
    });
}

// 异步返回
- (void)nativeGetPerson:(id)params completion:(SlateWebridgeCompletionBlock)completion webView:(SlateWebView *)webView
{
    NSString *name = [params objectForKey:@"name"];
    if (_contacts.count > 0)
    {
        id result = [_contacts objectForKey:name];
        if (completion)
        {
            completion(result, nil);
        }
        return;
    }

    CFErrorRef err;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        
        // ABAddressBook doesn'tgaurantee execution of this block on main thread, but we want our callbacks tobe
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!granted) {
                
                NSLog(@"error: %@", error);
                
                if (completion)
                {
                    completion(nil, (__bridge NSError *)error);
                }
                
            } else {
                
                [self readAddressBookContacts:addressBook];
                
                id result = [_contacts objectForKey:name];
                if (completion)
                {
                    completion(result, nil);
                }
            }
            
            CFRelease(addressBook);
            
        });
        
    });
}

// 同步返回
- (id)nativeGetPhoneContacts:(id)params webView:(SlateWebView *)webView
{
    return _contacts;
}

// 同步返回
- (id)nativeGetPerson:(id)params webView:(SlateWebView *)webView
{
    NSString *name = [params objectForKey:@"name"];
    return [_contacts objectForKey:name];
}

- (void)nativeShowAlert:(NSString *)message webView:(UIWebView *)webView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

// 同步JSToNative测试
- (id)testPassParam:(id)params webView:(SlateWebView *)webView
{
    return params;
}

// 异步JSToNative测试
- (void)testPassParamAsync:(id)params completion:(SlateWebridgeCompletionBlock)completion webView:(SlateWebView *)webView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) {
            completion(params, nil);
        }
    });
}

@end
