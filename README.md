# **PBR LookDev环境构建** #
此文档简略说明我是如何进行PBR LookDev环境构建的。全部过程大概总结为7步，涉及到
- 项目创建
- 资产导入
- 光照设置
- 材质创建
- 相机设置
- 后期处理效果设置
- 实时查看渲染效果

## **创建项目** ##
打开unity并选择3D模版。

## **导入资产** ##
导入所需的skybox材质，在 _window -> rendering -> lighting_。该资产名为[Skybox Series Free](https://assetstore.unity.com/packages/2d/textures-materials/sky/skybox-series-free-103633)来源于unity社区。此外，创建一个简易的plane，球体以及药丸体。
其中，药丸3D模型代表player，主要用于控制摄像机的移动和转。球体和plane被设在一个名为“Environment"下方便统一管理。此外，加入reflection probe[^1]用于控制反射效果。

## **设置光照** #
在这个项目中，光照设置为Directional Light来模拟太阳光。

## **创建材质** #
一共创建3个材质，混用standard shader和自己写的shader：
* player材质
* 布衣材质
* plane材质
* 球体材质 

## **设置摄像机** ##
为了提供可移动摄像机的功能，在Player ```GameObject```下分别创建一个3d模型Capsule以及camera。在Player中加入脚本组件用于控制摄像机跟随角色移动。脚本```PlayerMovement```需要输入3个变量，分别为:
+ Script
+ Controller
+ Speed
### 摄像机的转动以及后期处理 ###
在camera对象中，一共加入4组组件：
- Script
- Flare Layer
- Post-process Layer[^2]
- Post-process Volume
script用于控制摄像机跟随鼠标转动。Flare layer用于使镜头有光晕现象，post-process则用于后期处理。

## **后期处理** ##
在后期处理中，对于Post-process layer则是创建新的layer并将摄像机作为扳机(trigger)。主要工作则是在volume中完成。
在Volume里，采取了全局渲染（如果想通过控制在一个场景有作用而另一场景没有作用则取消该选项）。之后在profile中点击new就消除警告[^3]。
### Color Grading ###
后期处理中第一个使用的effect为color grading. 主要调整色温(Temperature)，饱和度(Saturation)，对比度(Contrast)以及色调偏移(Hue Shift)。
### Depth of Field ###
使用该组件来控制摄像机的聚焦距离，模糊大小等。
### Bloom ###
使用该组件来调整在强光源照射下出现的光晕效果。

## **查看渲染效果** ##
在game视图中通过移动摄像机来查看实时渲染效果，如反射是否真实变化，player是否会在不同位置被反射出来，物体阴影是否正确。

## **fps 显示** ##
为了将fps实时显示在屏幕左上角，通过创建canvas[^4]加入text(TMP)和一个脚本来实现。通过脚本来计算每秒帧率的变化。计算中引入平均帧```(1 / 时间流逝)```来得出帧率，并更新text的内容。

## **伪次表面散射Shader** ##
创建了一个可以实现伪次表面散射[^5]的着色器。该着色器同样支持金属材质/非金属材质，表面光滑度修改。具体实现理论依靠
Blinn - Phong模型。最终想要呈现出的效果的简易公式为：
```输出颜色 = 直接光源漫反射+直接光源镜面反射+IBL漫反射+IBL镜面反射```
### 提供选项 ###
着色器具体提供 采样图，法线贴图，颜色，镜面反射颜色，金属性，平滑性，吸收光谱，环绕光的属性修改。
### 着色器流程 ###
mesh -> vex func -> frag func -> image。
### 小结 ###
不过由于时间，家庭突发情况和自己对于更深的图像学知识理解不深，暂实现效果未达到预期。对于金属/非金属材质的反射，散射等物理现象渲染更为真实仍需要将部分物理模型和数学公式实现。
![Physic Model of BRDF PBS implement](./formula/format.png).


















[^1]: 如果使用的是```baked```渲染效果则无法提供实时的渲染，需要改为realtime。之后在 _window ->rendering -> lighting_ 中。将```auto generate```打开即可。如若选项为灰色无法选择，则需要在```assets```中创建新light setting文件即可.
[^2]: Post-process组件若缺失，可在 _window -> package manager -> unity registry_ 搜索并安装post processing即可。
[^3]: 对于老版unity则去在```assets```中创建新的文件即可。
[^4]: 对于canvas的渲染模式，为了使帧率显示固定在屏幕左上角，可以通过```Screen Space - Overlay```和```Screen Space - Camera```来固定显示位置。
[^5]: 理论参考文献: [Fast Subsurface Scattering in Unity](https://www.alanzucconi.com/2017/08/30/fast-subsurface-scattering-2/).</br>[Rendering 4 The First Light](https://catlikecoding.com/unity/tutorials/rendering/part-4/).</br>[Unity PBR Standard Shader 实现详解](https://zhuanlan.zhihu.com/p/137039291).