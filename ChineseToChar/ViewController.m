//
//  ViewController.m
//  ChineseToChar
//
//  Created by 涂婉丽 on 16/1/21.
//  Copyright © 2016年 涂婉丽. All rights reserved.
//

#import "ViewController.h"
#define KCNSSTRING_ISEMPTY(str) (str == nil || [str isEqual:[NSNull null]] || str.length <= 0)

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,retain)NSArray *dataArray;
@property (nonatomic,retain)NSDictionary *allKeysDict;
@property (nonatomic,retain)UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self CreateUI];
    _dataArray = [[NSArray alloc]init];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Data" ofType:@"plist"]];

    _allKeysDict =  [self createCharacter:array];
    NSLog(@"%@",_allKeysDict);
    _dataArray = [self.allKeysDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *letter1 = obj1;
        NSString *letter2 = obj2;
        if (KCNSSTRING_ISEMPTY(letter2)) {
            return NSOrderedDescending;
        }else if ([letter1 characterAtIndex:0] < [letter2 characterAtIndex:0]) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    
}

- (void)CreateUI
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.sectionIndexColor = [UIColor redColor];
    [self.view addSubview:_tableView];
}
- (NSDictionary *)createCharacter:(NSMutableArray *)strArr
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSDictionary *stringdict in strArr) {
        NSString *string = stringdict[@"name"];
        if ([string length]) {
            NSMutableString *mutableStr = [[NSMutableString alloc] initWithString:string];
        
            if (CFStringTransform((__bridge CFMutableStringRef)mutableStr, 0, kCFStringTransformMandarinLatin, NO)) {
            }
            if (CFStringTransform((__bridge CFMutableStringRef)mutableStr, 0, kCFStringTransformStripDiacritics, NO)) {
                NSString *str = [NSString stringWithString:mutableStr];
                str = [str uppercaseString];
                NSMutableArray *subArray = [dict objectForKey:[str substringToIndex:1]];
                if (!subArray) {
                    subArray = [NSMutableArray array];
                    [dict setObject:subArray forKey:[str substringToIndex:1]];
                }
                [subArray addObject:string];
            }
        }
    }
    return dict;
}
//创建右侧索引表，返回需要显示的索引表数组

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return self.dataArray.count;
}

//创建右侧索引表，返回需要显示的索引表数组
- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.dataArray;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"%ld",[(NSArray*)self.allKeysDict[self.dataArray[section]] count]);

    return [(NSArray*)self.allKeysDict[self.dataArray[section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.dataArray[section];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = [self.allKeysDict[self.dataArray[indexPath.section]] objectAtIndex:indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
