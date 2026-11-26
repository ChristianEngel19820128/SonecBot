// Layer eligibility is independent of contact geometry and damage.
// Each live plate has a session-unique identity; recycled slots never inherit
// a previously fired projectile's exclusion. Background chests form a
// separate sublayer on their carrier. Empty snapshots permit all targets.
global WeaponDepthSerial as integer

function WeaponDepthReset(Depth ref as TWeaponDepth)
    Depth.ExcludedPlateIds.Length = -1
    Depth.ExcludedBackgroundIds.Length = -1
endfunction

function WeaponDepthExclude(Depth ref as TWeaponDepth,PlateList ref as TPlateList,PlateIndex as integer,BackgroundOnly as integer)
    local i as integer
    local Id as integer
    if PlateIndex < 0 or PlateIndex > PlateList.Plate.Length then exitfunction
    if PlateList.Plate[PlateIndex].Enabled = FALSE then exitfunction
    Id = PlateList.Plate[PlateIndex].WeaponDepthId
    if Id <= 0 then exitfunction
    if BackgroundOnly = TRUE
        for i = 0 to Depth.ExcludedBackgroundIds.Length
            if Depth.ExcludedBackgroundIds[i] = Id then exitfunction
        next i
        Depth.ExcludedBackgroundIds.Insert(Id)
    else
        for i = 0 to Depth.ExcludedPlateIds.Length
            if Depth.ExcludedPlateIds[i] = Id then exitfunction
        next i
        Depth.ExcludedPlateIds.Insert(Id)
    endif
endfunction

function WeaponDepthAllows(Depth ref as TWeaponDepth,PlateList ref as TPlateList,PlateIndex as integer,IsBackground as integer)
    local i as integer
    local Id as integer
    if PlateIndex < 0 or PlateIndex > PlateList.Plate.Length then exitfunction TRUE
    if PlateList.Plate[PlateIndex].Enabled = FALSE then exitfunction TRUE
    Id = PlateList.Plate[PlateIndex].WeaponDepthId
    if Id <= 0 then exitfunction TRUE
    for i = 0 to Depth.ExcludedPlateIds.Length
        if Depth.ExcludedPlateIds[i] = Id then exitfunction FALSE
    next i
    if IsBackground = TRUE
        for i = 0 to Depth.ExcludedBackgroundIds.Length
            if Depth.ExcludedBackgroundIds[i] = Id then exitfunction FALSE
        next i
    endif
endfunction TRUE

// Strict overlap: merely touching a surface is not passive penetration.
function WeaponDepthOverlaps(A0 as TPosition,A1 as TPosition,B0 as TPosition,B1 as TPosition)
    if A0.x < B1.x and A1.x > B0.x and A0.y < B1.y and A1.y > B0.y then exitfunction TRUE
endfunction FALSE

// Carrier-local bounds provide current geometry even before ChestMoveAll.
function WeaponDepthChestOverlap(Chest ref as TChest,Plate ref as TPlate,MinPos as TPosition,MaxPos as TPosition)
    local B0 as TPosition
    local B1 as TPosition
    local Overlap as integer
    B0.x = Plate.ObjectData.Position.x+Chest.CollisionData.Position.x
    B0.y = Plate.ObjectData.Position.y+Chest.CollisionData.Position.y
    B1.x = B0.x+Chest.ObjectData.Size.Width
    B1.y = B0.y+Chest.ObjectData.Size.Height
    Overlap = WeaponDepthOverlaps(MinPos,MaxPos,B0,B1)
endfunction Overlap

function WeaponDepthCaptureSonec(Depth ref as TWeaponDepth,Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList)
    local i as integer
    local PlateIndex as integer
    local Slot as integer
    local MinPos as TPosition
    local MaxPos as TPosition
    WeaponDepthReset(Depth)
    // Use the accepted mechanical depth state, not a new motion solver.
    for i = 0 to PlateList.Plate.Length
        if PlateList.Plate[i].Enabled = TRUE and PlateList.Plate[i].SonecDepthState = SONEC_DEPTH_PASSAGE
            WeaponDepthExclude(Depth,PlateList,i,FALSE)
        endif
    next i
    // A linked platform can also contain a specifically permitted underside
    // passage through a chest/base. For weapons the whole plane is excluded.
    Slot = Sonec.PassThroughChestIndex
    if Slot >= 0 and Slot <= SonecMechanicalList.Chest.Length
        if SonecMechanicalList.Chest[Slot].Enabled = TRUE
            PlateIndex = SonecMechanicalList.Chest[Slot].CollisionData.Index
            WeaponDepthExclude(Depth,PlateList,PlateIndex,FALSE)
        endif
    endif
    MinPos.x = Sonec.ObjectData.Position.x-Sonec.ObjectData.Size.Width*0.5
    MinPos.y = Sonec.ObjectData.Position.y-Sonec.ObjectData.Size.Height*0.5
    MaxPos.x = Sonec.ObjectData.Position.x+Sonec.ObjectData.Size.Width*0.5
    MaxPos.y = Sonec.ObjectData.Position.y+Sonec.ObjectData.Size.Height*0.5
    for i = 0 to ChestList.Chest.Length
        if ChestList.Chest[i].Enabled = TRUE and ChestList.Chest[i].IsBackground = TRUE
            PlateIndex = ChestList.Chest[i].CollisionData.Index
            if PlateIndex >= 0 and PlateIndex <= PlateList.Plate.Length
                if PlateList.Plate[PlateIndex].Enabled = TRUE
                    if WeaponDepthChestOverlap(ChestList.Chest[i],PlateList.Plate[PlateIndex],MinPos,MaxPos) = TRUE
                        WeaponDepthExclude(Depth,PlateList,PlateIndex,TRUE)
                    endif
                endif
            endif
        endif
    next i
