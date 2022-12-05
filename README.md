![](https://raw.githubusercontent.com/xaochua/FDLocalizeder/master/.source/logo.png)

# FDLocalizeder
Localization language automatic import tool.

### [⛳️ 安装包下载点击这里 ⛳️](https://github.com/xaochua/FDLocalizeder/releases)

#### 【Instructions】
所有功能如下:

* Excel一键导入xcode工程
* xcode本地化分类导出至Excel
* 删除指定语言
* 本地语言多文件一键注释
* 本地化更新功能，相同code会覆盖
* 本地多语言包动态选择
* 非法语言路径过滤
* 语言比较，查找遗漏本地化
* 根据任一语言code添加新语言，并按母文件顺序排序
* 单语言，不定数语言添加，Excel指定范围添加
* 指定特定code导出语言包
* 版本暂存和回退
* 产品支持功能:Excel转义生成新的Excel文件

## FDLocalizeder 使用说明

> FDLocalizeder是一个自动添加本地化的工具。可以将`Excel(.xlsx)`文档一键导入到`xcode`工程项目中。

<br>

#### 使用步骤：

 1. 打开`FDLocalizeder`工程，分别将`xcodeproj/文件夹`和`xlsx`格式的文件或文件夹路径添加到`FDLocalizeder`中，这时界面上将出现`xcode`和`Excel`图标；

2. 选择需要添加的语言以及要添加的位置；

3. 你可以对所添加的本地化内容作注释说明；

4. 点击添加按钮`Click on add`进行添加操作。

[![zyVfFU.md.jpg](https://s1.ax1x.com/2022/12/05/zyVfFU.md.jpg)](https://imgse.com/i/zyVfFU)

<br>

#### 拓展功能：

> 根据需求，你可以添加部分语言或Excel的部分区域到项目中，方法如下：

1. 点击拓展功能按钮，弹出拓展选项；

2. 勾选`Choose some languages`可以进行部分语言的添加；

3. 勾选`Add With Range`可以进行`Excel`部分区域添加；

4. 右下方提供`Excel`的区域性选择框；

5. 右下角提供备份、还原功能，可根据需要进行使用；

6. 如果你不需要进行区域性添加，请取消掉勾选框，并`Confirm`。

[![zyV4W4.md.png](https://s1.ax1x.com/2022/12/05/zyV4W4.md.png)](https://imgse.com/i/zyV4W4)
<img src="https://raw.githubusercontent.com/chuxao/FDLocalizeder/master/.source/073331641B4BD2FC98D852E60121D341.png" width="600" alt=""/>

<br>

#### Excel格式

> 工具支持最新的`xlsx`格式文档的添加（目前所有Excel格式均为xlsx格式，xls格式已被废弃）

Excel文档请保持如下格式：

[![zyVRoT.md.png](https://s1.ax1x.com/2022/12/05/zyVRoT.md.png)](https://imgse.com/i/zyVRoT)
<img src="https://raw.githubusercontent.com/chuxao/FDLocalizeder/master/.source/F1350746-FC3C-459F-AE0C-8D6CED517678.png" width="700" alt="FDLocalizeder_Excel模板"/>

<br>

#### Excel不同国家名的通用性适配

> 需求给出的国家名千变万化。例如同样的瑞典语，第一次给出的可能是`se`，第二次给出`se瑞典语`，第三次又给出`se`，反反复复永无宁日。怎么办？添加适配文档，一劳永逸！

在`LanguzgeBindFile.plist`里将`Excel`所出现的国家名都添加到对应的列表中，使用的时候只要国家名在这里出现过，都可以识别。

[![zyV2wV.md.png](https://s1.ax1x.com/2022/12/05/zyV2wV.md.png)](https://imgse.com/i/zyV2wV)
<img src="https://raw.githubusercontent.com/xaochua/FDLocalizeder/master/.source/3101550-8279e9d744ff28e1.png" width="600" alt=""/>

#### 测试结果

[![zyVhYF.png](https://s1.ax1x.com/2022/12/05/zyVhYF.png)](https://imgse.com/i/zyVhYF)
<img src="https://raw.githubusercontent.com/xaochua/FDLocalizeder/master/.source/EBE063B8-002E-4B22-BA79-912F3D555B6C.png" width="800" alt=""/>

<br>

如有其它问题请提issue。

<br>
<br>
<br>



