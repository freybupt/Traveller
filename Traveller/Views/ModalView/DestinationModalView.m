//
//  DestinationModalView.m
//  Traveller
//
//  Created by WEI-JEN TU on 2014-04-20.
//  Copyright (c) 2014 Istuary. All rights reserved.
//

#import "DestinationModalView.h"
#import "RangeTableViewCell.h"
#import "DestinationTableViewCell.h"
#import "DepartureTableViewCell.h"

#define DESTINATION_MODAL_VIEW_TOP 77.0f
#define DESTINATION_MODAL_VIEW_WIDTH 296.0f
#define DESTINATION_MODAL_VIEW_HEIGHT 220.0f
#define DESTINATINO_MODAL_TABLEVIEW_INSET_TOP 10.0f
#define DESTINATION_MODAL_DEFAULT_TABLEVIEWCELL_IDENTIFIER @"DestinationModalDefaultTableViewCellIdentifier"
#define DESTINATION_MODAL_RANGE_TABLEVIEWCELL_IDENTIFIER @"DestinationModalRangeTableViewCellIdentifier"
#define DESTINATION_MODAL_DESTINATION_TABLEVIEWCELL_IDENTIFIER @"DestinationModalDestinationTableViewCellIdentifier"
#define DESTINATION_MODAL_DEPARTURE_TABLEVIEWCELL_IDENTIFIER @"DestinationModalDepartureTableViewCellIdentifier"

typedef NS_ENUM(NSInteger, DestinationModalTableRow) {
    DestinationModalTableRowRange,
    DestinationModalTableRowDestination,
    DestinationModalTableRowDeparture,
    DestinationModalTableRowCount
};

@interface DestinationModalView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation DestinationModalView

- (id)initWithTitle:(NSString *)title
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitle:(NSString *)otherButtonTitle
{
    CGRect frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - DESTINATION_MODAL_VIEW_WIDTH)/2,
                              DESTINATION_MODAL_VIEW_TOP,
                              DESTINATION_MODAL_VIEW_WIDTH,
                              DESTINATION_MODAL_VIEW_HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.text = title;
        self.delegate = delegate;
        [self.leftButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [self.rightButton setTitle:otherButtonTitle forState:UIControlStateNormal];
        
        _tableView = [self newTableView];
        [self insertSubview:_tableView belowSubview:self.leftButton];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Configuration
- (UITableView *)newTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                           self.titleLabel.frame.size.height,
                                                                           self.frame.size.width,
                                                                           self.frame.size.height - self.titleLabel.frame.size.height)];
    tableView.contentInset = UIEdgeInsetsMake(DESTINATINO_MODAL_TABLEVIEW_INSET_TOP, 0.0f, 0.0f, 0.0f);
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.scrollEnabled = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    return tableView;
}

#pragma mark - Table view data source & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return DestinationModalTableRowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case DestinationModalTableRowRange:
            return RANGE_TABLEVIEW_CELL_HEIGHT;
            break;
        case DestinationModalTableRowDestination:
            return DESTINATION_TABLEVIEW_CELL_HEIGHT;
            break;
        case DestinationModalTableRowDeparture:
            return DEPARTURE_TABLEVIEW_CELL_HEIGHT;
            break;
        default:
            return 0.0f;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case DestinationModalTableRowRange:{
            RangeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DESTINATION_MODAL_RANGE_TABLEVIEWCELL_IDENTIFIER];
            if (!cell) {
                cell = [[RangeTableViewCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.frame.size.width, RANGE_TABLEVIEW_CELL_HEIGHT)];
            }
            return cell;
        }break;
        case DestinationModalTableRowDestination:{
            DestinationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DESTINATION_MODAL_DESTINATION_TABLEVIEWCELL_IDENTIFIER];
            if (!cell) {
                cell = [[DestinationTableViewCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.frame.size.width, DESTINATION_TABLEVIEW_CELL_HEIGHT)];
            }
            return cell;
        }break;
        case DestinationModalTableRowDeparture:{
            DepartureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DESTINATION_MODAL_DEPARTURE_TABLEVIEWCELL_IDENTIFIER];
            if (!cell) {
                cell = [[DepartureTableViewCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.frame.size.width, DEPARTURE_TABLEVIEW_CELL_HEIGHT)];
            }
            return cell;
        }break;
        default:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DESTINATION_MODAL_DEFAULT_TABLEVIEWCELL_IDENTIFIER];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.frame.size.width, 0.0f)];
            }
            return cell;
        }break;
    }
}
@end
