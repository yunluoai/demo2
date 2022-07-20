--[[--
    ResultView.lua
    战斗结算界面
]]
local ResultView = class("ResultView", function()
    return display.newColorLayer(cc.c4b(0, 0, 0, 0))
end)
local FightConstDef = require("src.app.def.FightConstDef")
local scheduler = require("framework.scheduler")
local Card1 = require("src.app.data.card.Card1")
local Card2 = require("src.app.data.card.Card2")
--[[--
    构造函数

    @param none

    @return none
]]
function ResultView:ctor()

    local card1 = Card1.new(0,0)
    local card2 = Card2.new(0,0)
    self.bgScaleFactorX_ = 1 -- 类型：number，背景缩放系数
    self.bgScaleFactorY_ = 1 -- 类型：number，背景缩放系数
    self.state_ = 1
    self.cnt_ = 0

    self.isWin_ = true -- 己方是否胜利

    self.emenyCardGroup_ = {card1,card1,card1,card1,card1} -- 类型 card数组 敌方卡组
    self.enemyName_ = "robot" --类型 string 敌方名字
    self.emenyPlayerlevel_ = nil --敌方段位
    self.emenytrophyNum_ = 1 --敌方奖杯数量

    self.cardGroup_ = {card2,card2,card2,card2,card2} --自己卡组
    self.name_ = "me" --类型 string 己方名字
    self.playerlevel_ = nil --己方段位
    self.trophyNum_ = 2 --己方奖杯数量

    self.baseAwards_ = {1, 2} -- 胜利后结算时第一行，基本奖励，{奖杯数量，金币数量}
    self.winningStreakAwards_ = {2, 3} -- 胜利后结算第二行，连胜奖励，{奖杯数量，金币数量}
    self.buffAwards_ = {1, 2, 3} -- 胜利后结算第二行，特殊奖励，{奖杯数量，金币数量，钻石数量}

    self:initView()
end

