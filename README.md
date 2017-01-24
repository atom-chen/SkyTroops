## SkyTroops是飞行射击游戏，是plane框架的另一个游戏，素材比较完整

## 使用新的层级结构，主要只有两个层，显示层和UI层，由默认摄像机对着，而游戏层是另外一个摄像机对着，显示层使用的是RenderLayer,这层可以进行后处理

## 12.7 -- 12.9
* 输入设置，使用虚拟摇杆,抽象成一个层(C)
* 敌人生成更改 (C)
* 子弹图更改 (C)
* 阻碍逻辑 (C)
* 自动发射子弹 (C)
* 加入背景 (C)
* 机体爆炸动画 (C)
* 加入摄像头和RednerTexture制作可以后处理的场景(C)(已经取消，太消耗性能)
* 主角加入飞行的尾气 (C)

## 12.10 --12.16
* ui基本完善 (C)
* loading 时间缩短 (C)
* 观看广告复活删除 (C)
* 所有敌机加入尾气(C)
* 加入全部飞机的资源 (C)
* 飞机根据不同等级会切换不同的图案(C)
* HUD显示炸弹(C)
* 炸弹逻辑 (C)
* 敌人的AI(3个) (C)
* 结算界面经验条 (C)
* 游戏icon以及游戏名字(android) (C)
* 敌机发射子弹逻辑 (C)
* 敌机拥有血量 (C)
* 主角血量显示 (C)
* DesignScene 加入各个敌人的生产逻辑 (C)
* 主角移动范围 (C)
* 炸弹逻辑 (C)
* 分数的规则 (C)
* 恢复和升级道具 (C)
* 放炸弹的逻辑优化 (C)
* 主角升级时候需要有个粒子特效 (C)
* 选择角色界面优化 (C)
* 设置本地保存数据，根据总分数解锁飞机 (C)
* 主页背景淡入(C)
* 暂停界面加入LayerColor (C)
* 解锁的UI (C)
* 根据分数积累经验条解锁飞机 (C)
* 道具的图像 (C)
* 主界面优化 (C)
* 暂停界面优化 (C)
* 加入恢复的道具和升级的道具(C)
* 子弹模式（根据不同等级子弹攻击力不同）(C)
* 子弹的碰撞逻辑还需要进一步优化(C)
* 关卡逻辑，采用一个关卡里面有多个配置数据，如果读不到就进入下一个场景(C)

## 12.22-12.23
* 一共6个关卡，关卡开始时候有显示文字，不loading加载关卡(C)
* 六个场景应该有六个背景音乐

## 1.11 -- 1.13
* 敌人发射子弹速度减小(C)
* 关卡结束时候场景切换 (C)

## 1.17 -- 1.20
* 有些敌人死亡之后仍然会发射子弹(C)
* 发射炮弹敌人死亡之后还可以与子弹碰撞(C)
* 背景音乐调整(C)
* 进入第三个关卡之后glverts和drawcall变得多了，导致帧率下降(C)
* 子弹速度快一点(C)
* 炸弹的爆炸显示（可使用粒子效果)
* 字体 (C)
* 敌人死亡之后发射炮弹还能把敌人打死(C)
* 预加载音乐(C)
* 在结算时候的loading显示广告 (C)
* 炮弹打到敌人就消失(C)
* 敌机进入场景回调一个函数增加到场景的集合(C)
* 调整敌人的AI
* 敌机漂浮功能
* 调整敌机的子弹
* 敌人血量增加与调整 
* 五个关卡的配置
* 通关场景
* 设计时候把物品放在游戏中间不要放在最后面
* resultScene数据显示

## 敌人AI
1. 发射子弹
2. 加速移动
3. 死亡发射散弹
4. 发射两列
5. 发射散弹
9. 被打死发射三个散弹，同时有物品
10.追逐角色

## 小boss
6.发射三发的子弹，同时会跟随角色左右移动 (AI 13)
11.发射两列的子弹，同时会跟随角色左右移动(AI 14)
12.发射会跟随主角的子弹,同时跟随角色左右移动(AI 15)

## 大boss
7
8
13
14
15

## 13到20的AI代表小boss
## 21到30的AI代表大boss

## 关卡
* 基本配置：在关卡一半时候会有一个小boss,关底有一个大boss
* 后面的关卡:可以配置同时出现两个小boss
* 待定:可以有个boss brush关卡，全面挑战大boss

## 尝试
* 加入boss
* 加入中boss
* 加入小boss

## 优化

## 敌人Ai
* 移动型
1. 匀速直线移动 (C)
2. 直线到达距离特定高度时候加速直线移动 (C)
3. 绕弯追逐主角 (C)
*  子弹型
4. 发射子弹(C)
5. 发射散弹 (C)
6  发射两列 (C)
* 打死发射子弹
7. 被打死发射全场的散弹 (C)
8. 被打死发射三个散弹(9)
9. 死亡时候有概率得到道具(C)


10. 发射两列子弹 (C)
11. 移动到主角位置发射子弹(C)

* 发射子弹型
1. 简单直线发射 (4)
2. 主角在同一水平线发射 (C)
3. 移动到主角位置发射 (C)

* 发射子弹类型
1. 一个一个发射 （4)
2. 连续发射两个 (C)
3. 连续发射三个 (C)
4. 散发射 (C)
7. 发射的子弹会旋转


## 设计
* 三十秒，一分钟左右需要给予一定的反馈，可以是道具，升级，难度增大

## 待完善
* 子弹与敌机碰撞不精确(C)
* 游戏音乐和音效(C)
* 游戏文字
* 多语言支持（中文和英文）
* 不续关的逻辑，广告五分钟后固定显示,最后一个解锁是解锁广告
