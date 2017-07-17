### LaunchAd
开屏广告的实现，代码没有过多的封装，所以代码量相对来说不多，可以学学里面的思路，拿来就能用
![image](https://github.com/west-east/ReadMeImage/blob/master/2017-07-17%2018_56_48.gif) 



### 主要思路：
* 1.使用LaunchImage的方式做启动图

* 2.使用自定义view添加在根控制器上做开屏广告的容器

* 3.使用dispatch_source_set_timer做倒计时处理


### 使用方法：（内部依赖Masonry，YYWebImage，YYModel，都可以被替换掉）
* 1.替换为LaunchImage的启动图方式

* 2.在LaunchAdView里面修改网络请求

* 3.跑起来吧


### 对应博客地址：http://www.ticsmatic.com/?p=102
