//
//  XDPagesTypes.h
//  XDPagesView
//
//  Created by 谢兴达 on 2023/10/11.
//  Copyright © 2023 xie. All rights reserved.
//

/**
 pagesview下拉样式
 默认情况下为XDPagesPullOnTop，即顶端下拉
 */
typedef NS_ENUM(NSInteger, XDPagesPullStyle) {
    XDPagesPullOnTop = 0,       //顶端下拉
    XDPagesPullOnCenter = 1     //中间下拉
};

/**
 titleBar的下划指示线展示效果
 */
typedef NS_ENUM(NSInteger, SlideLineStyle) {
    XDSlideLine_None,          // 下划线无展示效果
    XDSlideLine_Scale,         // 下划线伸缩
    XDSlideLine_translation    // 下划线平移(默认效果)
};

/**
 titleBar的标题文字对齐方式
 */
typedef NS_ENUM(NSInteger, TitleVerticalAlignment) {
    XDVerticalAlignmentTop = 0, //标题顶部垂直对齐
    XDVerticalAlignmentMiddle,  //标题中部垂直对齐
    XDVerticalAlignmentBottom,  //标题底部垂直对齐
};

