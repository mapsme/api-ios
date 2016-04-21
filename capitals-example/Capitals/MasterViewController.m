/*******************************************************************************

 Copyright (c) 2013, MapsWithMe GmbH
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 ******************************************************************************/

#import "MasterViewController.h"
#import "CityDetailViewController.h"

#import "MapsWithMeAPI.h"

@implementation MasterViewController

- (CityDetailViewController *)detailViewController
{
  if (!_detailViewController)
      _detailViewController = [[CityDetailViewController alloc] initWithNibName:@"CityDetailViewController" bundle:nil];
  return _detailViewController;
}

- (NSArray *)capitals
{
  if (!_capitals)
  {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"capitals" ofType:@"plist"];
    _capitals = [NSArray arrayWithContentsOfFile:path];
  }
  return _capitals;
}

- (void)showAllCitiesOnTheMap:(id)sender
{
  NSMutableArray<MWMPin *> * array = [[NSMutableArray alloc] initWithCapacity:[self.capitals count]];

  for (NSInteger i = 0; i < [self.capitals count]; ++i)
  {
    NSString * pinId = [NSString stringWithFormat:@"%@", @(i)];
    // Note that url is empty - it means "More details" button for a pin in MapsWithMe will lead back to this example app
    NSDictionary * city = self.capitals[i];
    MWMPin * pin = [[MWMPin alloc] initWithLat:[city[@"lat"] doubleValue] lon:[city[@"lon"] doubleValue] title:city[@"name"] idOrUrl:pinId];
    [array addObject:pin];
  }
  // Your should hide any top view objects like UIPopoverController before calling +showPins:
  // If user does not installed MapsWithMe app, a popup dialog will be shown
  [self.detailViewController.masterPopoverController dismissPopoverAnimated:YES];
  
  [MWMApi showPins:array];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self)
  {
    self.title = NSLocalizedString(@"World Capitals", nil);
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
      self.clearsSelectionOnViewWillAppear = NO;
      self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  UIBarButtonItem * showMapButton = [[UIBarButtonItem alloc] initWithTitle:@"Show All" style:UIBarButtonItemStyleDone target:self action:@selector(showAllCitiesOnTheMap:)];
  self.navigationItem.rightBarButtonItem = showMapButton;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.capitals count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, tableView.rowHeight)];
  label.text = [MWMApi isApiSupported] ? @"MapsWithMe is installed" : @"MapsWithMe is not installed";
  label.textAlignment = NSTextAlignmentCenter;
  label.backgroundColor = [UIColor clearColor];
  return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return tableView.rowHeight / 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString * cellId = @"MasterCell";

  UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil)
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  cell.textLabel.text = self.capitals[indexPath.row][@"name"];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  self.detailViewController.city = self.capitals[indexPath.row];
  self.detailViewController.cityIndex = indexPath.row;
  if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
