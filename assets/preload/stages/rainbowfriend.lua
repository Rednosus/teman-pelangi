function onCreate()
	-- background shit
	makeLuaSprite('stageback', 'stageback',-600, -200);
	setLuaSpriteScrollFactor('stageback', 1, 1);
	scaleObject('stageback', 2, 2)

	addLuaSprite('stageback', false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end