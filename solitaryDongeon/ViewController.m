//
//  ViewController.m
//  solitaryDongeon
//
//  Created by Devine Lu Linvega on 2015-02-27.
//  Copyright (c) 2015 Devine Lu Linvega. All rights reserved.
//

#import "ViewController.h"
#import "Deck.h"
#import "Hand.h"
#import "Card.h"
#import "User.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *runButton;
- (IBAction)runButton:(id)sender;


// Card 1
@property (weak, nonatomic) IBOutlet UIView *card1Wrapper;
@property (weak, nonatomic) IBOutlet UIButton *card1Button;
- (IBAction)card1Button:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *card1Image;

// Card 2
@property (weak, nonatomic) IBOutlet UIView *card2Wrapper;
@property (weak, nonatomic) IBOutlet UIButton *card2Button;
- (IBAction)card2Button:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *card2Image;

// Card 3
@property (weak, nonatomic) IBOutlet UIView *card3Wrapper;
@property (weak, nonatomic) IBOutlet UIButton *card3Button;
- (IBAction)card3Button:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *card3Image;

// Card 4
@property (weak, nonatomic) IBOutlet UIView *card4Wrapper;
@property (weak, nonatomic) IBOutlet UIButton *card4Button;
- (IBAction)card4Button:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *card4Image;

// Details
@property (weak, nonatomic) IBOutlet UILabel *lifeLabel;
@property (weak, nonatomic) IBOutlet UILabel *Equipment;
@property (weak, nonatomic) IBOutlet UILabel *discardLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	playableHand = [[Hand alloc] init];
	playableDeck = [[Deck alloc] init];
	discardPile = [[NSMutableArray alloc] init];
	user = [[User alloc] init];
	
	[self template];
	[self updateStage];
}

-(void)template
{
	NSLog(@"Template(%f %f)", self.view.frame.size.width, self.view.frame.size.height);
	
	CGFloat margin = self.view.frame.size.width;
	
	_card1Wrapper.frame = CGRectMake(0, 0, 100, 100);
	_card1Wrapper.backgroundColor = [UIColor redColor];
	_card1Image.frame = CGRectMake(0, 0, 10, 10);
	_card1Image.backgroundColor = [UIColor blueColor];
	_card1Button.frame = CGRectMake(0, 0, 100, 100);
	_card1Wrapper.layer.cornerRadius = 10;
	_card1Wrapper.clipsToBounds = YES;
	
	_card2Wrapper.frame = CGRectMake(100, 0, 100, 100);
	_card2Wrapper.backgroundColor = [UIColor yellowColor];
	_card2Image.frame = CGRectMake(0, 0, 10, 10);
	_card2Image.backgroundColor = [UIColor blueColor];
	_card2Button.frame = CGRectMake(0, 0, 100, 100);
	_card2Wrapper.layer.cornerRadius = 10;
	_card2Wrapper.clipsToBounds = YES;
	
	_card3Wrapper.frame = CGRectMake(0, 100, 100, 100);
	_card3Wrapper.backgroundColor = [UIColor purpleColor];
	_card3Image.frame = CGRectMake(0, 0, 10, 10);
	_card3Image.backgroundColor = [UIColor blueColor];
	_card3Button.frame = CGRectMake(0, 0, 100, 100);
	_card3Wrapper.layer.cornerRadius = 10;
	_card3Wrapper.clipsToBounds = YES;
	
	_card4Wrapper.frame = CGRectMake(100, 100, 100, 100);
	_card4Wrapper.backgroundColor = [UIColor cyanColor];
	_card4Image.frame = CGRectMake(0, 0, 10, 10);
	_card4Image.backgroundColor = [UIColor blueColor];
	_card4Button.frame = CGRectMake(0, 0, 100, 100);
	_card4Wrapper.layer.cornerRadius = 10;
	_card4Wrapper.clipsToBounds = YES;
}

-(void)updateStage
{
	if( [[playableHand cards] count] < 3 ){
		[user nextRoom];
		[self draw];
	}
	
	[self.card1Button setTitle:[NSString stringWithFormat:@"%d%@",[[playableHand card:0] number],[[playableHand card:0] symbol]] forState:UIControlStateNormal];
	[self.card2Button setTitle:[NSString stringWithFormat:@"%d%@",[[playableHand card:1] number],[[playableHand card:1] symbol]] forState:UIControlStateNormal];
	[self.card3Button setTitle:[NSString stringWithFormat:@"%d%@",[[playableHand card:2] number],[[playableHand card:2] symbol]] forState:UIControlStateNormal];
	[self.card4Button setTitle:[NSString stringWithFormat:@"%d%@",[[playableHand card:3] number],[[playableHand card:3] symbol]] forState:UIControlStateNormal];
	
	[self.card1Button setTitleColor:[[playableHand card:0] color] forState:UIControlStateNormal];
	[self.card2Button setTitleColor:[[playableHand card:1] color] forState:UIControlStateNormal];
	[self.card3Button setTitleColor:[[playableHand card:2] color] forState:UIControlStateNormal];
	[self.card4Button setTitleColor:[[playableHand card:3] color] forState:UIControlStateNormal];
	
	self.Equipment.text = [NSString stringWithFormat:@"Sword: %d(Malus: %d)",[user equip], [user malus]];
	self.lifeLabel.text = [NSString stringWithFormat:@"Life: %d",[user life]];
	self.discardLabel.text = [NSString stringWithFormat:@"Points: %lu(%lu left)",(unsigned long)[discardPile count],(52-[discardPile count])];
	
	self.roomLabel.text = [NSString stringWithFormat:@"Room: %d",[user room]];
	
	if( [[playableHand cards] count] < 4 ){
		self.runButton.enabled = false;
	}
	else{
		self.runButton.enabled = true;
	}

}