--[[--
    界面初始化

    @param none

    @return none
]]
function ResultView:initView()

    self.container_ = ccui.Layout:create()
    self.container_:setContentSize(display.width, display.height)
    self.container_:setAnchorPoint(0.5, 0.5)
    self.container_:setPosition(display.width/2, display.height/2)
    self.container_:setBackGroundColor(cc.c3b(0, 0, 0))
    self.container_:setBackGroundColorType(1)
    self.container_:setCascadeOpacityEnabled(false) -- 穿透
    self.container_:setOpacity(0.8 * 255)
    self:addChild(self.container_)


    local loser, winner = {}, {}
    if self.isWin_ then
        winner.cardGroup =  self.cardGroup_
        winner.name = self.name_
        winner.playerlevel = self.playerlevel_
        winner.trophyNum = self.trophyNum_

        loser.cardGroup =  self.emenyCardGroup_
        loser.name = self.enemyName_
        loser.playerlevel = self.emenyPlayerlevel_
        loser.trophyNum = self.emenytrophyNum_
    else
        winner.cardGroup =  self.emenyCardGroup_
        winner.name = self.enemyName_
        winner.playerlevel = self.emenyPlayerlevel_
        winner.trophyNum = self.emenytrophyNum_

        loser.cardGroup =  self.cardGroup_
        loser.name = self.name_
        loser.playerlevel = self.playerlevel_
        loser.trophyNum = self.trophyNum_
    end


    --失败方层
    local loserLayer = display.newLayer()
    self.container_:addChild(loserLayer)

    local fail_bg = ccui.Layout:create()
    fail_bg:setBackGroundImage("image/fight/result/fail_bg.png")
    fail_bg:setAnchorPoint(0.5, 0.5)
    fail_bg:setPosition(display.cx, display.cy+380)
    -- loserLayer:setScaleX(fail_bg:getContentSize().width / fail_bg:getContentSize().width * display.width)
    -- loserLayer:setScaleY(fail_bg:getContentSize().height / fail_bg:getContentSize().height * display.height)
    loserLayer:addChild(fail_bg)

    --失败方段位图标
    local enemyLevel = display.newSprite("image/fight/fight/my_mark_icon.png")
    enemyLevel:setScaleX(self.bgScaleFactorX_*FightConstDef.ENEMY_SIZE.INTEGRAL_SIZE_X/60)
    enemyLevel:setScaleY(self.bgScaleFactorY_*FightConstDef.ENEMY_SIZE.INTEGRAL_SIZE_Y/49)
    enemyLevel:setAnchorPoint(0.5, 0.5)
    enemyLevel:setPosition(display.left + 130, display.bottom + 1050)
    loserLayer:addChild(enemyLevel)

    --失败方名字层
    local enemyNameLayer = display.newLayer()

    local enemyName = cc.Label:createWithTTF(loser.name,"font/fzzchjw.ttf",FightConstDef.ENEMY_SIZE.NAME_SIZE)
    enemyName:setScaleX(self.bgScaleFactorX_)
    enemyName:setScaleY(self.bgScaleFactorY_)
    enemyName:setAnchorPoint(0.5, 0.5)
    enemyName:setPosition(display.left + 205, display.bottom + 1050)
    enemyName:enableOutline(cc.c4b(0, 0, 0, 255),1)

    local enemyNameBg = display.newSprite("image/fight/result/text_bg.png")
    enemyNameBg:setAnchorPoint(0.5, 0.5)
    enemyNameBg:setScaleX(enemyName:getContentSize().width / enemyNameBg:getContentSize().width + 0.02)
    enemyNameBg:setPosition(enemyName:getPosition())

    enemyNameLayer:addChild(enemyNameBg)
    enemyNameLayer:addChild(enemyName)
    loserLayer:addChild(enemyNameLayer)

    --失败方奖杯图标
    local trophyIcon = display.newSprite("image/fight/result/trophy_icon.png")
    trophyIcon:setAnchorPoint(0.5, 0.5)
    trophyIcon:setPosition(display.left + 500, display.bottom + 1050)
    loserLayer:addChild(trophyIcon)

    --失败方奖杯数量
    local trophyNumLayer = display.newLayer()

    local trophyNum = cc.Label:createWithTTF(tostring(loser.trophyNum),"font/fzzchjw.ttf",
        FightConstDef.ENEMY_SIZE.NAME_SIZE)
    trophyNum:setScaleX(self.bgScaleFactorX_)
    trophyNum:setScaleY(self.bgScaleFactorY_)
    trophyNum:setAnchorPoint(0.5, 0.5)
    trophyNum:setPosition(display.left + 580, display.bottom + 1050)
    trophyNum:enableOutline(cc.c4b(0, 0, 0, 255),1)

    local trophyNumBg = display.newSprite("image/fight/result/text_bg.png")
    trophyNumBg:setAnchorPoint(0.5, 0.5)
    trophyNumBg:setPosition(trophyNum:getPosition())

    trophyNumLayer:addChild(trophyNumBg)
    trophyNumLayer:addChild(trophyNum)
    loserLayer:addChild(trophyNumLayer)


    local loserSprites = {} -- 类型：Sprite数组 失败方卡片数组
    local cardx = 105
    for i =1,#loser.cardGroup do
        --失败方卡片的图片
        local sprite = display.newSprite(loser.cardGroup[i]:getSmallSpriteImg())
        sprite:setScaleX(self.bgScaleFactorX_*FightConstDef.ENEMY_SIZE.CARD_SIZE_X/100)
        sprite:setScaleY(self.bgScaleFactorY_*FightConstDef.ENEMY_SIZE.CARD_SIZE_Y/100)
        sprite:setAnchorPoint(0.0, 1.0)
        sprite:setPosition(cardx, display.top - 290)
        loserLayer:addChild(sprite)
        loserSprites[i] = sprite
        --失败方卡片的等级
        local sprite1 = display.newSprite(loser.cardGroup[i]:getLevelImg())
        sprite1:setScaleX(self.bgScaleFactorX_*1.2)
        sprite1:setScaleY(self.bgScaleFactorY_*1.2)
        sprite1:setAnchorPoint(0.5, 1.0)
        sprite1:setPosition(cardx + 0.45*self.bgScaleFactorX_*FightConstDef.ENEMY_SIZE.CARD_SIZE_X + 7,
            display.top - 365)
            loserLayer:addChild(sprite1)
            loserSprites[i+5] = sprite1
        --失败方卡片的攻击类型
        local sprite2 = display.newSprite(loser.cardGroup[i]:getTypeImg())
        sprite2:setScaleX(self.bgScaleFactorX_*FightConstDef.ENEMY_SIZE.CARD_TYPE_SIZE_X/34*1.2)
        sprite2:setScaleY(self.bgScaleFactorY_*FightConstDef.ENEMY_SIZE.CARD_TYPE_SIZE_X/42*1.2)
        sprite2:setAnchorPoint(1.0, 1.0)
        sprite2:setPosition(cardx + 0.9*self.bgScaleFactorX_*FightConstDef.ENEMY_SIZE.CARD_SIZE_X + 12,
            display.top - 290)
        cardx = cardx + self.bgScaleFactorX_*(FightConstDef.ENEMY_SIZE.CARD_SIZE_X  + 50)
        loserLayer:addChild(sprite2)
        loserSprites[i+10] = sprite2
    end

    -- self:performWithDelay(function()
    --     loserLayer:setPosition(100, 200)
    -- end, 1)



    --胜利方层
    local winLayer = display.newLayer()
    self.container_:addChild(winLayer)
    self.winLayer_ = winLayer

    local win_bg = ccui.Layout:create()
    win_bg:setBackGroundImage("image/fight/result/win_bg.png")
    win_bg:setAnchorPoint(0.5, 0.5)
    win_bg:setPosition(display.cx, display.cy-80)
    winLayer:addChild(win_bg)
    -- winLayer:setScaleX(win_bg:getContentSize().width / win_bg:getContentSize().width * display.width)
    -- winLayer:setScaleY(win_bg:getContentSize().height / win_bg:getContentSize().height * display.height)

    --胜利方段位图标
    local winLevel = display.newSprite("image/fight/fight/my_mark_icon.png")
    winLevel:setScaleX(self.bgScaleFactorX_*FightConstDef.ENEMY_SIZE.INTEGRAL_SIZE_X/60)
    winLevel:setScaleY(self.bgScaleFactorY_*FightConstDef.ENEMY_SIZE.INTEGRAL_SIZE_Y/49)
    winLevel:setAnchorPoint(0.5, 0.5)
    winLevel:setPosition(display.left + 130, display.bottom + 540)
    winLayer:addChild(winLevel)

    --胜利方名字层
    local winNameLayer = display.newLayer()

    local winName = cc.Label:createWithTTF(winner.name,"font/fzzchjw.ttf",FightConstDef.ENEMY_SIZE.NAME_SIZE)
    winName:setScaleX(self.bgScaleFactorX_)
    winName:setScaleY(self.bgScaleFactorY_)
    winName:setAnchorPoint(0.5, 0.5)
    winName:setPosition(display.left + 205, display.bottom + 540)
    winName:enableOutline(cc.c4b(0, 0, 0, 255),1)

    local winNameBg = display.newSprite("image/fight/result/text_bg.png")
    winNameBg:setAnchorPoint(0.5, 0.5)
    winNameBg:setScaleX(winName:getContentSize().width / winNameBg:getContentSize().width + 0.02)
    winNameBg:setPosition(winName:getPosition())

    winNameLayer:addChild(winNameBg)
    winNameLayer:addChild(winName)
    winLayer:addChild(winNameLayer)

    --胜利方奖杯图标
    local winTrophyIcon = display.newSprite("image/fight/result/trophy_icon.png")
    winTrophyIcon:setAnchorPoint(0.5, 0.5)
    winTrophyIcon:setPosition(display.left + 500, display.bottom + 540)
    winLayer:addChild(winTrophyIcon)

    --胜利方奖杯数量
    local winTrophyNumLayer = display.newLayer()

    local winTrophyNum = cc.Label:createWithTTF(tostring(winner.trophyNum),"font/fzzchjw.ttf",
        FightConstDef.ENEMY_SIZE.NAME_SIZE)
    winTrophyNum:setScaleX(self.bgScaleFactorX_)
    winTrophyNum:setScaleY(self.bgScaleFactorY_)
    winTrophyNum:setAnchorPoint(0.5, 0.5)
    winTrophyNum:setPosition(display.left + 580, display.bottom + 540)
    winTrophyNum:enableOutline(cc.c4b(0, 0, 0, 255),1)

    local winTrophyNumBg = display.newSprite("image/fight/result/text_bg.png")
    winTrophyNumBg:setAnchorPoint(0.5, 0.5)
    winTrophyNumBg:setPosition(winTrophyNum:getPosition())

    winTrophyNumLayer:addChild(winTrophyNumBg)
    winTrophyNumLayer:addChild(winTrophyNum)
    winLayer:addChild(winTrophyNumLayer)


    local winSprites = {} -- 类型：Sprite数组 胜利方卡片数组
    cardx = 105
    for i =1,#winner.cardGroup do
        --胜利方卡片的图片
        local sprite = display.newSprite(winner.cardGroup[i]:getSmallSpriteImg())
        sprite:setScaleX(self.bgScaleFactorX_*FightConstDef.ENEMY_SIZE.CARD_SIZE_X/100)
        sprite:setScaleY(self.bgScaleFactorY_*FightConstDef.ENEMY_SIZE.CARD_SIZE_Y/100)
        sprite:setAnchorPoint(0.0, 1.0)
        sprite:setPosition(cardx, display.top - 290 - 510)
        winLayer:addChild(sprite)
        winSprites[i] = sprite
        --胜利方卡片的等级
        local sprite1 = display.newSprite(winner.cardGroup[i]:getLevelImg())
        sprite1:setScaleX(self.bgScaleFactorX_*1.2)
        sprite1:setScaleY(self.bgScaleFactorY_*1.2)
        sprite1:setAnchorPoint(0.5, 1.0)
        sprite1:setPosition(cardx + 0.45*self.bgScaleFactorX_*FightConstDef.ENEMY_SIZE.CARD_SIZE_X + 7,
            display.top - 365 - 510)
            winLayer:addChild(sprite1)
            winSprites[i+5] = sprite1
        --胜利方卡片的攻击类型
        local sprite2 = display.newSprite(winner.cardGroup[i]:getTypeImg())
        sprite2:setScaleX(self.bgScaleFactorX_*FightConstDef.ENEMY_SIZE.CARD_TYPE_SIZE_X/34*1.2)
        sprite2:setScaleY(self.bgScaleFactorY_*FightConstDef.ENEMY_SIZE.CARD_TYPE_SIZE_X/42*1.2)
        sprite2:setAnchorPoint(1.0, 1.0)
        sprite2:setPosition(cardx + 0.9*self.bgScaleFactorX_*FightConstDef.ENEMY_SIZE.CARD_SIZE_X + 12,
            display.top - 290 - 510)
        cardx = cardx + self.bgScaleFactorX_*(FightConstDef.ENEMY_SIZE.CARD_SIZE_X  + 50)
        winLayer:addChild(sprite2)
        winSprites[i+10] = sprite2
    end


    if not self.isWin_ then
        winLayer:setPosition(loserLayer:getPositionX(), winLayer:getPositionY() + 490)
        loserLayer:setPosition(loserLayer:getPositionX(), loserLayer:getPositionY() - 490)
    end

    local confirmBtn = ccui.Button:create("image/fight/result/confirm_btn.png", "image/fight/result/confirm_btn.png")
    confirmBtn:setAnchorPoint(0.5, 0.5)
    confirmBtn:setScale9Enabled(true)
    confirmBtn:pos(display.cx,display.cy-420)
	confirmBtn:setTitleFontSize(20)
    confirmBtn:setPressedActionEnabled(true)
    confirmBtn:addTouchEventListener(function(sender, eventType)
        if 0 == eventType then
		end
		if 2 == eventType then
            if not self.isWin_ then
                -- 失败，不显示具体结算界面
                self:hideView()
            else
                -- 胜利，显示具体结算
                if self.state_ == 1 then
                    self.state_ = 2
                    loserLayer:hide()
                    self:performWithDelay(function()
                        self.awardsLayer_:show()
                    end, 0.3)
                end
            end

            if self.state_ == 3 then
                self:hideView()
            end
		end
	end)
    self.container_:addChild(confirmBtn)

    self.awardsLayer_ = display.newLayer() -- 胜利后的结算层
    -- 三个具体结算层
    local baseAwardIcon = display.newSprite("image/fight/result/base_award_icon.png")
    local winningStreakAwardIcon = display.newSprite("image/fight/result/winning_streak_award_icon.png")
    local buffAwardIcon = display.newSprite("image/fight/result/buff_award_icon.png")
    self.awardsLayer_:addChild(ResultView:newAwardLayer(baseAwardIcon, self.baseAwards_[1], self.baseAwards_[2], nil))
    local l2 = ResultView:newAwardLayer(winningStreakAwardIcon, self.winningStreakAwards_[1], self.winningStreakAwards_[2], nil)
    l2:setPositionY(l2:getPositionY()-60)
    self.awardsLayer_:addChild(l2)
    local l3 = ResultView:newAwardLayer(buffAwardIcon, self.buffAwards_[1], self.buffAwards_[2], self.buffAwards_[3])
    l3:setPositionY(l3:getPositionY()-120)
    self.awardsLayer_:addChild(l3)

    -- 总计结算层
    local totalLayer = display.newLayer()
    local awardTotalBg = display.newSprite("image/fight/result/award_totle_bg.png")
    awardTotalBg:pos(display.cx, display.cy - 270)
    totalLayer:addChild(awardTotalBg)
    local totalTxt = cc.Label:createWithTTF("总计","font/fzbiaozjw.ttf",
            30):pos(display.cx-260, awardTotalBg:getPositionY())
    totalTxt:enableOutline(cc.c4b(0, 0, 0, 255), 1) -- 2像素纯黑色描边
    totalLayer:addChild(totalTxt)
    local trophyIcon = display.newSprite("image/fight/result/trophy_icon.png")
        :pos(display.cx - 160, awardTotalBg:getPositionY())
    local goldIcon = display.newSprite("image/fight/result/gold_icon.png")
        :pos(display.cx , awardTotalBg:getPositionY())
    local diamondIcon = display.newSprite("image/fight/result/diamond_icon.png")
        :pos(display.cx + 160, awardTotalBg:getPositionY())
    totalLayer:addChild(trophyIcon)
    local trophyTotal = self.baseAwards_[1] + self.winningStreakAwards_[1] + self.buffAwards_[1]
    totalLayer:addChild(cc.Label:createWithTTF("+"..trophyTotal,"font/fzbiaozjw.ttf",
    FightConstDef.ENEMY_SIZE.NAME_SIZE):pos(display.cx-100, awardTotalBg:getPositionY()))
    totalLayer:addChild(goldIcon)
    local goldTotal = self.baseAwards_[2] + self.winningStreakAwards_[2] + self.buffAwards_[2]
    totalLayer:addChild(cc.Label:createWithTTF("+"..goldTotal,"font/fzbiaozjw.ttf",
        FightConstDef.ENEMY_SIZE.NAME_SIZE):pos(display.cx+60, awardTotalBg:getPositionY()))
    totalLayer:addChild(diamondIcon)
    totalLayer:addChild(cc.Label:createWithTTF("+"..self.buffAwards_[3],"font/fzbiaozjw.ttf",
        FightConstDef.ENEMY_SIZE.NAME_SIZE):pos(display.cx+220, awardTotalBg:getPositionY()))

    self.awardsLayer_:addChild(totalLayer)

    self.container_:addChild(self.awardsLayer_)
    self.awardsLayer_:hide()

    local listener = cc.EventListenerTouchOneByOne:create()
    self.listener_ = listener
    self.isListening_ = true
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
        if self.isListening_ then
            --返回true时，该层下面的层的触摸事件都会屏蔽掉
            return true
        end
        return false
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function ResultView:newAwardLayer(icon, trophy, gold, diamond)
    local awardIcon = icon
    local trophyIcon = display.newSprite("image/fight/result/trophy_icon.png")
    local goldIcon = display.newSprite("image/fight/result/gold_icon.png")
    local diamondIcon = display.newSprite("image/fight/result/diamond_icon.png")
    local awardBg = display.newSprite("image/fight/result/award_bg.png")
    local awardLayer = display.newLayer() 
    awardBg:pos(display.cx+30, 600)
    awardIcon:pos(display.cx-220, awardBg:getPositionY())
    trophyIcon:pos(display.cx-130, awardBg:getPositionY())
    goldIcon:pos(display.cx, awardBg:getPositionY())
    diamondIcon:pos(display.cx+130, awardBg:getPositionY())
    awardLayer:addChild(awardBg)
    awardLayer:addChild(awardIcon)
    awardLayer:addChild(trophyIcon)
    awardLayer:addChild(cc.Label:createWithTTF("+"..trophy,"font/fzbiaozjw.ttf",
        FightConstDef.ENEMY_SIZE.NAME_SIZE):pos(display.cx-80, awardBg:getPositionY()))
    awardLayer:addChild(goldIcon)
    awardLayer:addChild(cc.Label:createWithTTF("+"..gold,"font/fzbiaozjw.ttf",
        FightConstDef.ENEMY_SIZE.NAME_SIZE):pos(display.cx+50, awardBg:getPositionY()))
    if diamond ~= nil then
        awardLayer:addChild(diamondIcon)
        awardLayer:addChild(cc.Label:createWithTTF("+"..diamond,"font/fzbiaozjw.ttf",
            FightConstDef.ENEMY_SIZE.NAME_SIZE):pos(display.cx+170, awardBg:getPositionY()))
    end
    return awardLayer
end

--[[--
    隐藏界面

    @param none

    @return none
]]
function ResultView:hideView()
    self:setVisible(false)
    self.listener_:setSwallowTouches(false)
    self.isListening_ = false
end

--[[--
    显示界面

    @param none

    @return none
]]
function ResultView:showView()
    self:setVisible(true)
    self.listener_:setSwallowTouches(true)
    self.isListening_ = true
end


--[[--
    界面刷新

    @param dt 类型：number，帧间隔

    @return none
]]
function ResultView:update(dt)

    if self.state_ == 2 then
        self.cnt_ = self.cnt_ + dt
        if self.cnt_ < 0.2 then
            -- 胜利部分上移动画
            self.winLayer_:setPosition(self.winLayer_:getPositionX(), self.winLayer_:getPositionY()+30)
        else
            self.state_ = 3
        end
    end

end

return ResultView