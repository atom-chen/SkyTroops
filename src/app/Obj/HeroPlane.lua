local BasePlane = require("app/Obj/BasePlane")

local HeroPlane = class("HeroPlane", BasePlane)

local MOVE_TIME = 0.3
--左右加速器判断
local LEFT_ACC = -0.1
local RIGHT_ACC = 0.1
local UP_ACC = -0.4
local DOWN_ACC = -0.8
local RELIVE_TIME = 3


--限制不能移动的范围
local LIMIT_RECT = cc.rect(70,display.cy*0.5 + 50, display.width-150, display.height-150)

local LIMIT_LEFT_X = 70
local LIMIT_RIGHT_X = display.width-50
local LIMIT_UP_Y = display.height-50
local LIMIT_DOWN_Y = display.cy*0.3- 60

local allTime = 0

local isFireBullet = false

--最大能量条
local MAX_POWER = 8

function HeroPlane:ctor( fileName )
	HeroPlane.super.ctor(self, fileName)

	--是否在左右移动过程中
	self.isMoved_ = false
	--是否在受伤过程
	self.isOnHurt_ = false

	--死亡动画播放
	self.onDeadAni_ = false

	--是否复活
	self.isRelive_ = false

	--能量
	self.power_ = MAX_POWER

	--虚拟摇杆
	self.virtualJoy_ = nil

	--限制是否在屏幕内
	self.limitInScreen_ = true

	self.level_ = 1
end

function HeroPlane:onEnter()
	HeroPlane.super.onEnter(self)
end

function HeroPlane:getMaxPower(  )
	return MAX_POWER
end

function HeroPlane:getPower(  )
	return self.power_
end

function HeroPlane:minitesPower( pow )
	self.power_ = self.power_ - pow
end

function HeroPlane:addPower( pow )
	self.power_ = self.power_ + pow 
	--最大只能是极限值
	self.power_ = self.power_ > MAX_POWER and MAX_POWER or self.power_
end

--是否还有能量
function HeroPlane:hasPower(  )
	return self.power_ > 0
end

function HeroPlane:resetPower(  )
	self.power_ = MAX_POWER
end

function HeroPlane:onTouch( event )
	if event.name == "began" then
		self:fireBullet()
	end
end

function HeroPlane:attachVirtualJoy( joy )
	self.virtualJoy_ = joy
end

function HeroPlane:getVirtualJoy()
	return self.virtualJoy_
end

function HeroPlane:hasVirtualJoy()
	return self.virtualJoy_ ~= nil
end

function HeroPlane:fireBullet()
	--如果死掉时候不能发射子弹
	if self:isDead() then return end
	local scene = self:getParent():getParent()
	if scene and scene.onFireBullet then 
		if self:isCanFireBullet() then
			scene:onFireBullet(self:getBulletId())
			self:setLastFireTime(os.clock())
			isFireBullet = true
		end
	end
end

function HeroPlane:isCanFireBullet( ... )
	-- body
	local flag = false
	local time = os.clock()
	if time - self:getLastFireTime() >= self:getBulletCalmTime() then 
		flag = true
	end

	if not self:hasPower() then
		flag = false
	end

	return flag
end

--得到物品时候的回调函数
function HeroPlane:onGetItem(item)
	local id = item:getId()
	--1就升级
	if id == 1 then 
		--小于3才升级，否则
		if self:getLevel() < 3 then
			self:levelUp()
			--显示一个粒子特效
			local point = cc.p(self:getViewRect().width*0.5, self:getViewRect().height*0.8)
			Helper.showChangeParticle(self, point)
		else
			local score = 50
			GameData:getInstance():addScore( score ) 
		end
	--2就补血
	elseif id == 2 then
		local hp = item:getRecoverHp()
		self:addHp(hp)
	--3就增加炸弹
	elseif id == 3 then 
		local bombNum = item:getBombNum()
		GameData:getInstance():addBomb(bombNum)
	end