endfunction

// Source-independent capture for grounded actors. The caller supplies its
// existing movement hull. Foreign carrier overlaps are passive; same-carrier
// foreground contacts remain eligible. Background sublayers are separate.
function WeaponDepthCaptureGrounded(Depth ref as TWeaponDepth,PlateList ref as TPlateList,ChestList ref as TChestList,OwnPlateIndex as integer,MinPos as TPosition,MaxPos as TPosition)
    local i as integer
    local PlateIndex as integer
    local LowerRect as TChest
    local UpperRect as TChest
    WeaponDepthReset(Depth)
    for i = 0 to PlateList.Plate.Length
        if i <> OwnPlateIndex and PlateList.Plate[i].Enabled = TRUE
            if WeaponDepthOverlaps(MinPos,MaxPos,PlateList.Plate[i].CollisionData.Position1,PlateList.Plate[i].CollisionData.Position2) = TRUE
                WeaponDepthExclude(Depth,PlateList,i,FALSE)
            endif
        endif
    next i
    for i = 0 to ChestList.Chest.Length
        if ChestList.Chest[i].Enabled = TRUE
            PlateIndex = ChestList.Chest[i].CollisionData.Index
            if PlateIndex >= 0 and PlateIndex <= PlateList.Plate.Length
                if PlateList.Plate[PlateIndex].Enabled = TRUE
                    if WeaponDepthChestOverlap(ChestList.Chest[i],PlateList.Plate[PlateIndex],MinPos,MaxPos) = TRUE
                        if PlateIndex <> OwnPlateIndex
                            WeaponDepthExclude(Depth,PlateList,PlateIndex,FALSE)
                        else
                            if ChestList.Chest[i].IsBackground = TRUE then WeaponDepthExclude(Depth,PlateList,PlateIndex,TRUE)
                        endif
                    endif
                endif
            endif
        endif
    next i
    // Foreign platform bases are passive too. Rebuild temporary rectangles
    // from current plate transforms; no mutations to the real object lists.
    for i = 0 to JumppodList.Length
        if JumppodList[i].Enabled = TRUE
            PlateIndex = JumppodList[i].PlateIndex
            if PlateIndex <> OwnPlateIndex and PlateIndex >= 0 and PlateIndex <= PlateList.Plate.Length
                if PlateList.Plate[PlateIndex].Enabled = TRUE
                    SockelUpdateRects(LowerRect,UpperRect,PlateList.Plate[PlateIndex],PlateIndex,JumppodList[i].OffsetX)
                    if WeaponDepthOverlaps(MinPos,MaxPos,LowerRect.CollisionData.Position1,LowerRect.CollisionData.Position2) = TRUE or WeaponDepthOverlaps(MinPos,MaxPos,UpperRect.CollisionData.Position1,UpperRect.CollisionData.Position2) = TRUE
                        WeaponDepthExclude(Depth,PlateList,PlateIndex,FALSE)
                    endif
                endif
            endif
        endif
    next i
    for i = 0 to FlarakList.Length
        if FlarakList[i].Enabled = TRUE
            PlateIndex = FlarakList[i].PlateIndex
            if PlateIndex <> OwnPlateIndex and PlateIndex >= 0 and PlateIndex <= PlateList.Plate.Length
                if FlarakCarrierMatches(FlarakList[i],PlateList.Plate[PlateIndex]) = TRUE
                    SockelUpdateRects(LowerRect,UpperRect,PlateList.Plate[PlateIndex],PlateIndex,FlarakList[i].PlateOffsetX)
                    if WeaponDepthOverlaps(MinPos,MaxPos,LowerRect.CollisionData.Position1,LowerRect.CollisionData.Position2) = TRUE or WeaponDepthOverlaps(MinPos,MaxPos,UpperRect.CollisionData.Position1,UpperRect.CollisionData.Position2) = TRUE
                        WeaponDepthExclude(Depth,PlateList,PlateIndex,FALSE)
                    endif
                endif
            endif
        endif
    next i
endfunction
