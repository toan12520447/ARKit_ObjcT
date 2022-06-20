//
//  ViewController.m
//  ARKit_Objc
//
//  Created by Toan Tran on 20/06/2022.
//

#import "ListViewController.h"
#import "ARSCNSreen.h"
@interface ListViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupListView];
    
}
- (void)setupListView{
    self.listView.delegate = self;
    self.listView.dataSource = self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"ARSCNView";
    } else if ( indexPath.row == 1) {
        cell.textLabel.text = @"ARView";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
#define VCFromSB(VC, SBName) (VC*)[[UIStoryboard storyboardWithName:SBName bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([VC class])];
    if (indexPath.row == 0) {
        ARSCNSreen *vc = VCFromSB(ARSCNSreen, @"ARSCNSreen");
        [self.navigationController pushViewController:vc animated:true];
    }else{
        
    }
}


@end
