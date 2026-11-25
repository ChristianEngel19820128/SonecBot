
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoGrenadeLoad(ProtoGrenade ref as TProtoGrenade,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoGrenade.FromJson(ReadFileString(File))
		
		if ImageLoad(ProtoGrenade.AnimGrenade.Image) = TRUE
			SpriteLoad(ProtoGrenade.AnimGrenade)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeInit(GrenadeList ref as TGrenadeList)
	
	GrenadeList.Grenade.Length = -1
	GrenadeList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeNew(Grenade ref as TGrenade,ProtoGrenade ref as TProtoGrenade,World ref as TWorld,Position as TPosition,Angle as float,Radius as float,Now)
	
	Speed as TPosition
	
	Grenade.Enabled = TRUE
	TimeSet(Grenade.ObjectData.MoveTimer,10,10)
	TimeReset(Grenade.ObjectData.MoveTimer,Now)
	
	Grenade.ObjectData.Position = Position
	CalcPosition(Grenade.ObjectData.Position,Angle,Radius)
	Grenade.PreviousPosition = Grenade.ObjectData.Position
	
	Grenade.ObjectData.MoveSpeedMax.x = 3
	Grenade.ObjectData.MoveSpeedMax.y = 3
	
	Speed.x = 0
	Speed.y = 0
	CalcPosition(Speed,Angle,3)

	Grenade.ObjectData.MoveSpeed.x = Speed.x
	Grenade.ObjectData.MoveSpeed.y = Speed.y

	Grenade.ObjectData.MoveAcceleration.x = 0
	Grenade.ObjectData.MoveAcceleration.y = 1.5
	
	Grenade.ObjectData.MoveAlignment.x = 0
	Grenade.ObjectData.MoveAlignment.y = 0
	
	Grenade.SpriteData.Angle = Angle
	Grenade.SpriteData.Center = TRUE
	Grenade.SpriteData.Scale = 1
		
	ColorSet(Grenade.SpriteData.Color,255,255,255,255)
	
	Grenade.ObjectData.Size.Width = GetImageWidth(ProtoGrenade.AnimGrenade.Image.ID)*Grenade.SpriteData.Scale
	Grenade.ObjectData.Size.Height = GetImageHeight(ProtoGrenade.AnimGrenade.Image.ID)*Grenade.SpriteData.Scale

	if Grenade.ObjectData.Size.Width > Grenade.ObjectData.Size.Height
		Grenade.ObjectData.Radius = Grenade.ObjectData.Size.Width * 0.5
	else
		Grenade.ObjectData.Radius = Grenade.ObjectData.Size.Height * 0.5
	endif
	
	SpritePositionCalc(Grenade.SpriteData.Position,Grenade.ObjectData.Position,World.Position)
	
	Grenade.BulletData.BulletType = 1
	Grenade.BulletData.Damage = 5
	
	Grenade.CollisionData.Position1.x = Grenade.ObjectData.Position.x - Grenade.ObjectData.Size.Height * 0.5
	Grenade.CollisionData.Position1.y = Grenade.ObjectData.Position.y - Grenade.ObjectData.Size.Width  * 0.5
	Grenade.CollisionData.Position2.x = Grenade.ObjectData.Position.x + Grenade.ObjectData.Size.Height * 0.5
	Grenade.CollisionData.Position2.y = Grenade.ObjectData.Position.y + Grenade.ObjectData.Size.Width  * 0.5
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeAdd(GrenadeList ref as TGrenadeList,ProtoGrenade ref as TProtoGrenade,World ref as TWorld,Position as TPosition,Angle as float,Radius as float,Now as integer)
	
	local Found as integer
	local i as integer
	local Grenade as TGrenade
		
	GrenadeNew(Grenade,ProtoGrenade,World,Position,Angle,Radius,Now)
	
	Found = FALSE
	i = GrenadeList.FirstFree
	while Found = FALSE and i <= GrenadeList.Grenade.Length
		if GrenadeList.Grenade[i].Enabled = FALSE
			Found = TRUE
		else
			i = i+1
		endif
	endwhile
	
	if Found = FALSE
		GrenadeList.Grenade.Insert(Grenade)
		GrenadeList.FirstFree = GrenadeList.Grenade.Length
	else
		GrenadeList.Grenade[i] = Grenade
		GrenadeList.FirstFree = i+1
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeDelete(GrenadeList ref as TGrenadeList,Index as integer)
	
	GrenadeList.Grenade[Index].Enabled = FALSE
	if GrenadeList.FirstFree > Index
		GrenadeList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeDestroy(GrenadeList ref as TGrenadeList,Index as integer,ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion,Game ref as TGame,Position ref as TPosition,Now as integer)

	if GrenadeList.Grenade[Index].Enabled = FALSE then exitfunction
	GrenadeDelete(GrenadeList,Index)
	ExplosionAdd(ExplosionList,ProtoExplosion,Game,1,Position,Now)

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Preserve the existing horizontal grenade AABB (image height on X).
function GrenadeBoxEntry(Grenade ref as TGrenade,MinPos as TPosition,MaxPos as TPosition)
    local Entry as float
    Entry = CollisionBoxSweepEntry(Grenade.PreviousPosition,Grenade.ObjectData.Position,MinPos,MaxPos,Grenade.ObjectData.Size.Height*0.5,Grenade.ObjectData.Size.Width*0.5)
endfunction Entry

function GrenadeCircleEntry(Grenade ref as TGrenade,Center as TPosition,Radius as float)
    local Entry as float
    Entry = CollisionCircleSweepEntry(Grenade.PreviousPosition,Grenade.ObjectData.Position,Center,Radius+Grenade.ObjectData.Radius)
endfunction Entry

// Sweep against the same 2px sampled target footprint used by FlarakAreaHits.
// A swept rectangle against each sampled point avoids skipping a target
// between projectile positions without altering the approved silo geometry.
function GrenadeFlarakEntry(Grenade ref as TGrenade,F ref as TFlarak,World ref as TWorld)
    local MinPos as TPosition
    local MaxPos as TPosition
    local P as TPosition
    local IX as integer
    local IY as integer
    local Entry as float
    local Best as float
    if F.Enabled = FALSE or F.Destroyed = TRUE or F.CurrentFrame <= 1 then exitfunction -1.0
    MinPos.x = F.WorldX-46
    MinPos.y = F.WorldY-56
    MaxPos.x = F.WorldX+46
    MaxPos.y = F.WorldY+40
    if GrenadeBoxEntry(Grenade,MinPos,MaxPos) < 0 then exitfunction -1.0
    Best = 2
    for IX = -23 to 23
        P.x = F.WorldX+IX*2
        for IY = -28 to 20
            P.y = F.WorldY+IY*2
            Entry = GrenadeBoxEntry(Grenade,P,P)
            if Entry >= 0 and Entry < Best
                if FlarakPointHits(F,World,P.x,P.y) then Best = Entry
            endif
        next IY
    next IX
    if Best <= 1 then exitfunction Best
endfunction -1.0

// One earliest hit over every existing grenade target type. Stable tie order
// retains legacy priority (bomb, rocket, orb, mines, chest, walker, drone,
// Flak/Flarak, pod, plate, bomber). No damage while collecting candidates.
function GrenadeCollideAll(Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    local Entry as float
    local BestEntry as float
    local BestType as integer
    local BestIndex as integer
    local Damage as integer
    local P as TPosition
    local MinPos as TPosition
    local MaxPos as TPosition
    local Impact as TPosition
    for i = 0 to Game.GrenadeList.Grenade.Length
        if Game.GrenadeList.Grenade[i].Enabled = TRUE
            BestEntry = 2
            BestType = 0
            BestIndex = -1
            for k = 0 to BOMBER_BOMB_COUNT-1
                if Game.Bomber.Bomb[k].Enabled = TRUE
                    Entry = GrenadeCircleEntry(Game.GrenadeList.Grenade[i],Game.Bomber.Bomb[k].Position,BOMBER_BOMB_SHOT_RADIUS)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 1
                        BestIndex = k
                    endif
                endif
            next k
            for k = 0 to FlarakList.Length
                if FlarakList[k].Rocket1.Active = TRUE
                    P.x = FlarakList[k].Rocket1.PosX
                    P.y = FlarakList[k].Rocket1.PosY
                    Entry = GrenadeCircleEntry(Game.GrenadeList.Grenade[i],P,FLARAK_ROCKET_SHOT_RADIUS)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 2
                        BestIndex = k
                    endif
                endif
                if FlarakList[k].Rocket2.Active = TRUE
                    P.x = FlarakList[k].Rocket2.PosX
                    P.y = FlarakList[k].Rocket2.PosY
                    Entry = GrenadeCircleEntry(Game.GrenadeList.Grenade[i],P,FLARAK_ROCKET_SHOT_RADIUS)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 3
                        BestIndex = k
                    endif
                endif
            next k
            for k = 0 to Game.OrbList.Orb.Length
                if Game.OrbList.Orb[k].Enabled = TRUE
                    Entry = GrenadeBoxEntry(Game.GrenadeList.Grenade[i],Game.OrbList.Orb[k].CollisionData.Position1,Game.OrbList.Orb[k].CollisionData.Position2)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 4
                        BestIndex = k
                    endif
                endif
            next k
            for k = 0 to Game.MineList.Mine.Length
                if Game.MineList.Mine[k].Enabled = TRUE
                    Entry = GrenadeCircleEntry(Game.GrenadeList.Grenade[i],Game.MineList.Mine[k].ObjectData.Position,Game.MineList.Mine[k].ObjectData.Radius)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 5
                        BestIndex = k
                    endif
                endif
            next k
            for k = 0 to Game.SimpleMineList.Mine.Length
                if Game.SimpleMineList.Mine[k].Enabled = TRUE
                    Entry = GrenadeCircleEntry(Game.GrenadeList.Grenade[i],Game.SimpleMineList.Mine[k].ObjectData.Position,Game.SimpleMineList.Mine[k].ObjectData.Radius)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 6
                        BestIndex = k
                    endif
                endif
            next k
            for k = 0 to Game.ChestList.Chest.Length
                if Game.ChestList.Chest[k].Enabled = TRUE
                    Entry = GrenadeBoxEntry(Game.GrenadeList.Grenade[i],Game.ChestList.Chest[k].CollisionData.Position1,Game.ChestList.Chest[k].CollisionData.Position2)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 7
                        BestIndex = k
                    endif
                endif
            next k
            for k = 0 to Game.WalkerList.Walker.Length
                if Game.WalkerList.Walker[k].Enabled = TRUE
                    Entry = GrenadeBoxEntry(Game.GrenadeList.Grenade[i],Game.WalkerList.Walker[k].WalkerCollisionData.Tower.Position1,Game.WalkerList.Walker[k].WalkerCollisionData.Tower.Position2)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 8
                        BestIndex = k
                    endif
                endif
            next k
            if Game.Drone.Enabled = TRUE
                MinPos.x = Game.Drone.Position.x-23
                MinPos.y = Game.Drone.Position.y-15
                MaxPos.x = Game.Drone.Position.x+23
                MaxPos.y = Game.Drone.Position.y+15
                Entry = GrenadeBoxEntry(Game.GrenadeList.Grenade[i],MinPos,MaxPos)
                if Entry >= 0 and Entry < BestEntry
                    BestEntry = Entry
                    BestType = 9
                    BestIndex = -1
                endif
            endif
            for k = 0 to FlarakList.Length
                if FlarakList[k].Enabled = TRUE and FlarakList[k].Destroyed = FALSE
                    Entry = GrenadeFlarakEntry(Game.GrenadeList.Grenade[i],FlarakList[k],Game.World)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 10
                        BestIndex = k
                    endif
                endif
            next k
            for k = 0 to JumppodList.Length
                if JumppodList[k].Enabled = TRUE
                    Entry = GrenadeBoxEntry(Game.GrenadeList.Grenade[i],JumppodList[k].Lower.CollisionData.Position1,JumppodList[k].Lower.CollisionData.Position2)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 11
                        BestIndex = k
                    endif
                    Entry = GrenadeBoxEntry(Game.GrenadeList.Grenade[i],JumppodList[k].Upper.CollisionData.Position1,JumppodList[k].Upper.CollisionData.Position2)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 11
                        BestIndex = k
                    endif
                endif
            next k
            for k = 0 to Game.PlateList.Plate.Length
                if Game.PlateList.Plate[k].Enabled = TRUE
                    Entry = GrenadeBoxEntry(Game.GrenadeList.Grenade[i],Game.PlateList.Plate[k].CollisionData.Position1,Game.PlateList.Plate[k].CollisionData.Position2)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 12
                        BestIndex = k
                    endif
                endif
            next k
            if Game.Bomber.Enabled = TRUE
                MinPos.x = Game.Bomber.Position.x-BOMBER_HIT_HALF_WIDTH
                MinPos.y = Game.Bomber.Position.y-BOMBER_HIT_HALF_HEIGHT
                MaxPos.x = Game.Bomber.Position.x+BOMBER_HIT_HALF_WIDTH
                MaxPos.y = Game.Bomber.Position.y+BOMBER_HIT_HALF_HEIGHT
                Entry = GrenadeBoxEntry(Game.GrenadeList.Grenade[i],MinPos,MaxPos)
                if Entry >= 0 and Entry < BestEntry
                    BestEntry = Entry
                    BestType = 13
                    BestIndex = -1
                endif
            endif
            if BestType > 0
                Impact.x = Game.GrenadeList.Grenade[i].PreviousPosition.x+(Game.GrenadeList.Grenade[i].ObjectData.Position.x-Game.GrenadeList.Grenade[i].PreviousPosition.x)*BestEntry
                Impact.y = Game.GrenadeList.Grenade[i].PreviousPosition.y+(Game.GrenadeList.Grenade[i].ObjectData.Position.y-Game.GrenadeList.Grenade[i].PreviousPosition.y)*BestEntry
                Damage = Game.GrenadeList.Grenade[i].BulletData.Damage
                // Interception retains the existing single target explosion,
                // not an additional grenade blast.
                if BestType = 1
                    P = Game.Bomber.Bomb[BestIndex].Position
                    Game.Bomber.Bomb[BestIndex].Enabled = FALSE
                    GrenadeDelete(Game.GrenadeList,i)
                    ExplosionAdd(Game.ExplosionList,Game.ProtoExplosion,Game,1,P,Now)
                endif
                if BestType = 2
                    FlarakRocketIntercept(FlarakList[BestIndex].Rocket1,Game,Now)
                    FlarakMarkFree(BestIndex)
                    GrenadeDelete(Game.GrenadeList,i)
                endif
                if BestType = 3
                    FlarakRocketIntercept(FlarakList[BestIndex].Rocket2,Game,Now)
                    FlarakMarkFree(BestIndex)
                    GrenadeDelete(Game.GrenadeList,i)
                endif
                if BestType = 4
                    Game.OrbList.Orb[BestIndex].Health.State = Game.OrbList.Orb[BestIndex].Health.State-Damage
                    ColorSet(Game.OrbList.Orb[BestIndex].SpriteData.Color,255,0,0,255)
                endif
                if BestType = 5
                    Game.MineList.Mine[BestIndex].Health.State = Game.MineList.Mine[BestIndex].Health.State-Damage
                    ColorSet(Game.MineList.Mine[BestIndex].SpriteData.Color,255,0,0,255)
                endif
                if BestType = 6
                    Game.SimpleMineList.Mine[BestIndex].Health.State = Game.SimpleMineList.Mine[BestIndex].Health.State-Damage
                    ColorSet(Game.SimpleMineList.Mine[BestIndex].SpriteData.Color,255,0,0,255)
                endif
                if BestType = 7
                    Game.ChestList.Chest[BestIndex].Health.State = Game.ChestList.Chest[BestIndex].Health.State-Damage
                    ColorSet(Game.ChestList.Chest[BestIndex].SpriteData.Color,255,0,0,255)
                endif
                if BestType = 8
                    Game.WalkerList.Walker[BestIndex].Health.State = Game.WalkerList.Walker[BestIndex].Health.State-Damage
                    Game.WalkerList.Walker[BestIndex].HitFlashUntil = Now+150
                    ColorSet(Game.WalkerList.Walker[BestIndex].WalkerSpriteData.Tower.Color,255,0,0,255)
                endif
                if BestType = 9 then DroneTakeDamage(Game.Drone,Damage)
                if BestType = 10 then FlarakApplyDamage(FlarakList[BestIndex],Game,Damage,Now)
                if BestType = 11 then JumppodApplyDamage(BestIndex,Game,Damage,Now)
                if BestType = 13 then BomberTakeDamage(Game.Bomber,Game,Damage,Now)
                if BestType >= 4
                    GrenadeDestroy(Game.GrenadeList,i,Game.ExplosionList,Game.ProtoExplosion,Game,Impact,Now)
                endif
            endif
        endif
    next i
endfunction

function GrenadeMove(Grenade ref as TGrenade,World ref as TWorld,Now as integer)

	if Grenade.Enabled = TRUE
		Grenade.PreviousPosition = Grenade.ObjectData.Position
		if TimeGet(Grenade.ObjectData.MoveTimer,Now) > 0
			
			
			
			Grenade.ObjectData.MoveAcceleration.y = Grenade.ObjectData.MoveAcceleration.y^2
			
			if Grenade.ObjectData.MoveSpeed.y + Grenade.ObjectData.MoveAcceleration.y*0.00025 < Grenade.ObjectData.MoveSpeedMax.y
				Grenade.ObjectData.MoveSpeed.y = Grenade.ObjectData.MoveSpeed.y + Grenade.ObjectData.MoveAcceleration.y*0.00025
			endif
			
			Grenade.ObjectData.Position.x = Grenade.ObjectData.Position.x + Grenade.ObjectData.MoveSpeed.x * Grenade.ObjectData.MoveTimer.CalcRange
			Grenade.ObjectData.Position.y = Grenade.ObjectData.Position.y + Grenade.ObjectData.MoveSpeed.y * Grenade.ObjectData.MoveTimer.CalcRange
			
			SpritePositionCalc(Grenade.SpriteData.Position,Grenade.ObjectData.Position,World.Position)
			
			Grenade.CollisionData.Position1.x = Grenade.ObjectData.Position.x - Grenade.ObjectData.Size.Height * 0.5
			Grenade.CollisionData.Position1.y = Grenade.ObjectData.Position.y - Grenade.ObjectData.Size.Width  * 0.5
			Grenade.CollisionData.Position2.x = Grenade.ObjectData.Position.x + Grenade.ObjectData.Size.Height * 0.5
			Grenade.CollisionData.Position2.y = Grenade.ObjectData.Position.y + Grenade.ObjectData.Size.Width  * 0.5
			
			TimeReset(Grenade.ObjectData.MoveTimer,Now)
			
		endif
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeMoveAll(GrenadeList ref as TGrenadeList,World ref as TWorld,Now as integer)
	local i as integer
	for i = 0 to GrenadeList.Grenade.Length
		GrenadeMove(GrenadeList.Grenade[i],World,Now)
	next i
endfunction

// Cull only after testing the complete final movement segment.
function GrenadeCullAll(GrenadeList ref as TGrenadeList,World ref as TWorld)

	Local i as integer
	
	for i = 0 to GrenadeList.Grenade.Length
		if GrenadeList.Grenade[i].Enabled = TRUE
			if GrenadeList.Grenade[i].ObjectData.Position.y < -GrenadeList.Grenade[i].ObjectData.Size.Height
				GrenadeDelete(GrenadeList,i)
			else
				if GrenadeList.Grenade[i].ObjectData.Position.y > World.Size.Height+GrenadeList.Grenade[i].ObjectData.Size.Height
					GrenadeDelete(GrenadeList,i)
				else
					if GrenadeList.Grenade[i].ObjectData.Position.x > World.Size.Width+GrenadeList.Grenade[i].ObjectData.Size.Width
						GrenadeDelete(GrenadeList,i)
					else
						if GrenadeList.Grenade[i].ObjectData.Position.x < -GrenadeList.Grenade[i].ObjectData.Size.Width
							GrenadeDelete(GrenadeList,i)
						endif
					endif
				endif
			endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeDraw(Grenade ref as TGrenade,ProtoGrenade ref as TProtoGrenade)

	if Grenade.Enabled = TRUE
		SpriteDraw(ProtoGrenade.AnimGrenade.Sprite,Grenade.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeDrawAll(GrenadeList ref as TGrenadeList,ProtoGrenade ref as TProtoGrenade)
	
	local i as integer
	
	for i = 0 to GrenadeList.Grenade.Length
		GrenadeDraw(GrenadeList.Grenade[i],ProtoGrenade)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeCountAll(GrenadeList ref as TGrenadeList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to GrenadeList.Grenade.Length
		if GrenadeList.Grenade[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------






