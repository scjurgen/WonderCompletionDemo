//
//  WebNewsEngine.h
//  test
//
//  Created by Jurgen Schwietering on 5/30/11.
//  Copyright (c) 2012 Deltatre S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebNewsEngine: NSObject

@property (nonatomic, strong) NSString *htmlTemplate;

-(void)defineTemplate:(NSString*)templateName;

-(NSString*)CreateHtml;

@end
