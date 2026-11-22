
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Bullet modifications: normal ammunition remains the default for all existing callers.
#constant BULLET_MOD_STANDARD 0
#constant BULLET_MOD_EXPLOSIVE 1
#constant BULLET_EXPLOSIVE_FUSE_MIN_MS 450
#constant BULLET_EXPLOSIVE_FUSE_MAX_MS 1100
#constant BULLET_EXPLOSIVE_EXPLOSION_TYPE 3

function ProtoBulletLoad(ProtoBullet ref as TProtoBullet,File ref as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoBullet.FromJson(ReadFileString(File))
		
		if ImageLoad(ProtoBullet.AnimBullet.Image) = TRUE
			SpriteLoad(ProtoBullet.AnimBullet)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletInit(BulletList ref as TBulletList)
	
	BulletList.Bullet.Length = -1
	BulletList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// World-space AABB enclosing the sprite at its current rotation.
// For the old 90/270 degree shots this has the same bounds as before.
// It is not a swept segment test or pixel-perfect oriented collision.
function BulletCollisionBoundsCalculate(Bullet ref as TBullet)
	local HalfImageWidth as float
	local HalfImageHeight as float
	local ExtentX as float
	local ExtentY as float
	local c as float
	local sn as float

	HalfImageWidth = Bullet.ObjectData.Size.Width*0.5
	HalfImageHeight = Bullet.ObjectData.Size.Height*0.5
	c = Cos(Bullet.SpriteData.Angle)
	sn = Sin(Bullet.SpriteData.Angle)
	ExtentX = abs(HalfImageWidth*c) + abs(HalfImageHeight*sn)
	ExtentY = abs(HalfImageWidth*sn) + abs(HalfImageHeight*c)

	Bullet.CollisionData.Position1.x = Bullet.ObjectData.Position.x - ExtentX
	Bullet.CollisionData.Position1.y = Bullet.ObjectData.Position.y - ExtentY
	Bullet.CollisionData.Position2.x = Bullet.ObjectData.Position.x + ExtentX
	Bullet.CollisionData.Position2.y = Bullet.ObjectData.Position.y + ExtentY
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletNew(Bullet ref as TBullet,ProtoBullet ref as TProtoBullet,World ref as TWorld,Position ref as TPosition,Angle as float,Radius as float,CollisionType as integer,Now as integer)
	
	Speed as TPosition
	
	Bullet.Enabled = TRUE
	Bullet.Modification = BULLET_MOD_STANDARD
	Bullet.ExplodeAtMs = 0
	TimeSet(Bullet.ObjectData.MoveTimer,10,10)
	TimeReset(Bullet.ObjectData.MoveTimer,Now)
	
	Bullet.ObjectData.Position = Position
	CalcPosition(Bullet.ObjectData.Position,Angle,Radius)
	Bullet.PreviousPosition = Bullet.ObjectData.Position
	
	Bullet.ObjectData.MoveSpeedMax.x = 0
	Bullet.ObjectData.MoveSpeedMax.y = 0
	
	Speed.x = 0
	Speed.y = 0
	CalcPosition(Speed,Angle,3)

	Bullet.ObjectData.MoveSpeed.x = Speed.x
	Bullet.ObjectData.MoveSpeed.y = Speed.y

	Bullet.ObjectData.MoveAcceleration.x = 0
	Bullet.ObjectData.MoveAcceleration.y = 0
	
	Bullet.ObjectData.MoveAlignment.x = 0
	Bullet.ObjectData.MoveAlignment.y = 0
	
	Bullet.SpriteData.Angle = Angle
	Bullet.SpriteData.Center = TRUE
	Bullet.SpriteData.Scale = 1
		
	ColorSet(Bullet.SpriteData.Color,255,255,255,255)
	
	Bullet.ObjectData.Size.Width = GetImageWidth(ProtoBullet.AnimBullet.Image.ID)*Bullet.SpriteData.Scale
	Bullet.ObjectData.Size.Height = GetImageHeight(ProtoBullet.AnimBullet.Image.ID)*Bullet.SpriteData.Scale

	if Bullet.ObjectData.Size.Width > Bullet.ObjectData.Size.Height
		Bullet.ObjectData.Radius = Bullet.ObjectData.Size.Width * 0.5
	else
		Bullet.ObjectData.Radius = Bullet.ObjectData.Size.Height * 0.5
	endif
	
	SpritePositionCalc(Bullet.SpriteData.Position,Bullet.ObjectData.Position,World.Position)
	
	Bullet.CollisionData.CollisionType = CollisionType
	Bullet.BulletData.BulletType = 1
	Bullet.BulletData.Damage = 25
	
	BulletCollisionBoundsCalculate(Bullet)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletAdd(BulletList ref as TBulletList,ProtoBullet ref as TProtoBullet,World ref as TWorld,Position ref as TPosition,Angle as float,Radius as float,CollisionType as integer,Now as integer)
	
	local Found as integer
	local i as integer
	local Bullet as TBullet
		
	BulletNew(Bullet,ProtoBullet,World,Position,Angle,Radius,CollisionType,Now)
	
	Found = FALSE
	i = BulletList.FirstFree
	while Found = FALSE and i <= BulletList.Bullet.Length
		if BulletList.Bullet[i].Enabled = FALSE
			Found = TRUE
		else
			i = i+1
		endif
	endwhile
	
	if Found = FALSE
		BulletList.Bullet.Insert(Bullet)
		BulletList.FirstFree = BulletList.Bullet.Length
	else
		BulletList.Bullet[i] = Bullet
		BulletList.FirstFree = i+1
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Configure the bullet just appended by BulletAdd, without changing existing callers.
function BulletSetModification(BulletList ref as TBulletList,Modification as integer,Now as integer)
    local Index as integer
    Index = BulletList.FirstFree-1
    if Index < 0 or Index > BulletList.Bullet.Length then exitfunction
    if BulletList.Bullet[Index].Enabled = FALSE then exitfunction
    BulletList.Bullet[Index].Modification = Modification
    if Modification = BULLET_MOD_EXPLOSIVE
        BulletList.Bullet[Index].ExplodeAtMs = Now+Random(BULLET_EXPLOSIVE_FUSE_MIN_MS,BULLET_EXPLOSIVE_FUSE_MAX_MS)
    else
        BulletList.Bullet[Index].ExplodeAtMs = 0
    endif
endfunction

// Fuse detonations use the existing explosion system and its damage rules.
function BulletExplosiveFuses(BulletList ref as TBulletList,Game ref as TGame,Now as integer)
    local i as integer
    for i = 0 to BulletList.Bullet.Length
        if BulletList.Bullet[i].Enabled = TRUE and BulletList.Bullet[i].Modification = BULLET_MOD_EXPLOSIVE
            if Now >= BulletList.Bullet[i].ExplodeAtMs
                ExplosionAdd(Game.ExplosionList,Game.ProtoExplosion,Game,BULLET_EXPLOSIVE_EXPLOSION_TYPE,BulletList.Bullet[i].ObjectData.Position,Now)
                BulletDelete(BulletList,i)
            endif
        endif
    next i
endfunction

function BulletDelete(BulletList ref as TBulletList,Index as integer)
	
	BulletList.Bullet[Index].Enabled = FALSE
	if BulletList.FirstFree > Index
		BulletList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// K1d: two body circles are the active enemy-bullet hitbox.
// Change the switch to 0 to restore the proven K1c single-circle damage path.
#constant SONEC_TWO_CIRCLE_TEST 1
#constant SONEC_TWO_CIRCLE_DAMAGE 1
global SonecTwoCircleChecks as integer
global SonecTwoCircleBoth as integer
global SonecTwoCircleOldOnly as integer
global SonecTwoCircleNewOnly as integer
// F3 only controls the visible outlines; comparison remains active.
global SonecCollisionDebugVisible as integer
// Debug-only: track each circle independently; both can light up on one sweep.
#constant SONEC_COLLISION_DEBUG_HIT_MS 200
global SonecCollisionDebugHitUntil0 as integer
global SonecCollisionDebugHitUntil1 as integer

function BulletSweepHitsSonecCircle(Bullet ref as TBullet,CenterX as float,CenterY as float,Radius as float)
    local Dx as float
    local Dy as float
    local LengthSq as float
    local Projection as float
    local DeltaX as float
    local DeltaY as float
    Dx = Bullet.ObjectData.Position.x-Bullet.PreviousPosition.x
    Dy = Bullet.ObjectData.Position.y-Bullet.PreviousPosition.y
    LengthSq = Dx*Dx+Dy*Dy
    Projection = 0
    if LengthSq > 0
        Projection = ((CenterX-Bullet.PreviousPosition.x)*Dx+(CenterY-Bullet.PreviousPosition.y)*Dy)/LengthSq
        if Projection < 0 then Projection = 0
        if Projection > 1 then Projection = 1
    endif
    DeltaX = Bullet.PreviousPosition.x+Projection*Dx-CenterX
    DeltaY = Bullet.PreviousPosition.y+Projection*Dy-CenterY
endfunction DeltaX*DeltaX+DeltaY*DeltaY < Radius*Radius

function BulletSweepHitsSonecTwoCircles(Bullet ref as TBullet,Sonec ref as TSonec)
    local Radius as float
    local Hit as integer
    Radius = SonecHitCircleRadius(Sonec)
    Hit = FALSE
    if BulletSweepHitsSonecCircle(Bullet,Sonec.ObjectData.Position.x,SonecHitCircleY(Sonec,0),Radius) = TRUE then Hit = TRUE
    if BulletSweepHitsSonecCircle(Bullet,Sonec.ObjectData.Position.x,SonecHitCircleY(Sonec,1),Radius) = TRUE then Hit = TRUE
endfunction Hit

// K1c: check the whole last movement segment of an enemy bullet against
// Sonec's existing circle. Do not enlarge the hitbox by the bullet radius.
// A zero-length step is checked at its current position.
function BulletSweepHitsSonec(Bullet ref as TBullet,Sonec ref as TSonec)
    local Dx as float
    local Dy as float
    local LengthSq as float
    local Projection as float
    local ClosestX as float
    local ClosestY as float
    local DeltaX as float
    local DeltaY as float
    local RadiusSq as float
    local Hit as integer

    Hit = FALSE
    Dx = Bullet.ObjectData.Position.x - Bullet.PreviousPosition.x
    Dy = Bullet.ObjectData.Position.y - Bullet.PreviousPosition.y
    LengthSq = Dx*Dx + Dy*Dy
    Projection = 0
    if LengthSq > 0
        Projection = ((Sonec.ObjectData.Position.x-Bullet.PreviousPosition.x)*Dx + (Sonec.ObjectData.Position.y-Bullet.PreviousPosition.y)*Dy)/LengthSq
        if Projection < 0 then Projection = 0
        if Projection > 1 then Projection = 1
    endif

    ClosestX = Bullet.PreviousPosition.x + Projection*Dx
    ClosestY = Bullet.PreviousPosition.y + Projection*Dy
    DeltaX = ClosestX - Sonec.ObjectData.Position.x
    DeltaY = ClosestY - Sonec.ObjectData.Position.y
    RadiusSq = Sonec.ObjectData.Radius*Sonec.ObjectData.Radius
    if DeltaX*DeltaX + DeltaY*DeltaY < RadiusSq then Hit = TRUE
endfunction Hit

function BulletCollide(BulletList ref as TBulletList,Sonec ref as TSonec,Shield ref as TShield,Game ref as TGame,Now as integer)
    local i as integer

    for i = 0 to BulletList.Bullet.Length
        if BulletList.Bullet[i].Enabled = TRUE
            if BulletList.Bullet[i].CollisionData.CollisionType = TYPEENEMY
                local OldHit as integer
                local NewHit as integer
                local DamageHit as integer
                OldHit = FALSE
                NewHit = FALSE
                DamageHit = FALSE
                if SONEC_TWO_CIRCLE_TEST = 1
                    OldHit = BulletSweepHitsSonec(BulletList.Bullet[i],Sonec)
                    NewHit = BulletSweepHitsSonecTwoCircles(BulletList.Bullet[i],Sonec)
                    SonecTwoCircleChecks = SonecTwoCircleChecks+1
                    if OldHit = TRUE and NewHit = TRUE then SonecTwoCircleBoth = SonecTwoCircleBoth+1
                    if OldHit = TRUE and NewHit = FALSE then SonecTwoCircleOldOnly = SonecTwoCircleOldOnly+1
                    if OldHit = FALSE and NewHit = TRUE then SonecTwoCircleNewOnly = SonecTwoCircleNewOnly+1
                endif
                if SONEC_TWO_CIRCLE_DAMAGE = 1 and SONEC_TWO_CIRCLE_TEST = 1
                    DamageHit = NewHit
                else
                    if SONEC_TWO_CIRCLE_TEST = 1
                        DamageHit = OldHit
                    else
                        DamageHit = BulletSweepHitsSonec(BulletList.Bullet[i],Sonec)
                    endif
                endif
                if DamageHit = TRUE
                    // Diagnostic only: identify which body circle(s) the active sweep touched.
                    if SONEC_TWO_CIRCLE_TEST = 1 and SONEC_TWO_CIRCLE_DAMAGE = 1
                        local DebugRadius as float
                        local DebugHitUntil as integer
                        DebugRadius = SonecHitCircleRadius(Sonec)
                        DebugHitUntil = GetMilliseconds() + SONEC_COLLISION_DEBUG_HIT_MS
                        if BulletSweepHitsSonecCircle(BulletList.Bullet[i],Sonec.ObjectData.Position.x,SonecHitCircleY(Sonec,0),DebugRadius) = TRUE
                            SonecCollisionDebugHitUntil0 = DebugHitUntil
                        endif
                        if BulletSweepHitsSonecCircle(BulletList.Bullet[i],Sonec.ObjectData.Position.x,SonecHitCircleY(Sonec,1),DebugRadius) = TRUE
                            SonecCollisionDebugHitUntil1 = DebugHitUntil
                        endif
                    endif
                    // Keep the established proportional shield protection and health damage.
                    local HealthBeforeHit as integer
                    HealthBeforeHit = Sonec.Health.State
                    Sonec.Health.State = Sonec.Health.State - (BulletList.Bullet[i].BulletData.Damage - ShieldAbsorbDamage(Shield,Sonec,BulletList.Bullet[i].BulletData.Damage,Now))
                    if Sonec.Health.State < HealthBeforeHit then SonecHitFlashUntil = Now + SONEC_HIT_FLASH_MS
                    BulletDelete(BulletList,i)
                endif
            endif
        endif
    next i
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletCollideOrbs(BulletList ref as TBulletList,OrbList ref as TOrbList)
	
	local i as integer
	local k as integer
	local Radius as float
	
	for i = 0 to BulletList.Bullet.Length
		// Orbs are player-only targets: enemy bullets must never destroy rewards.
		if BulletList.Bullet[i].Enabled = TRUE and BulletList.Bullet[i].CollisionData.CollisionType = TYPEPLAYERONE
			for k = 0 to OrbList.Orb.Length
				if OrbList.Orb[k].Enabled = TRUE
					if BoxInBox(BulletList.Bullet[i].CollisionData.Position1,BulletList.Bullet[i].CollisionData.Position2,OrbList.Orb[k].CollisionData.Position1,OrbList.Orb[k].CollisionData.Position2)
						OrbList.Orb[k].Health.State = OrbList.Orb[k].Health.State - BulletList.Bullet[i].BulletData.Damage
						BulletDelete(BulletList,i)
						ColorSet(OrbList.Orb[k].SpriteData.Color,255,0,0,255)
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletCollideWalkers(BulletList ref as TBulletList,WalkerList ref as TWalkerList,Now as integer)
	local i as integer
	local k as integer
	for i = 0 to BulletList.Bullet.Length
		// Enemy bullets must not damage Walkers; only player bullets hit their turret.
		if BulletList.Bullet[i].Enabled = TRUE and BulletList.Bullet[i].CollisionData.CollisionType = TYPEPLAYERONE
			for k = 0 to WalkerList.Walker.Length
				if WalkerList.Walker[k].Enabled = TRUE and BulletList.Bullet[i].Enabled = TRUE
					if BoxInBox(BulletList.Bullet[i].CollisionData.Position1,BulletList.Bullet[i].CollisionData.Position2,WalkerList.Walker[k].WalkerCollisionData.Tower.Position1,WalkerList.Walker[k].WalkerCollisionData.Tower.Position2)
						WalkerList.Walker[k].Health.State = WalkerList.Walker[k].Health.State - BulletList.Bullet[i].BulletData.Damage
						WalkerList.Walker[k].HitFlashUntil = Now + 150
						ColorSet(WalkerList.Walker[k].WalkerSpriteData.Tower.Color,255,0,0,255)
						BulletDelete(BulletList,i)
					endif
				endif
			next k
		endif
	next i
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// K1: earliest contact along the bullet's last movement segment against
// a stationary mine circle at the currently sampled position.
// Returns -1 on miss, otherwise entry fraction [0,1] for nearest-hit ordering.
// No hitbox enlargement: retain the existing bullet + mine radii.
function BulletMineSweepEntry(Bullet ref as TBullet,Mine ref as TMine)
    local Dx as float
    local Dy as float
    local StartX as float
    local StartY as float
    local Radius as float
    local RadiusSq as float
    local DistanceSq as float
    local LengthSq as float
    local Projection as float
    local ClosestSq as float
    local Chord as float
    local Entry as float

    Entry = -1
    Radius = Bullet.ObjectData.Radius + Mine.ObjectData.Radius
    RadiusSq = Radius*Radius
    StartX = Bullet.PreviousPosition.x - Mine.ObjectData.Position.x
    StartY = Bullet.PreviousPosition.y - Mine.ObjectData.Position.y
    DistanceSq = StartX*StartX + StartY*StartY

    if DistanceSq <= RadiusSq
        // Already overlapping at the start of this step.
        Entry = 0
    else
        Dx = Bullet.ObjectData.Position.x - Bullet.PreviousPosition.x
        Dy = Bullet.ObjectData.Position.y - Bullet.PreviousPosition.y
        LengthSq = Dx*Dx + Dy*Dy
        if LengthSq > 0
            Projection = -(StartX*Dx + StartY*Dy)/LengthSq
            if Projection >= 0 and Projection <= 1
                ClosestSq = DistanceSq - Projection*Projection*LengthSq
                if ClosestSq <= RadiusSq
                    Chord = sqrt((RadiusSq-ClosestSq)/LengthSq)
                    Entry = Projection - Chord
                    if Entry < 0 then Entry = 0
                endif
            else
                // Center of closest approach may lie past the endpoint.
                if Projection > 1
                    StartX = Bullet.ObjectData.Position.x - Mine.ObjectData.Position.x
                    StartY = Bullet.ObjectData.Position.y - Mine.ObjectData.Position.y
                    if StartX*StartX + StartY*StartY <= RadiusSq then Entry = 1
                endif
            endif
        endif
    endif
endfunction Entry

// K1b: earliest intersection of a moving bullet center with an AABB.
// The bullet radius expands the target bounds; this is a conservative
// swept-circle/AABB approximation, not a pixel-perfect sprite collision.
// Return -1 for a miss or the first segment entry fraction [0,1].
function BulletBoxSweepEntry(Bullet ref as TBullet,BoxMin ref as TPosition,BoxMax ref as TPosition)
    local Dx as float
    local Dy as float
    local MinX as float
    local MaxX as float
    local MinY as float
    local MaxY as float
    local NearTime as float
    local FarTime as float
    local AxisNear as float
    local AxisFar as float
    local Temp as float
    local Entry as float

    Entry = -1
    MinX = BoxMin.x - Bullet.ObjectData.Radius
    MaxX = BoxMax.x + Bullet.ObjectData.Radius
    MinY = BoxMin.y - Bullet.ObjectData.Radius
    MaxY = BoxMax.y + Bullet.ObjectData.Radius
    Dx = Bullet.ObjectData.Position.x - Bullet.PreviousPosition.x
    Dy = Bullet.ObjectData.Position.y - Bullet.PreviousPosition.y
    NearTime = 0
    FarTime = 1

    if Dx = 0
        if Bullet.PreviousPosition.x < MinX or Bullet.PreviousPosition.x > MaxX then exitfunction Entry
    else
        AxisNear = (MinX-Bullet.PreviousPosition.x)/Dx
        AxisFar = (MaxX-Bullet.PreviousPosition.x)/Dx
        if AxisNear > AxisFar
            Temp = AxisNear
            AxisNear = AxisFar
            AxisFar = Temp
        endif
        if AxisNear > NearTime then NearTime = AxisNear
        if AxisFar < FarTime then FarTime = AxisFar
    endif

    if Dy = 0
        if Bullet.PreviousPosition.y < MinY or Bullet.PreviousPosition.y > MaxY then exitfunction Entry
    else
        AxisNear = (MinY-Bullet.PreviousPosition.y)/Dy
        AxisFar = (MaxY-Bullet.PreviousPosition.y)/Dy
        if AxisNear > AxisFar
            Temp = AxisNear
            AxisNear = AxisFar
            AxisFar = Temp
        endif
        if AxisNear > NearTime then NearTime = AxisNear
        if AxisFar < FarTime then FarTime = AxisFar
    endif

    if NearTime <= FarTime and FarTime >= 0 and NearTime <= 1
        Entry = NearTime
    endif
endfunction Entry

// K1b: choose one earliest player-bullet hit across ALL supported targets.
// Tie priority is stable: orb, Walker turret, intelligent mine, simple mine,
// chest. Enemy bullets continue to use their existing collision functions.
function BulletCollidePlayerTargets(BulletList ref as TBulletList,OrbList ref as TOrbList,WalkerList ref as TWalkerList,MineList ref as TMineList,SimpleMineList ref as TMineList,ChestList ref as TChestList,Drone ref as TDrone,Now as integer)
    local i as integer
    local k as integer
    local BestType as integer
    local BestIndex as integer
    local BestEntry as float
    local Entry as float
    local DroneMin as TPosition
    local DroneMax as TPosition

    for i = 0 to BulletList.Bullet.Length
        if BulletList.Bullet[i].Enabled = TRUE and BulletList.Bullet[i].CollisionData.CollisionType = TYPEPLAYERONE
            BestType = 0
            BestIndex = -1
            BestEntry = 2

            for k = 0 to OrbList.Orb.Length
                if OrbList.Orb[k].Enabled = TRUE
                    Entry = BulletBoxSweepEntry(BulletList.Bullet[i],OrbList.Orb[k].CollisionData.Position1,OrbList.Orb[k].CollisionData.Position2)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 1
                        BestIndex = k
                    endif
                endif
            next k

            for k = 0 to WalkerList.Walker.Length
                if WalkerList.Walker[k].Enabled = TRUE
                    Entry = BulletBoxSweepEntry(BulletList.Bullet[i],WalkerList.Walker[k].WalkerCollisionData.Tower.Position1,WalkerList.Walker[k].WalkerCollisionData.Tower.Position2)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 2
                        BestIndex = k
                    endif
                endif
            next k

            for k = 0 to MineList.Mine.Length
                if MineList.Mine[k].Enabled = TRUE
                    Entry = BulletMineSweepEntry(BulletList.Bullet[i],MineList.Mine[k])
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 3
                        BestIndex = k
                    endif
                endif
            next k

            for k = 0 to SimpleMineList.Mine.Length
                if SimpleMineList.Mine[k].Enabled = TRUE
                    Entry = BulletMineSweepEntry(BulletList.Bullet[i],SimpleMineList.Mine[k])
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 4
                        BestIndex = k
                    endif
                endif
            next k

            for k = 0 to ChestList.Chest.Length
                if ChestList.Chest[k].Enabled = TRUE
                    Entry = BulletBoxSweepEntry(BulletList.Bullet[i],ChestList.Chest[k].CollisionData.Position1,ChestList.Chest[k].CollisionData.Position2)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 5
                        BestIndex = k
                    endif
                endif
            next k

            // Drone joins the same nearest-hit sweep as all other player targets.
            if Drone.Enabled = TRUE
                DroneMin.x = Drone.Position.x-23
                DroneMin.y = Drone.Position.y-15
                DroneMax.x = Drone.Position.x+23
                DroneMax.y = Drone.Position.y+15
                Entry = BulletBoxSweepEntry(BulletList.Bullet[i],DroneMin,DroneMax)
                if Entry >= 0 and Entry < BestEntry
                    BestEntry = Entry
                    BestType = 6
                endif
            endif

            if BestType = 1
                OrbList.Orb[BestIndex].Health.State = OrbList.Orb[BestIndex].Health.State - BulletList.Bullet[i].BulletData.Damage
                ColorSet(OrbList.Orb[BestIndex].SpriteData.Color,255,0,0,255)
                BulletDelete(BulletList,i)
            endif
            if BestType = 2
                WalkerList.Walker[BestIndex].Health.State = WalkerList.Walker[BestIndex].Health.State - BulletList.Bullet[i].BulletData.Damage
                WalkerList.Walker[BestIndex].HitFlashUntil = Now + 150
                ColorSet(WalkerList.Walker[BestIndex].WalkerSpriteData.Tower.Color,255,0,0,255)
                BulletDelete(BulletList,i)
            endif
            if BestType = 3
                MineList.Mine[BestIndex].Health.State = MineList.Mine[BestIndex].Health.State - BulletList.Bullet[i].BulletData.Damage
                ColorSet(MineList.Mine[BestIndex].SpriteData.Color,255,0,0,255)
                BulletDelete(BulletList,i)
            endif
            if BestType = 4
                SimpleMineList.Mine[BestIndex].Health.State = SimpleMineList.Mine[BestIndex].Health.State - BulletList.Bullet[i].BulletData.Damage
                ColorSet(SimpleMineList.Mine[BestIndex].SpriteData.Color,255,0,0,255)
                BulletDelete(BulletList,i)
            endif
            if BestType = 6
                DroneTakeDamage(Drone,BulletList.Bullet[i].BulletData.Damage)
                BulletDelete(BulletList,i)
            endif
            if BestType = 5
                ChestList.Chest[BestIndex].Health.State = ChestList.Chest[BestIndex].Health.State - BulletList.Bullet[i].BulletData.Damage
                ColorSet(ChestList.Chest[BestIndex].SpriteData.Color,255,0,0,255)
                BulletDelete(BulletList,i)
            endif
        endif
    next i
endfunction

// One scan across BOTH mine types ensures the nearest valid hit wins, even
// when an intelligent and a simple mine lie on the same bullet trajectory.
// Enemy bullets retain their prior endpoint-circle behavior for this K1 step.
function BulletCollideMines(BulletList ref as TBulletList,MineList ref as TMineList,SimpleMineList ref as TMineList)
    local i as integer
    local k as integer
    local BestType as integer
    local BestIndex as integer
    local BestEntry as float
    local Entry as float
    local Radius as float

    for i = 0 to BulletList.Bullet.Length
        if BulletList.Bullet[i].Enabled = TRUE
            BestType = 0
            BestIndex = -1
            BestEntry = 2

            for k = 0 to MineList.Mine.Length
                if MineList.Mine[k].Enabled = TRUE
                    Entry = -1
                    if BulletList.Bullet[i].CollisionData.CollisionType = TYPEPLAYERONE
                        Entry = BulletMineSweepEntry(BulletList.Bullet[i],MineList.Mine[k])
                    else
                        Radius = CalcRadius(BulletList.Bullet[i].ObjectData.Position,MineList.Mine[k].ObjectData.Position)
                        if Radius < BulletList.Bullet[i].ObjectData.Radius + MineList.Mine[k].ObjectData.Radius then Entry = 1
                    endif
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 1
                        BestIndex = k
                    endif
                endif
            next k

            for k = 0 to SimpleMineList.Mine.Length
                if SimpleMineList.Mine[k].Enabled = TRUE
                    Entry = -1
                    if BulletList.Bullet[i].CollisionData.CollisionType = TYPEPLAYERONE
                        Entry = BulletMineSweepEntry(BulletList.Bullet[i],SimpleMineList.Mine[k])
                    else
                        Radius = CalcRadius(BulletList.Bullet[i].ObjectData.Position,SimpleMineList.Mine[k].ObjectData.Position)
                        if Radius < BulletList.Bullet[i].ObjectData.Radius + SimpleMineList.Mine[k].ObjectData.Radius then Entry = 1
                    endif
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestType = 2
                        BestIndex = k
                    endif
                endif
            next k

            if BestType = 1
                MineList.Mine[BestIndex].Health.State = MineList.Mine[BestIndex].Health.State - BulletList.Bullet[i].BulletData.Damage
                ColorSet(MineList.Mine[BestIndex].SpriteData.Color,255,0,0,255)
                BulletDelete(BulletList,i)
            endif
            if BestType = 2
                SimpleMineList.Mine[BestIndex].Health.State = SimpleMineList.Mine[BestIndex].Health.State - BulletList.Bullet[i].BulletData.Damage
                ColorSet(SimpleMineList.Mine[BestIndex].SpriteData.Color,255,0,0,255)
                BulletDelete(BulletList,i)
            endif
        endif
    next i
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletCollideChest(BulletList ref as TBulletList,ChestList ref as TChestList)
	
	local i as integer
	local k as integer
	local Radius as float
	
	for i = 0 to BulletList.Bullet.Length
		if BulletList.Bullet[i].Enabled = TRUE
			for k = 0 to ChestList.Chest.Length
				if ChestList.Chest[k].Enabled = TRUE
					if BoxInBox(BulletList.Bullet[i].CollisionData.Position1,BulletList.Bullet[i].CollisionData.Position2,ChestList.Chest[k].CollisionData.Position1,ChestList.Chest[k].CollisionData.Position2)
						ChestList.Chest[k].Health.State = ChestList.Chest[k].Health.State - BulletList.Bullet[i].BulletData.Damage
						BulletDelete(BulletList,i)
						ColorSet(ChestList.Chest[k].SpriteData.Color,255,0,0,255)
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletMove(Bullet ref as TBullet,World ref as TWorld,Now as integer)

	if Bullet.Enabled = TRUE
		// Always preserve a single-segment sweep, also when the 10-ms gate is closed.
		Bullet.PreviousPosition = Bullet.ObjectData.Position
		if TimeGet(Bullet.ObjectData.MoveTimer,Now) > 0
			
			Bullet.ObjectData.Position.x = Bullet.ObjectData.Position.x + Bullet.ObjectData.MoveSpeed.x * Bullet.ObjectData.MoveTimer.CalcRange
			Bullet.ObjectData.Position.y = Bullet.ObjectData.Position.y + Bullet.ObjectData.MoveSpeed.y * Bullet.ObjectData.MoveTimer.CalcRange
			
			SpritePositionCalc(Bullet.SpriteData.Position,Bullet.ObjectData.Position,World.Position)
			
			BulletCollisionBoundsCalculate(Bullet)
			
			TimeReset(Bullet.ObjectData.MoveTimer,Now)
			
		endif
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletMoveAll(BulletList ref as TBulletList,World ref as TWorld,Now as integer)

	Local i as integer
	
	for i = 0 to BulletList.Bullet.Length
		if BulletList.Bullet[i].Enabled = TRUE
			BulletMove(BulletList.Bullet[i],World,Now)
			if BulletList.Bullet[i].ObjectData.Position.y < -BulletList.Bullet[i].ObjectData.Size.Height
				BulletDelete(BulletList,i)
			else
				if BulletList.Bullet[i].ObjectData.Position.y > World.Size.Height+BulletList.Bullet[i].ObjectData.Size.Height
					BulletDelete(BulletList,i)
				else
					if BulletList.Bullet[i].ObjectData.Position.x > World.Size.Width+BulletList.Bullet[i].ObjectData.Size.Width
						BulletDelete(BulletList,i)
					else
						if BulletList.Bullet[i].ObjectData.Position.x < -BulletList.Bullet[i].ObjectData.Size.Width
							BulletDelete(BulletList,i)
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

function BulletDraw(Bullet ref as TBullet,ProtoBullet ref as TProtoBullet)

	if Bullet.Enabled = TRUE
		SpriteDraw(ProtoBullet.AnimBullet.Sprite,Bullet.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletDrawAll(BulletList ref as TBulletList,ProtoBullet ref as TProtoBullet)
	
	local i as integer
	
	for i = 0 to BulletList.Bullet.Length
		BulletDraw(BulletList.Bullet[i],ProtoBullet)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletCountAll(BulletList ref as TBulletList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to BulletList.Bullet.Length
		if BulletList.Bullet[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------






