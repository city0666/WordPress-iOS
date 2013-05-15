//
//  ReaderPostTableViewCell.m
//  WordPress
//
//  Created by Eric J on 4/4/13.
//  Copyright (c) 2013 WordPress. All rights reserved.
//

#import "ReaderPostTableViewCell.h"
#import <DTCoreText/DTCoreText.h>
#import "UIImageView+Gravatar.h"
#import "WPWebViewController.h"
#import "WordPressAppDelegate.h"

#define RPTVCVerticalPadding 10.0f;
#define RPTVCFeaturedImageHeight 150.0f;

@interface ReaderPostTableViewCell() <DTAttributedTextContentViewDelegate>

@property (nonatomic, strong) ReaderPost *post;
@property (nonatomic, strong) DTAttributedTextContentView *snippetTextView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIView *byView;
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *reblogButton;
@property (nonatomic, strong) UILabel *bylineLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, assign) BOOL showImage;

- (CGFloat)requiredRowHeightForWidth:(CGFloat)width tableStyle:(UITableViewStyle)style;
- (void)handleLikeButtonTapped:(id)sender;
- (void)handleFollowButtonTapped:(id)sender;
- (void)handleReblogButtonTapped:(id)sender;

@end

@implementation ReaderPostTableViewCell

+ (NSArray *)cellHeightsForPosts:(NSArray *)posts
						   width:(CGFloat)width
					  tableStyle:(UITableViewStyle)tableStyle
					   cellStyle:(UITableViewCellStyle)cellStyle
				 reuseIdentifier:(NSString *)reuseIdentifier {

	NSMutableArray *heights = [NSMutableArray arrayWithCapacity:[posts count]];
	ReaderPostTableViewCell *cell = [[ReaderPostTableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:reuseIdentifier];
	for (ReaderPost *post in posts) {
		[cell configureCell:post];
		CGFloat height = [cell requiredRowHeightForWidth:width tableStyle:tableStyle];
		[heights addObject:[NSNumber numberWithFloat:height]];
	}
	return heights;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		CGFloat width = self.frame.size.width;
		
		[self.contentView addSubview:self.imageView]; // TODO: Not sure about this...
		self.imageView.contentMode = UIViewContentModeScaleAspectFill;
		self.imageView.clipsToBounds = YES;
		
		//self.snippetTextView = [[DTAttributedTextContentView alloc] initWithAttributedString:nil width:width];
		self.snippetTextView = [[DTAttributedTextContentView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 44.0f)];
		_snippetTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_snippetTextView.backgroundColor = [UIColor clearColor];
		_snippetTextView.edgeInsets = UIEdgeInsetsMake(0.f, 10.f, 0.f, 10.f);
		_snippetTextView.delegate = self;
		_snippetTextView.shouldDrawImages = NO;
		_snippetTextView.shouldLayoutCustomSubviews = NO;
		[self.contentView addSubview:_snippetTextView];
		
		self.byView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, (width - 20.0f), 20.0f)];
		_byView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self.contentView addSubview:_byView];
		
		self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
		[_byView addSubview:_avatarImageView];
		
		self.bylineLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, 0.0f, width - 45.0f, 20.0f)];
		_bylineLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_bylineLabel.font = [UIFont systemFontOfSize:14.0f];
		_bylineLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
		_bylineLabel.backgroundColor = [UIColor clearColor];
		[_byView addSubview:_bylineLabel];
		

		UIImageView *commentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"note_icon_comment.png"]];
		commentImageView.frame = CGRectMake(10.0f, 3.0f, 16.0f, 16.0f);

		self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 3.0f, 30.0f, 16.0f)];
		_commentLabel.font = [UIFont systemFontOfSize:14.0f];
		_commentLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0f];
		
		UIImageView *likesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"note_icon_like.png"]];
		likesImageView.frame = CGRectMake(10.0f, 20.0f, 16.0f, 16.0f);

		self.likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 20.0f, 30.0f, 16.0f)];
		_likesLabel.font = [UIFont systemFontOfSize:14.0f];
		_likesLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0f];
		
		
		self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_likeButton.frame = CGRectMake(70.0f, 0.0f, 40.0f, 40.0f);
		_likeButton.backgroundColor = [UIColor colorWithHexString:@"3478E3"];
		_likeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[_likeButton addTarget:self action:@selector(handleLikeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

		self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = CGRectMake(170.0f, 0.0f, 40.0f, 40.0f);
		_followButton.backgroundColor = [UIColor colorWithHexString:@"3478E3"];
		_followButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[_followButton addTarget:self action:@selector(handleFollowButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		self.reblogButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_reblogButton.frame = CGRectMake(270.0f, 0.0f, 40.0f, 40.0f);
		_reblogButton.backgroundColor = [UIColor colorWithHexString:@"3478E3"];
		_reblogButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[_reblogButton addTarget:self action:@selector(handleReblogButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		self.controlView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
		_controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[_controlView addSubview:commentImageView];
		[_controlView addSubview:_commentLabel];
		[_controlView addSubview:likesImageView];
		[_controlView addSubview:_likesLabel];
		[_controlView addSubview:_likeButton];
		[_controlView addSubview:_followButton];
		[_controlView addSubview:_reblogButton];
		[self.contentView addSubview:_controlView];
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)layoutSubviews {
	[super layoutSubviews];

	CGFloat contentWidth = self.contentView.frame.size.width;
	CGFloat nextY = 0.0f;
	CGFloat vpadding = RPTVCVerticalPadding;
	CGFloat height = 0.0f;

	// Are we showing an image? What size should it be?
	if(_showImage) {
		height = RPTVCFeaturedImageHeight;
		self.imageView.frame = CGRectMake(0.0f, nextY, contentWidth, height);

		nextY += ceilf(height + vpadding);
	} else {
		nextY += vpadding;
	}

	// Position the snippet
	height = [_snippetTextView suggestedFrameSizeToFitEntireStringConstraintedToWidth:contentWidth].height;
	_snippetTextView.frame = CGRectMake(0.0f, nextY, contentWidth, height);
	[_snippetTextView layoutSubviews];
	nextY += ceilf(height + vpadding);

	// position the byView
	height = _byView.frame.size.height;
	CGFloat width = contentWidth - 20.0f;
	_byView.frame = CGRectMake(10.0f, nextY, width, height);
	nextY += ceilf(height + vpadding);
	
	// position the control bar
	height = _controlView.frame.size.height;
	_controlView.frame = CGRectMake(0.0f, nextY, contentWidth, height);
}


- (CGFloat)requiredRowHeightForWidth:(CGFloat)width tableStyle:(UITableViewStyle)style {
	
	CGFloat desiredHeight = 0.0f;
	CGFloat vpadding = RPTVCVerticalPadding;
	
	// Do the math. We can't trust the cell's contentView's frame because
	// its not updated at a useful time during rotation.
	CGFloat contentWidth = width;
	
	// reduce width for accessories
	switch (self.accessoryType) {
		case UITableViewCellAccessoryDisclosureIndicator:
		case UITableViewCellAccessoryCheckmark:
			contentWidth -= 20.0f;
			break;
		case UITableViewCellAccessoryDetailDisclosureButton:
			contentWidth -= 33.0f;
			break;
		case UITableViewCellAccessoryNone:
			break;
	}
	
	// reduce width for grouped table views
	if (style == UITableViewStyleGrouped) {
		contentWidth -= 19;
	}
	
	// Are we showing an image? What size should it be?
	if(_showImage) {
		CGFloat height = RPTVCFeaturedImageHeight;
		desiredHeight += height;
	}
	
	desiredHeight += vpadding;
	
	// Size of the snippet
	desiredHeight += [_snippetTextView suggestedFrameSizeToFitEntireStringConstraintedToWidth:contentWidth].height;
	desiredHeight += vpadding;
	
	// Size of the byview
	desiredHeight += (_byView.frame.size.height + vpadding);
	
	// size of the control bar
	desiredHeight += (_controlView.frame.size.height + vpadding);
	
	return desiredHeight;
}


- (void)prepareForReuse {
	[super prepareForReuse];
	
	[self.imageView cancelImageRequestOperation];
	self.imageView.image = nil;
	_avatarImageView.image = nil;
	_bylineLabel.text = nil;
	_snippetTextView.attributedString = nil;
}


- (void)configureCell:(ReaderPost *)post {
	self.post = post;
	NSString *str;
	NSString *contentSnippet = post.summary;
	if(contentSnippet && [contentSnippet length] > 0){
		str = [NSString stringWithFormat:@"<h3>%@</h3>%@", post.postTitle, contentSnippet];
	} else {
		str = [NSString stringWithFormat:@"<h3>%@</h3>", post.postTitle];
	}

	_snippetTextView.attributedString = [self convertHTMLToAttributedString:str withOptions:nil];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	NSString *dateStr = [dateFormatter stringFromDate:post.date_created_gmt];
	
	_bylineLabel.text = [NSString stringWithFormat:@"%@ on %@",dateStr, post.blogName];

	self.showImage = NO;
	self.imageView.hidden = YES;
	NSURL *url = nil;
	if (post.featuredImage) {
		self.showImage = YES;
		self.imageView.hidden = NO;

		NSInteger width = ceil(self.frame.size.width);

		NSString *path = [NSString stringWithFormat:@"https://i0.wp.com/%@?w=%i", post.featuredImage, width];
		url = [NSURL URLWithString:path];

		[self.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"gravatar.jpg"]];
	}
	
	_commentLabel.text = [self.post.commentCount stringValue];
	_likesLabel.text = [self.post.likeCount stringValue];
	
	[self.avatarImageView setImageWithBlavatarUrl:[[NSURL URLWithString:post.blogURL] host]];
	
	[self updateControlBar];
}


- (NSAttributedString *)convertHTMLToAttributedString:(NSString *)html withOptions:(NSDictionary *)options {
    NSAssert(html != nil, @"Can't convert nil to AttributedString");
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
														  DTDefaultFontFamily: @"Helvetica",
										   NSTextSizeMultiplierDocumentOption: [NSNumber numberWithFloat:1.3]
								 }];

	if(options) {
		[dict addEntriesFromDictionary:options];
	}
	
    return [[NSAttributedString alloc] initWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding] options:dict documentAttributes:NULL];
}


- (void)updateControlBar {
	if (!self.post) return;
	
	UIImage *img = nil;
	if (self.post.isLiked.boolValue) {
		img = [UIImage imageNamed:@""];
	} else {
		img = [UIImage imageNamed:@""];
	}
	[self.likeButton.imageView setImage:img];
	
	if (self.post.isReblogged.boolValue) {
		img = [UIImage imageNamed:@""];
	} else {
		img = [UIImage imageNamed:@""];
	}
	[self.reblogButton.imageView setImage:img];
	
	if (self.post.isFollowing.boolValue) {
		img = [UIImage imageNamed:@""];
	} else {
		img = [UIImage imageNamed:@""];
	}
	[self.followButton.imageView setImage:img];
}


- (void)handleLikeButtonTapped:(id)sender {
	NSLog(@"Tapped like");
	[self.post toggleLikedWithSuccess:^{
		// Nothing to see here?
	} failure:^(NSError *error) {
		[self updateControlBar];
	}];
	
	[self updateControlBar];
}


- (void)handleFollowButtonTapped:(id)sender {
	NSLog(@"Tapped follow");
	[self.post toggleFollowingWithSuccess:^{
		
	} failure:^(NSError *error) {
		[self updateControlBar];
	}];
	
	[self updateControlBar];
}


- (void)handleReblogButtonTapped:(id)sender {
	NSLog(@"Tapped reblog");
	[self.post reblogPostToSite:nil success:^{
		
	} failure:^(NSError *error) {
		[self updateControlBar];
	}];
	
	[self updateControlBar];
}


- (void)handleLinkTapped:(id)sender {
	WPWebViewController *controller = [[WPWebViewController alloc] init];
	[controller setUrl:((DTLinkButton *)sender).URL];
	[[[WordPressAppDelegate sharedWordPressApplicationDelegate] panelNavigationController] pushViewController:controller animated:YES];
}

#pragma mark - DTAttributedTextContentView Delegate Methods

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame {
	NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
	
	DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
	button.URL = [attributes objectForKey:DTLinkAttribute];
	button.minimumHitSize = CGSizeMake(25.0f, 25.0f); // adjusts it's bounds so that button is always large enough
	button.GUID = [attributes objectForKey:DTGUIDAttribute];
	
	// get image with normal link text
	UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
	[button setImage:normalImage forState:UIControlStateNormal];
	
	// get image for highlighted link text
	UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
	[button setImage:highlightImage forState:UIControlStateHighlighted];
	
	// use normal push action for opening URL
	[button addTarget:self action:@selector(handleLinkTapped:) forControlEvents:UIControlEventTouchUpInside];

	return button;
}


@end