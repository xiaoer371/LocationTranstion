//
//  LocationTransform.m
//  TTTest
//
//  Created by lxj on 2017/5/26.
//  Copyright © 2017年 lxj. All rights reserved.
//

#import "LocationTransform.h"

static double EARTH_R = 6378137.0;


@interface LocationTransform ()


@end


@implementation LocationTransform

- (BOOL)isOutOfChinaWithLat:(LXLoca)loca
{
    if (loca.lng < 72.004 || loca.lng > 137.8347) {
        return true;
    }
    if (loca.lat < 0.8293 || loca.lat > 55.8271) {
        return true;
    }
    
    return false;
}

- (LXLoca)transform:(LXLoca)lxLoca
{
    double xy = lxLoca.lat * lxLoca.lng;
    double absX = sqrt(fabs(lxLoca.lat));
    
    double xPi = lxLoca.lat * M_PI;
    double yPi = lxLoca.lng * M_PI;
    double d = 20.0 * sin(6.0 * xPi) + 20.0 * sin(2.0 * xPi);
    
    double lat = d;
    double lng = d;
    
    lat += 20.0 * sin(yPi) + 40.0 * sin(yPi / 3.0);
    lng += 20.0 * sin(xPi) + 40.0 * sin(xPi / 3.0);
    
    lat += 160.0 * sin(yPi / 12.0) + 320 * sin(yPi / 30.0);
    lng += 150.0 * sin(xPi / 12.0) + 300 * sin(xPi / 30.0);
    
    lat *= 2.0 / 3.0;
    lng *= 2.0 / 3.0;
    
    lat += -100 + 2.0 * lxLoca.lat + 3.0 * lxLoca.lng + 0.2 * lxLoca.lng * lxLoca.lng + 0.1 * xy + 0.2 * absX;
    lng += 300.0 + lxLoca.lat + 2.0 * lxLoca.lng + 0.1 * lxLoca.lat * lxLoca.lat + 0.1 * xy + 0.1 * absX;
    
    LXLoca loca = {lat, lng};
    
    return loca;
}

- (LXLoca )delta:(LXLoca)lxLoca
{
    double ee = 0.00669342162296594323;
    double radLat = lxLoca.lat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    LXLoca locaTran = {lxLoca.lng - 105.0, lxLoca.lat - 35.0};
    LXLoca loca = [self transform:locaTran];
    double nlat = (loca.lat * 180.0) / ((EARTH_R * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    double nLng = (loca.lng * 180.0) / (EARTH_R / sqrtMagic * cos(radLat) * M_PI);
    LXLoca nloca = {nlat, nLng};
    return nloca;
}


/**
 * wgs2gcj 函数  WGS-84 转 GCJ-02
 */
- (LXLoca)wgs2gcj:(LXLoca)wsgLoca
{
    if ([self isOutOfChinaWithLat:wsgLoca]) {
        return wsgLoca;
    }
    LXLoca loca = [self delta:wsgLoca];
    LXLoca nLoca = {wsgLoca.lat + loca.lat, wsgLoca.lng + loca.lng};
    return nLoca;
}


/**
 * gcj2wgs 函数 GCJ-02 转 WGS-84  
 * 这个输出的坐标精度是1米到2米， 如果要更精确的结果，使用 gcj2wgs_exact 函数
 */
- (LXLoca)gcj2wgs:(LXLoca)gcjLoca
{
    if ([self isOutOfChinaWithLat:gcjLoca]) {
        return gcjLoca;
    }
    LXLoca loca = [self delta:gcjLoca];
    LXLoca nLoca = {gcjLoca.lat - loca.lat, gcjLoca.lng - loca.lng};
    return nLoca;
}

/**
 * gcj2wgs_exact 函数 GCJ-02 转 WGS-84 
 * 能精确到0.5米以下，但是比 gcj2wgs 函数 慢很多。
 */
- (LXLoca)gcj2wgs_exact:(LXLoca)gcjLoca
{
    double initDelta = 0.01;
    double threshold = 0.000001;
    LXLoca dLoca = {initDelta, initDelta};
    LXLoca mLoca = {gcjLoca.lat - dLoca.lat, gcjLoca.lng - dLoca.lng};
    LXLoca pLoca = {gcjLoca.lat + dLoca.lat, gcjLoca.lng + dLoca.lng};
    LXLoca wsgLoca = gcjLoca;
    
    for (int i =0 ; i<30 ; i++) {
        wsgLoca.lat = (mLoca.lat + pLoca.lat)/2;
        wsgLoca.lng = (mLoca.lng + mLoca.lng)/2;
        LXLoca temLoca = [self wgs2gcj:wsgLoca];
        
        dLoca.lat = temLoca.lat - gcjLoca.lat;
        dLoca.lng = temLoca.lng = gcjLoca.lng;
        if (fabs(dLoca.lat)< threshold && (fabs(dLoca.lng)<threshold)) {
            return wsgLoca;
        }
        
        if (dLoca.lat>0) {
            pLoca.lat = wsgLoca.lat;
        }else{
            mLoca.lat = wsgLoca.lat;
        }
        if (dLoca.lng >0) {
            pLoca.lng = wsgLoca.lng;
        }else{
            mLoca.lng = wsgLoca.lng;
        }
        
    }
    return wsgLoca;
}

-(double)Distance:(LXLoca)locaA locaB:(LXLoca)locaB
{
    double arcLatA = locaA.lat * M_PI / 180;
    double arcLatB = locaB.lat * M_PI / 180;
    double x = cos(arcLatA) * cos(arcLatB) * cos((locaA.lng-locaB.lng) * M_PI/180);
    double y = sin(arcLatA) * sin(arcLatB);
    double s = x + y;
    if (s > 1 ){
        s = 1;
    }
    if (s < -1 ){
        s = -1;
    }
    double alpha = acos(s);
    double distance = alpha * EARTH_R;
    return distance;
}

/**
 * gcj2bd    GCJ-02 坐标 转 百度坐标 BD-09
 */
- (LXLoca)gcj2bd:(LXLoca)gcjLoca
{
    if ([self isOutOfChinaWithLat:gcjLoca]) {
        return gcjLoca;
    }
    double x = gcjLoca.lng;
    double y = gcjLoca.lat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) + 0.000003 * cos(x * M_PI);
    double bdLng = z * cos(theta) + 0.0065;
    double bdLat = z * sin(theta) + 0.006;
    LXLoca bdLoca = {bdLat, bdLng};
    return bdLoca;
}

/**
 * bd2gcj   百度坐标BD-09 转  GCJ-02 坐标
 */
- (LXLoca)bd2gcj:(LXLoca)bdLoca
{
    if ([self isOutOfChinaWithLat:bdLoca]) {
        return bdLoca;
    }
    double x = bdLoca.lng - 0.0065;
    double y = bdLoca.lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
    double gcjLng = z * cos(theta);
    double gcjLat = z * sin(theta);
    LXLoca gcjLoca = {gcjLat, gcjLng};
    return gcjLoca;
}

/**
 * wgs2bd   WGS-84坐标 转 百度坐标BD-09
 */
- (LXLoca )wgs2bd:(LXLoca)wgsLoca
{
    LXLoca gcjLoca = [self wgs2gcj:wgsLoca];
    return [self gcj2bd:gcjLoca];
}

/**
 * bd2wgs   百度坐标BD-09 转  WGS-84坐标
 */
- (LXLoca )bd2wgs:(LXLoca)bdLoca
{
    LXLoca gcjLoca = [self bd2gcj:bdLoca];
    return [self gcj2wgs:gcjLoca];
}




@end