end

function HeroPlane:updateLogic(dt)
	allTime = allTime + dt

	--每秒加一个能量
	if allTime > self:getBulletCalmTime() then 
		allTime = 0
		self:fireBullet()
	end

	--如果有虚拟摇杆处理虚拟摇杆逻辑
	local joy = self:getVirtualJoy()
	if joy then 
		local strength = joy:getStrength()
		local length = cc.pGetLength(strength)
		local speed = cc.pMul(strength, length > 0.5 and 10 or 6)
		self:setSpeed(speed)
	end

end

--复写方法
function HeroPlane:step(dt)
	self:updateLogic(dt)

	local gameSpeed = GameData:getInstance():getGameSpeed()
	local posx, posy = self:getPosition()
	local pos = cc.p(posx, posy)
	if self.limitInScreen_ then 
		local nextPos = cc.p(pos.x + self.speed_.x * gameSpeed, pos.y + self.speed_.y * gameSpeed)
		if nextPos.x > LIMIT_RIGHT_X or nextPos.x < LIMIT_LEFT_X  then
			nextPos.x = posx
		end

		if nextPos.y > LIMIT_UP_Y or nextPos.y < LIMIT_DOWN_Y  then
			nextPos.y = posy
		end
		self:pos(nextPos)
	else
		self:posByY(self.speed_.y * gameSpeed)
		self:posByX(self.speed_.x * gameSpeed)

	end

end

--复活
function HeroPlane:relive()
	self:restoreOriginSprite()
	--3秒内无敌
	self.isRelive_ = true
	self:resetHp()
	self:resetPower()
	local act = cc.Sequence:create( cc.DelayTime:create( RELIVE_TIME ) , cc.CallFunc:create( function ( target )
		target.isRelive_ = false
	end ))	

	local sequence = cc.Sequence:create( cc.FadeOut:create(0.3), cc.FadeIn:create(0.2) )
	local hurtAct = cc.Repeat:create(sequence,  RELIVE_TIME / 0.5)
	self:runAction(act)
	self:runAction(hurtAct)
end

function HeroPlane:isRelive()
	return self.isRelive_
end

--角色升级
function HeroPlane:levelUp()
	--播放音效
	__G__levelUpSound()
	self:addLevel(1)
	self:updateAvatar()
	self:updateBullet()
end

function HeroPlane:updateBullet()
	local id = self:getId()
	local typeId = self:getBulletFireType()
	local fireTbl = { 
		{ 1,2, __G__isAndroid and 2 or 3 },
		{ 1,2,4	},
		{ 1,1,1 },
		{ 1,2,2 },
		{ 1,2,3 },
		{ 1,2,4 }

	 }
	local level = self:getLevel()
	local nextTypeId = fireTbl[id][level]
	if nextTypeId then 
		self:setBulletFireType(nextTypeId)
	end

	--update bullet time
	-- if id == 1 then
	-- 	local tbl = { 0.15, 0.2, 0.25 }
	-- 	local nextcalmTime = tbl[level]
	-- 	if nextcalmTime then
	-- 		self:setBulletCalmTime(nextcalmTime)
	-- 	end
	if id == 3 then
		local tbl = { 0.4, 0.2, 0.1 }
		local nextcalmTime = tbl[level]
		if nextcalmTime then
			self:setBulletCalmTime(nextcalmTime)
		end
	end
end

--更新角色服装
function HeroPlane:updateAvatar()
	local level = self:getLevel()
	local id = self:getId()
	--先看有没有图片模式
	local pattern = self:getFileFormat()
	if pattern then 
		local str = string.format(pattern, level)
		local frame = display.newSpriteFrame(str)
		self:setSpriteFrame(frame)
		return 
	end	

	pattern = self:getAnimationFormat()
	if pattern then 
		local str = string.format(pattern, level)
		self:playAnimation(str,1,4,-1)
		return 
	end
