
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WorldInit(World ref as TWorld,ProtoBackground ref as TProtoBackground,Screen as TSize)
	
	World.Size.Width = Screen.Width
	World.Size.Height = GetSpriteHeight(ProtoBackground.AnimSky.Sprite.ID)
	World.Position.x = 0
	World.Position.y = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

