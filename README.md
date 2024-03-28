# Harvest

Harvest Front Client

## 支持

![](https://img.shields.io/badge/language-dart-orange.svg)
![](https://img.shields.io/badge/language-flutter-blue.svg)



## Getting Started

## 学习并记录Flutter

## 目标：完成一个漂亮实用的APP

### 界面
1. 毛玻璃效果
2. 动态背景
3. WEB侧边栏风格

### 实用
1. 登录注册
2. 数据存储
3. 网络请求
4. 图片加载

## 开启网络权限及http访问

## 安卓

### 开启网络权限

这里需要修改两个地方

路径：app/src/main/AndroidManifest.xml，app/src/profile/AndroidManifest.xml

位置：在mainfest节点下

```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```



### 允许http访问

这里添加的是application的一个属性：`android:usesCleartextTraffic="true"`

```xml
<application
        android:label="ptools"
        android:name="${applicationName}"
        android:usesCleartextTraffic="true"
        android:icon="@mipmap/ic_launcher">
</application>
```



## IOS

### 无需开启网络访问权限

### 需要开启http访问

路径：ios/Runner/Info.plist

位置：第一个dict下面单起一行

![image-20231024092931423](https://img.ptools.fun/blog/image-20231024092931423.png)

```xml
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowArbitraryLoads</key>
        <true/>
    </dict>
```



## MacOS

添加文件 `macos/Runner/DebugProfile.entitlements` 和 `macos/Runner/Release.entitlements`

```
<key>com.apple.security.network.client</key>
<true/>
```