# pragma mark - Choice

-(void)choice:(int)cardNumber
{
	NSString * cardData = [playableHand cardValue:cardNumber];
	Card * card = [[Card alloc] initWithString:cardData];
	
	NSLog(@"--------+-------------------");
	NSLog(@"!  CARD | %@ %d", [card type], [card number]);
	NSLog(@"--------+-------------------");
	
	// Check for trying to heal twice
	if( justHealed == 1 && [[card type] isEqualToString:@"H"] ){
		NSLog(@"Cannot heal twice!");
		[discardPile addObject:[playableHand cardValue:cardNumber]];
		[playableHand discard:cardNumber];
		justHealed = 1;
	}
	else if( [[card type] isEqualToString:@"H"] ){
		[user gainLife:[card value]];
		// Manip cards
		[discardPile addObject:[playableHand cardValue:cardNumber]];
		[playableHand discard:cardNumber];
		justHealed = 1;
		
	}
	else if( [[card type] isEqualToString:@"D"] ){
		[user gainEquip:[card value]];
		// Manip cards
		[discardPile addObject:[playableHand cardValue:cardNumber]];
		[playableHand discard:cardNumber];
		[user setMalus:25];
		justHealed = 0;
	}
	else{
		// Malus
		if( [card value] >= [user malus] ){
			NSLog(@"!!!!!!!");
			[user looseEquip];
			[self updateStage];
		}
		
		int battleDamage = ( [card value] - [user equip]) ;
		if( battleDamage < 0 ){ battleDamage = 0; }
		if( battleDamage > 0 ){ [user looseLife:battleDamage]; }
		
		[user setMalus:[card value]];
		
		// Manip cards
		[discardPile addObject:[playableHand cardValue:cardNumber]];
		[playableHand discard:cardNumber];
		justHealed = 0;
	}
	
	[user setEscape:0];
	[self updateStage];
}

-(void)draw
{
	NSLog(@"   VIEW | Draw");
	
	// Draw 4 cards
	
	if( [[playableHand cards] count] == 0){
		[playableHand pickCard:[playableDeck pickCard]];
		[playableHand pickCard:[playableDeck pickCard]];
		[playableHand pickCard:[playableDeck pickCard]];
		[playableHand pickCard:[playableDeck pickCard]];
	}
	else if( [[playableHand cards] count] == 1){
		[playableHand pickCard:[playableDeck pickCard]];
		[playableHand pickCard:[playableDeck pickCard]];
		[playableHand pickCard:[playableDeck pickCard]];
	}
	else if( [[playableHand cards] count] == 2){
		[playableHand pickCard:[playableDeck pickCard]];
		[playableHand pickCard:[playableDeck pickCard]];
	}
	else if( [[playableHand cards] count] == 3){
		[playableHand pickCard:[playableDeck pickCard]];
	}
	
	[self updateStage];
}

# pragma mark - Interactions

- (IBAction)runButton:(id)sender
{
	if([user escaped] == 1){
		return;
	}
	
	if( [[playableHand cards] count] < 4 ){
		return;
	}
	
	NSLog(@"   VIEW | Run Away! Discard %lu cards",(unsigned long)[[playableHand cards] count]);
	
	if( [[playableHand cards] count] == 4){
		[playableDeck addCard:[playableHand cardValue:0]];
		[playableDeck addCard:[playableHand cardValue:1]];
		[playableDeck addCard:[playableHand cardValue:2]];
		[playableDeck addCard:[playableHand cardValue:3]];
		[playableHand discard:0];
		[playableHand discard:0];
		[playableHand discard:0];
		[playableHand discard:0];
	}
	else if( [[playableHand cards] count] == 3){
		[playableDeck addCard:[playableHand cardValue:0]];
		[playableDeck addCard:[playableHand cardValue:1]];
		[playableDeck addCard:[playableHand cardValue:2]];
		[playableHand discard:0];
		[playableHand discard:0];
		[playableHand discard:0];
	}
	else if( [[playableHand cards] count] == 2){
		[playableDeck addCard:[playableHand cardValue:0]];
		[playableDeck addCard:[playableHand cardValue:1]];
		[playableHand discard:0];
		[playableHand discard:0];
	}
	else if( [[playableHand cards] count] == 1){
		[playableDeck addCard:[playableHand cardValue:0]];
		[playableHand discard:0];
	}
	[user setEscape:1];
	[user nextRoom];
	
	[self draw];
}

- (IBAction)card1Button:(id)sender
{
	[self choice:0];
}

- (IBAction)card2Button:(id)sender
{
	[self choice:1];
}

- (IBAction)card3Button:(id)sender
{
	[self choice:2];
}

- (IBAction)card4Button:(id)sender
{
	[self choice:3];
}

# pragma mark - Defaults

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

@end
