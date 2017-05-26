//
//  LocationTransform.h
//  TTTest
//
//  Created by lxj on 2017/5/26.
//  Copyright © 2017年 lxj. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  *  结构变换坐标之间的地球(wgs - 84)和火星在中国(GCJ-02)。
 */

typedef struct {
    double lat;
    double lng;
}LXLoca;

@interface LocationTransform : NSObject

/**
 * wgs2gcj 函数  WGS-84 转 GCJ-02
 */
- (LXLoca)wgs2gcj:(LXLoca)wsgLoca;
/**
 * gcj2wgs 函数 GCJ-02 转 WGS-84
 * 这个输出的坐标精度是1米到2米， 如果要更精确的结果，使用 gcj2wgs_exact 函数
 */
- (LXLoca)gcj2wgs:(LXLoca)gcjLoca;

/**
 * gcj2wgs_exact 函数 GCJ-02 转 WGS-84
 * 能精确到0.5米以下，但是比 gcj2wgs 函数 慢很多。
 */
- (LXLoca)gcj2wgs_exact:(LXLoca)gcjLoca;

/**
 * 计算两点的坐标的距离
 @param locaA 坐标1
 @param locaB 坐标2
 @return 返回两个坐标之间的距离
 */
-(double)Distance:(LXLoca)locaA locaB:(LXLoca)locaB;

/**
 * gcj2bd    GCJ-02 坐标 转 百度坐标 BD-09
 */
- (LXLoca)gcj2bd:(LXLoca)gcjLoca;

/**
 * bd2gcj   百度坐标BD-09 转  GCJ-02 坐标
 */
- (LXLoca)bd2gcj:(LXLoca)bdLoca;

/**
 * wgs2bd   WGS-84坐标 转 百度坐标BD-09
 */
- (LXLoca )wgs2bd:(LXLoca)wgsLoca;

/**
 * bd2wgs   百度坐标BD-09 转  WGS-84坐标
 */
- (LXLoca )bd2wgs:(LXLoca)bdLoca;




@end
