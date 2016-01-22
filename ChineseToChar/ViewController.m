//
//  ViewController.m
//  ChineseToChar
//
//  Created by 涂婉丽 on 16/1/21.
//  Copyright © 2016年 涂婉丽. All rights reserved.
//

#import "ViewController.h"
#define KCNSSTRING_ISEMPTY(str) (str == nil || [str isEqual:[NSNull null]] || str.length <= 0)

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating>
{

    UISearchController *seachVC;
}
@property (nonatomic,retain)NSArray *dataArray;
@property (nonatomic,retain)NSMutableArray *littleArray;
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
    seachVC = [[UISearchController alloc]initWithSearchResultsController:nil];
    seachVC.searchResultsUpdater = self;
    seachVC.dimsBackgroundDuringPresentation = false;
    [seachVC.searchBar sizeToFit];

    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.sectionIndexColor = [UIColor redColor];
    _tableView.tableHeaderView = seachVC.searchBar;
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
//
    if (!seachVC.active) {
        return self.dataArray.count;
    }else{
        return 1;
        
    }
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (!seachVC.active) {
        return self.dataArray;
    }else{
        return _littleArray;
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!seachVC.active) {
        return [(NSArray*)self.allKeysDict[self.dataArray[section]] count];
    }else{
    
        if (_littleArray.count!=0) {
             return [(NSArray*)self.allKeysDict[self.littleArray[section]] count];
        }else{
        
            return 0;
        }
       
    }

    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!seachVC.active) {
        return self.dataArray[section];
    }else{
    
        return nil;
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if (!seachVC.active) {
        cell.textLabel.text = [self.allKeysDict[self.dataArray[indexPath.section]] objectAtIndex:indexPath.row];
    }else{
    
        cell.textLabel.text = [self.allKeysDict[self.littleArray[indexPath.section]] objectAtIndex:indexPath.row];
    }
    
    return cell;
}
#pragma mark - searchController delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
//    [self.littleArray removeAllObjects];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@",searchController.searchBar.text];
    self.littleArray = [[self.dataArray filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    NSLog(@"--------------------%@",_littleArray);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
