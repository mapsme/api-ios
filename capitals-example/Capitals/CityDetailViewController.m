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

#import "CityDetailViewController.h"

#import "MapsWithMeAPI.h"

@interface CityDetailViewController ()

- (void)configureView;

@end


@implementation CityDetailViewController

- (NSString *)urlEncode:(NSString *)str
{
  return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("!$&'()*+,-./:;=?@_~"), kCFStringEncodingUTF8);
}

- (void)showCapitalOnTheMap:(BOOL)withLink
{
  NSString * pinId;
  if (withLink)
    pinId = [NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", [self urlEncode:self.city[@"name"]]];
  else
    pinId = [NSString stringWithFormat:@"%i", _cityIndex];
  [MWMApi showLat:[self.city[@"lat"] doubleValue] lon:[self.city[@"lon"] doubleValue] title:self.city[@"name"] andId:pinId];
}

- (void)setCityIndex:(NSInteger)newCityIndex
{
  if (_cityIndex != newCityIndex)
  {
    _cityIndex = newCityIndex;
    // Update the view.
    [self configureView];
  }

  if (self.masterPopoverController)
    [self.masterPopoverController dismissPopoverAnimated:YES];
}

- (void)configureView
{
  self.title = self.city[@"name"];
  [self.tableView reloadData];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self configureView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return section == 0 ? 5 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString * cellId = [NSString stringWithFormat:@"%d%d", indexPath.section, indexPath.row];
  UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil)
  {
    if (indexPath.section == 0)
    {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      switch (indexPath.row)
      {
        case 0: cell.textLabel.text = @"Latitude"; break;
        case 1: cell.textLabel.text = @"Longitude"; break;
        case 2: cell.textLabel.text = @"Country Code"; break;
        case 3: cell.textLabel.text = @"Population"; break;
        case 4: cell.textLabel.text = @"Time Zone"; break;
        default: break;
      }
    }
    else
    {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
      cell.textLabel.textAlignment = UITextAlignmentCenter;
      if (indexPath.section == 1)
        cell.textLabel.text = @"Show map and come back";
      else
        cell.textLabel.text = @"Show map and read Wikipedia";
    }
  }

  if (indexPath.section == 0)
  {
    switch (indexPath.row)
    {
      case 0: cell.detailTextLabel.text = [self.city[@"lat"] stringValue]; break;
      case 1: cell.detailTextLabel.text = [self.city[@"lon"] stringValue]; break;
      case 2: cell.detailTextLabel.text = self.city[@"countryCode"]; break;
      case 3: cell.detailTextLabel.text = [self.city[@"population"] stringValue]; break;
      case 4: cell.detailTextLabel.text = self.city[@"timeZone"]; break;
      default: break;
    }
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  switch (indexPath.section)
  {
    case 1: [self showCapitalOnTheMap:NO]; break;
    case 2: [self showCapitalOnTheMap:YES]; break;
    default: break;
  }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
  barButtonItem.title = NSLocalizedString(@"World Capitals", nil);
  [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
  self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
  // Called when the view is shown again in the split view, invalidating the button and popover controller.
  [self.navigationItem setLeftBarButtonItem:nil animated:YES];
  self.masterPopoverController = nil;
}

@end
