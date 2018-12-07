# FDLocalizeder
Localization language automatic import tool.


## FDLocalizeder 使用说明

> FDLocalizeder是一个自动添加本地化的工具。可以将`Excel(.xlsx)`文档一键导入到`xcode`工程项目中。

<br>

#### 使用步骤：

 1. 打开`FDLocalizeder`工程，分别将`xcodeproj`和`xlsx`格式的文件路径添加到`FDLocalizeder`中，这时界面上将出现`xcode`和`Excel`图标；

2. 选择需要添加的语言以及要添加的位置；

3. 你可以对所添加的本地化内容作注释说明；

4. 点击添加按钮`Click on ad`进行添加操作。

![主页](https://raw.githubusercontent.com/chuxiaojiajia/FDLocalizeder/master/.source/EAEC404C98DAECC6BB54A64924C24610.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/600)

![](https://raw.githubusercontent.com/chuxiaojiajia/FDLocalizeder/master/.source/983181C537C9F20E92365765A37D7EF6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/600)


<br>

#### 拓展功能：

> 根据需求，你可以添加部分语言或Excel的部分区域到项目中，方法如下：

1. 点击拓展功能按钮，弹出拓展选项；

2. 勾选`Choose some languages`可以进行部分语言的添加；

3. 勾选`Add With Range`可以进行`Excel`部分区域添加；

4. 右下方提供`Excel`的区域性选择框；

5. 右下角提供备份、还原功能，可根据需要进行使用；

6. 如果你不需要进行区域性添加，请取消掉勾选框，并`Confirm`。

![](https://raw.githubusercontent.com/chuxiaojiajia/FDLocalizeder/master/.source/073331641B4BD2FC98D852E60121D341.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/600)


<br>

#### Excel格式

> 工具支持最新的`xlsx`格式文档的添加（目前所有Excel格式均为xlsx格式，xls格式已被废弃）

Excel文档请保持如下格式：

![FDLocalizeder_Excel模板](https://raw.githubusercontent.com/chuxiaojiajia/FDLocalizeder/master/.source/F1350746-FC3C-459F-AE0C-8D6CED517678.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/600)


<br>

#### Excel不同国家名的通用性适配

> 需求给出的国家名千变万化。例如同样的瑞典语，第一次给出的可能是`se`，第二次给出`se瑞典语`，第三次又给出`se`，反反复复永无宁日。怎么办？添加适配文档，一劳永逸！

在`LanguzgeBindFile.plist`里将`Excel`所出现的国家名都添加到对应的列表中，使用的时候只要国家名在这里出现过，都可以识别。

<img src="https://raw.githubusercontent.com/chuxiaojiajia/FDLocalizeder/master/.source/3101550-8279e9d744ff28e1.png" width="375" alt=""/>

<br>
<br>
<br>



