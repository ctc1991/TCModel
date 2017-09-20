# TCModel
A class to handle json and model.
## 使用方法
### 1.CocoaPods
```
pod 'TCModel'
```
```
oc:#import <TCModel/TCModel.h>
swift:import TCModel
```
### 2.手动拖入TCCategory文件夹
```
#import "TCModel.h"
```
##注意
- 基于TCModel的model都会在初始化中初始化每个属性，以保证使用model的过程中，不会因为nil而崩溃，也使得显示数据的时候最坏的情况也就是空字符和0，而不会出现尴尬的null。
- 目前只能对简单结构的model归档读档。