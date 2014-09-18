//
//  FKFormMultiSelectViewController.m
//  FormKit
//
//  Created by Hong Wei Zhuo on 18/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import "FKFormMultiSelectViewController.h"
#import "FKFormItem.h"

@interface FKFormMultiSelectViewController () <UISearchBarDelegate, UISearchDisplayDelegate> {
    NSArray *_sortedKeyValues;
    NSMutableDictionary *_selectedRowFlags;
    
    FKMultiSelectFieldItem *_multiSelectFieldItem;
    
    UISearchBar *_searchBar;
    UISearchDisplayController *_searchDisplayController;
    NSMutableArray *_searchKeyValues;
}

-(void)back:(id)sender;

@end

@implementation FKFormMultiSelectViewController

-(id)initWithMultiSelectFieldItem:(FKMultiSelectFieldItem *)multiSelectFieldItem {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _allowSearching = NO;
        _searchKeyValues = [NSMutableArray array];
        
        _multiSelectFieldItem = multiSelectFieldItem;
        _sortedKeyValues = _multiSelectFieldItem.sortedKeyValues;
        if (!_sortedKeyValues) {
            [self deriveSortedKeyValues];
        }
        
        _selectedRowFlags = [NSMutableDictionary dictionary];
        if (_multiSelectFieldItem.value) {
            NSArray *selectedKeyValues = (NSArray *)_multiSelectFieldItem.value;
            for (id keyValue in selectedKeyValues) {
                [_selectedRowFlags setObject:@(YES) forKey:keyValue];
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backButton = [UIHelpers barButtonWithTitle:@"Back" target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 38)];
    _searchBar.backgroundImage = [UIImage imageNamed:@"bg_searchbar"];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"bg_searchbar_textfield"] forState:UIControlStateNormal];
    _searchBar.delegate = self;
    
    _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchDisplayController.delegate = self;
    _searchDisplayController.searchResultsDataSource = self;
    _searchDisplayController.searchResultsDelegate = self;
    
    if (_allowSearching) {
        self.tableView.tableHeaderView = _searchBar;
    }
}

-(void)setAllowSearching:(BOOL)allowSearching {
    _allowSearching = allowSearching;
    if (self.isViewLoaded) {
        if (_allowSearching) {
            self.tableView.tableHeaderView = _searchBar;
        } else {
            self.tableView.tableHeaderView = nil;
        }
    }
}

-(void)deriveSortedKeyValues {
    __block NSMutableDictionary *reverseMap = [NSMutableDictionary dictionary];
    [_multiSelectFieldItem.keyAndDisplayValues enumerateKeysAndObjectsUsingBlock:^(id key, id displayValue, BOOL *stop) {
        [reverseMap setObject:key forKey:displayValue];
    }];
    
    NSArray *sortedDisplayValues = [[reverseMap allKeys] sortedArrayUsingSelector:@selector(compare:)];
    _sortedKeyValues = [reverseMap objectsForKeys:sortedDisplayValues notFoundMarker:[NSNull null]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (_sortedKeyValues) {
            return _sortedKeyValues.count;
        }
    } else if (tableView == _searchDisplayController.searchResultsTableView) {
        return _searchKeyValues.count;
        
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    NSArray *keyValues = (tableView == self.tableView)? _sortedKeyValues:_searchKeyValues;
    id keyValue = [keyValues objectAtIndex:indexPath.row];
    
    NSString *displayValue = [_multiSelectFieldItem.keyAndDisplayValues objectForKey:keyValue];
    displayValue = displayValue?displayValue:@"";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        
        //        cell.textLabel.highlightedTextColor = [UIColor grayColor];
        
        UIView *selectedBackgroundView = [UIView new];
        selectedBackgroundView.backgroundColor = mRgb(0xea, 0xea, 0xea);
        cell.selectedBackgroundView = selectedBackgroundView;
    }
    
    cell.textLabel.text = displayValue;
    
    NSNumber *isSelected = (NSNumber *) (_selectedRowFlags[keyValue]);
    
    if (isSelected && isSelected.boolValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *keyValues = (tableView == self.tableView)? _sortedKeyValues:_searchKeyValues;
    id keyValue = [keyValues objectAtIndex:indexPath.row];
    
    NSNumber *isSelected = (NSNumber *) (_selectedRowFlags[keyValue]);
    if (isSelected && isSelected.boolValue) {
        [_selectedRowFlags removeObjectForKey:keyValue];
        
    } else {
        _selectedRowFlags[keyValue] = @(YES);
        
    }
    
    NSArray *selectedKeyValues = _selectedRowFlags.allKeys;
    _multiSelectFieldItem.value = (selectedKeyValues.count > 0)? selectedKeyValues: nil;
    
    [tableView reloadData];
    FKForm *form = (FKForm *)_multiSelectFieldItem.rootItem;
    [form valueChangedForItem:(ISInputItem *)_multiSelectFieldItem];
}

#pragma mark - private methods

-(void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
    FKForm *form = (FKForm *)_multiSelectFieldItem.rootItem;
    [form defocusItem:(ISInputItem *)_multiSelectFieldItem];
}

#pragma mark - UISearchDelegate & UISearchDisplayDelegate

-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    UITableView *searchResultsTableView =  _searchDisplayController.searchResultsTableView;
    searchResultsTableView.backgroundColor = mRgb(0xf8, 0xf8, 0xfa);
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self performSearchWithTerm:searchBar.text];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resetSearch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self performSearchWithTerm:searchBar.text];
}

-(void)performSearchWithTerm:(NSString *)term {
    [self resetSearch];
    
    if (term.length == 0) {
        return;
    }
    
    NSArray *sortedValues = [_multiSelectFieldItem.keyAndDisplayValues objectsForKeys:_sortedKeyValues notFoundMarker:[NSNull null]];
    
    [sortedValues enumerateObjectsUsingBlock:^(NSString *value, NSUInteger idx, BOOL *stop) {
        if ([value rangeOfString:term options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [_searchKeyValues addObject:_sortedKeyValues[idx]];
        }
    }];
}

-(void)resetSearch {
    [_searchKeyValues removeAllObjects];
}

@end