end

function HeroPlane:addLevel( num )
	self.level_ = self.level_ + num
end

function HeroPlane:getLevel()
	return self.level_
end

function HeroPlane:resetLevel()
	self.level_ = 1
end

function HeroPlane:accelerateEvent( x,y,z,timeStap )
	
end

function HeroPlane:onKeyPad( event )
	local code = event.keycode
	local target = event.target
	local eventtype = event.eventType
	if eventtype == "press" then
		if code == cc.KeyCode.KEY_A then 
			if self.virtualJoy_ then
				self.virtualJoy_:setStrength(cc.p( -1,0 ))
			end
		elseif code == cc.KeyCode.KEY_D then 
			if self.virtualJoy_ then
				self.virtualJoy_:setStrength(cc.p( 1,0 ))
			end
		elseif code == cc.KeyCode.KEY_S then
			if self.virtualJoy_ then
				self.virtualJoy_:setStrength(cc.p( 0,-1 ))
			end
		elseif code == cc.KeyCode.KEY_W then
			if self.virtualJoy_ then
				self.virtualJoy_:setStrength(cc.p( 0,1 ))
			end
		end

		if code == cc.KeyCode.KEY_SPACE then 
			self:fireBullet()
		end
	elseif eventtype == "release" then 
		if self.virtualJoy_ then
			self.virtualJoy_:setStrength(cc.p( 0,0 ))
		end
	end
end

--碰撞碰到敌人回调
function HeroPlane:onCollision(other )
	local damge = 1 
	if other and other.getDamge then
		damge = other:getDamge()
	end
	self:onHurt(damge)
	if self:isDead() then 
		--默认在上上层
		self:playDeadAnimation( "PlaneExplose%02d.png")
	end
	local scene = self:getParent():getParent()
	if scene and scene.onRoleHurt then
		scene:onRoleHurt(other)
	end
end

function HeroPlane:playDeadAnimation( fileFormat_ )
	if self.onDeadAni_ then return end 
	self.onDeadAni_ = true
	local ani = display.getAnimationCache("PlaneDeadAnimation")
	if not ani then 
		local frames = display.newFrames( fileFormat_, 1, 4, false )
		ani = display.newAnimation(frames, 0.3)
		display.setAnimationCache( "PlaneDeadAnimation", ani )
	end

	local act = cc.Sequence:create( cc.CallFunc:create( function ( target )
		local view = self:getParent():getParent()
		if view and view.onPlayerDead then 
			view:onPlayerDead( target )
		end

		self:hideGas()
	end ),cc.Animate:create( ani ), cc.Hide:create(), cc.CallFunc:create( function ( target )
		target.onDeadAni_ = false
	end ) )
	self:runAction(act)
end

--碰撞检测所用矩形
function HeroPlane:getCollisionRect(  )
	local rect = self:getBoundingBox()
	local finalWidth  = rect.width * 0.3 
	local finalHeight = rect.height * 0.3
	-- local pos = cc.p( rect.x+ rect.width*0.5-finalWidth*0.5, rect.y+rect.height*0.5-finalHeight*0.5 ) 
	local pos = cc.p(rect.x + rect.width*0.5-finalWidth*0.5 - 20,rect.y + rect.height*0.5-finalHeight*0.5)
	local newRect = cc.rect( pos.x, pos.y, finalWidth, finalHeight )
	return newRect
end

function HeroPlane:onHurt(hp_)
	--受伤过程不可再受伤
	if self.isOnHurt_ then return end
	self.super.onHurt(self,hp_)

	local sequence = cc.Sequence:create( cc.FadeOut:create(0.3), cc.FadeIn:create(0.2) )
	local act = cc.Repeat:create(sequence, 3)
	self:runAction(act)
	__G__actDelay(self, function (  )
		self.isOnHurt_ = false
	end, 1.5)
	self.isOnHurt_ = true
end

return HeroPlane