//
//  StoppagesViewController.m
//  Safetrax
//
//  Created by Himanth on 30/06/16.
//  Copyright © 2016 Mtap. All rights reserved.
//

#import "StoppagesViewController.h"

@interface StoppagesViewController ()

@end

@implementation StoppagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return namesArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.text = [namesArray objectAtIndex:indexPath.row];
//    cell.textLabel.text = [NSString stringWithFormat:@"%li . %@",indexPath.row +1,[namesArray objectAtIndex:indexPath.row]];
    cell.detailTextLabel.text = [userIdsArray objectAtIndex:indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)getUsernameArray:(NSMutableArray *)usernameArray forAppropriateIdarray:(NSMutableArray *)idsArray;

{
    namesArray = usernameArray;
    userIdsArray = idsArray;
    NSLog(@"%@%@",namesArray,idsArray);
}
-(IBAction)donePressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
