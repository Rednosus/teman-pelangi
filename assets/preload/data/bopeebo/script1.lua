--Script by Super_Hugo on GameBanana
--Enjoy!

------------OPTIONS------------
playable = true		--change this to false if you want to play normally without multiplayer

keys = {'A', 'S', 'W', 'D'}		--change your keys here (needs to be in this order: left, down, up, right)	- example: {'D', 'F', 'J', 'K'}

doNoteSplashes = true

changeStrums = true		--set to false if you can't see the opponent notes in a song, or you are using differentCharactersMode (else make it true for modcharts to work)



--------health stuff--------
cannotDieP1 = true		--if true makes it so P1 can't die (to make it more fair lmao)

doHealthDrainP1 = true		--P1 health drain
doHealthDrainP2 = true		--P2 health drain (disable if song already has opponent health drain)



--------ratings--------
showCombo = false
showComboNum = true
showRating = true

showMS = true		--show ms timing just like in kade engine

comboOffset = {-300, -250, -300, -250}		--{ratingX, ratingY, numX, numY}		(the combo uses numX and numY)



--------other--------
doEndScreen = true		--if true adds a screen at the end of the song that shows the score for each player

botPlayKey = 'SIX'		--the key to toggle botplay mid-song for P2 (nil for no toggle)

lessMemoryUsage = false		--disables ratings and all of that stuff for less memory usage and less lag drops



--------experimental stuff--------

--(dont use these in songs with mechanics or extra notes or it can break)

mustPressSwap = false		--swaps the notes between P1 and P2 (also changes the characters if differentCharactersMode is false)

differentCharactersMode = false		--if true lets you change the P1 and P2 characters (use with changeStrums in false to change the note positions)

--change these to the characters you want to play as with differentCharactersMode enabled
swapCharacterP1 = 'dad'
swapCharacterP2 = 'boyfriend'

--EXAMPLES
--[[

if you want the P2 to play as boyfriend and P1 to play as opponent do this:

swapCharacterP1 = 'dad'
swapCharacterP2 = 'boyfriend'

mustPressSwap = true

--

and if you want the P1 to play as girlfriend:

swapCharacterP1 = 'girlfriend'
swapCharacterP2 = 'dad'

mustPressSwap = false

--]]




------------dont change anything from this point on------------

--score and stuff for player 2
scoreP2 = 0
comboP2 = 0
totalNotesHitP2 = 0
totalPlayedP2 = 0
hitsP2 = 0
songMissesP2 = 0
ratingsP2 = {sicks = 0, goods = 0, bads = 0, shits = 0}

local ratingPercentP2 = 1
local ratingNameP2 = '?'
local ratingFCP2 = ''

local cpuControlled = false
local newBotPlayP2 = true		--disabling this makes some stuff not work, use (playable = false) instead


--{name, ratingMod, score, noteSplash}
local ratingsData = {
{'sick', 1, 350, true},
{'good', 0.7, 200, false},
{'bad', 0.4, 100, false},
{'shit', 0, 50, false}
}


defaultCharacter = 'dad'

if differentCharactersMode == true then
	defaultCharacter = swapCharacterP2
	
elseif mustPressSwap == true then
	defaultCharacter = 'boyfriend'
	swapCharacterP1 = 'dad'
end


--other variables
local makeChanges = false
local songSplashSkin = nil
local ratingCount = 0
local gfSinging = false
local gfSingingP1 = false
local hitsP1 = 0
local noteMissesP2 = 0

local endContinue = false
local continueTxtSine = 0


-------------------prepare stuff-------------------
function onCreatePost()

	--get the song note splashes because it doesn't let me use SONG.splashSkin for some reason
	songSplashSkin = getPropertyFromGroup('unspawnNotes', 0, 'noteSplashTexture')

	if songSplashSkin == nil or songSplashSkin == 'noteSplashTexture' then 
		songSplashSkin = 'noteSplashes'
	end
	
	
	if lessMemoryUsage == false then
	
		--make opponent scoreTxt
		makeLuaText('scoreTxtP2', '', 0, 0, 0)
		setObjectCamera('scoreTxtP2', 'camHUD')
		setProperty('scoreTxtP2.borderSize', 1.25)
		setTextSize('scoreTxtP2', 20)
		setTextAlignment('scoreTxtP2', 'center')
		setProperty('scoreTxtP2.visible', playable and not (getPropertyFromClass('ClientPrefs', 'hideHud')))
		addLuaText('scoreTxtP2', true)
		
		setProperty('scoreTxtP2.scale.x', getProperty('scoreTxt.scale.x'))
		setProperty('scoreTxtP2.scale.y', getProperty('scoreTxt.scale.y'))

		if getPropertyFromClass('ClientPrefs', 'downScroll') then
			setProperty('scoreTxtP2.y', 650)
		end
		
		setTextString('scoreTxtP2', 'Score: '..scoreP2..' | Misses: '..songMissesP2..' | Rating: '..ratingNameP2)
		
		screenCenter('scoreTxtP2', 'x')
	
	end
	
end


function onUpdate(elapsed)

	--debug botplay key
	if not (botPlayKey == nil or botPlayKey == '') then
	
		if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.'..botPlayKey:upper()) then
		
			if newBotPlayP2 == true and playable == true then
				cpuControlled = not cpuControlled
			else
			
				if playable == false then
					cpuControlled = false
				end
				
				playable = not playable
				
			end
			
			makeChanges = true
			
		end
	
	end
	
	
	if playable == true then

		if cpuControlled == false and getProperty('inCutscene') == false then
			keyShit()
		end
		
		--mmm
		if getProperty('showCombo') == false and getProperty('showComboNum') == false and getProperty('showRating') == false then
			showCombo = false
			showComboNum = false
			showRating = false
		end

		--this so the health doesn't go below 0 in cannotDie
		if cannotDieP1 == true and getProperty('health') < 0 then
			setProperty('health', 0)
		end
	
	end

end


--normal notes input
function keyShit()

	for i = 1, #keys do
		
		if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.'..keys[i]:upper()) == true then
			strumPlayAnim(i - 1, 'pressed', true, -1)
			callOnLuas('onKeyPressP2', {(i - 1)}, false, false) 
			--used callOnLuas so it doesn't stop this function when something goes wrong in the other (i think that's how it works, if not it doesn't change anything either way so)
			--onKeyPressP2(i - 1)
		end
		
	end
	
	return
	
end


--hold notes
function keyHoldShit()

	for i = 1, #keys do

		if getPropertyFromClass('flixel.FlxG', 'keys.pressed.'..keys[i]:upper()) == true then
			
			for ii = 0, getProperty('notes.length')-1 do
		
				if getPropertyFromGroup('notes', ii, 'noteData') == (i - 1) and getPropertyFromGroup('notes', ii, 'isSustainNote') == true and getPropertyFromGroup('notes', ii, 'mustPress') == false then
				
					if getPropertyFromGroup('notes', ii, 'canBeHit') == true and getPropertyFromGroup('notes', ii, 'tooLate') == false and getPropertyFromGroup('notes', ii, 'hitByOpponent') == false then
						callOnLuas('goodNoteHitP2', {ii, getPropertyFromGroup('notes', ii, 'noteData'), getPropertyFromGroup('notes', ii, 'noteType'), getPropertyFromGroup('notes', ii, 'isSustainNote')}, false, false)
					end
				
				end
			
			end
					
		end

		if getPropertyFromClass('flixel.FlxG', 'keys.released.'..keys[i]:upper()) then
			strumPlayAnim(i - 1, 'static', true, 0)
		end
	
	end

end


--more set note stuff
function onSpawnNote(id)

	--set note stuff for mustPressSwap
	if mustPressSwap == true then
		setPropertyFromGroup('notes', id, 'mustPress', not getPropertyFromGroup('notes', id, 'mustPress'))
		setPropertyFromGroup('notes', id, 'hitHealth', -getPropertyFromGroup('notes', id, 'hitHealth'))
		setPropertyFromGroup('notes', id, 'missHealth', -getPropertyFromGroup('notes', id, 'missHealth'))
	end

	--swapped characters
	if differentCharactersMode == true or mustPressSwap == true then
		
		if getPropertyFromGroup('notes', i, 'mustPress') == true then
			setPropertyFromGroup('notes', i, 'inEditor', getPropertyFromGroup('notes', i, 'noAnimation'))
			setPropertyFromGroup('notes', i, 'noAnimation', true)
			setPropertyFromGroup('notes', i, 'noMissAnimation', true)
		end
		
	end
	
	--health
	if getPropertyFromGroup('notes', i, 'mustPress') == false then
	
		--just in case
		if doHealthDrainP2 == false then
			setPropertyFromGroup('notes', i, 'hitHealth', 0)
		end

	else
	
		if doHealthDrainP1 == false then
			setPropertyFromGroup('notes', i, 'hitHealth', 0)
		end
		
	end
	
end


-------------------set stuff for player 2-------------------
function onUpdatePost(elapsed)

	if playable == true then
	
		if isCharacter(defaultCharacter) == true then 
			animThingP2(elapsed) 
		end
		
		if ((differentCharactersMode == true) or (mustPressSwap == true and differentCharactersMode == false)) and isCharacter(swapCharacterP1) == true then
			animThingP1(elapsed)
		end
	
		if lessMemoryUsage == false then
		
			--change strum positions with the character
			if changeStrums == false then
			
				for i = 0, 3 do
				
					--my brain hurts by just looking at this lmao
					if differentCharactersMode == true then

						--Player 1
						if swapCharacterP1 == 'dad' or (swapCharacterP1 == 'gf' and not (swapCharacterP2 == 'gf')) then
							setPropertyFromGroup('playerStrums', i, 'x', _G['defaultOpponentStrumX'..i])
							setPropertyFromGroup('playerStrums', i, 'y', _G['defaultOpponentStrumY'..i])
							
						--middlescroll (only when both characters are gf)
						elseif swapCharacterP1 == 'gf' and swapCharacterP2 == 'gf' then
							setPropertyFromGroup('playerStrums', i, 'x', (screenWidth / 3) + (i * (getPropertyFromGroup('playerStrums', i, 'width'))))
							setPropertyFromGroup('playerStrums', i, 'y', _G['defaultPlayerStrumY'..i])
							
						else
							setPropertyFromGroup('playerStrums', i, 'x', _G['defaultPlayerStrumX'..i])
							setPropertyFromGroup('playerStrums', i, 'y', _G['defaultPlayerStrumY'..i])
						end
						
						--Player 2
						if swapCharacterP2 == 'boyfriend' or (swapCharacterP2 == 'gf' and not (swapCharacterP1 == 'gf')) then
							setPropertyFromGroup('opponentStrums', i, 'x', _G['defaultPlayerStrumX'..i])
							setPropertyFromGroup('opponentStrums', i, 'y', _G['defaultPlayerStrumY'..i])
							
						--middlescroll (only when both characters are gf)
						elseif swapCharacterP1 == 'gf' and swapCharacterP2 == 'gf' then
							setPropertyFromGroup('opponentStrums', i, 'x', (screenWidth / 3) + (i * (getPropertyFromGroup('opponentStrums', i, 'width'))))
							setPropertyFromGroup('opponentStrums', i, 'y', _G['defaultOpponentStrumY'..i])
							
						else
							setPropertyFromGroup('opponentStrums', i, 'x', _G['defaultOpponentStrumX'..i])
							setPropertyFromGroup('opponentStrums', i, 'y', _G['defaultOpponentStrumY'..i])
						end

					else
						
						if mustPressSwap == true then
							setPropertyFromGroup('playerStrums', i, 'x', _G['defaultOpponentStrumX'..i])
							setPropertyFromGroup('playerStrums', i, 'y', _G['defaultOpponentStrumY'..i])
							setPropertyFromGroup('opponentStrums', i, 'x', _G['defaultPlayerStrumX'..i])
							setPropertyFromGroup('opponentStrums', i, 'y', _G['defaultPlayerStrumY'..i])
						else
							setPropertyFromGroup('playerStrums', i, 'x', _G['defaultPlayerStrumX'..i])
							setPropertyFromGroup('playerStrums', i, 'y', _G['defaultPlayerStrumY'..i])
							setPropertyFromGroup('opponentStrums', i, 'x', _G['defaultOpponentStrumX'..i])
							setPropertyFromGroup('opponentStrums', i, 'y', _G['defaultOpponentStrumY'..i])
						end
						
					end
					
					setPropertyFromGroup('playerStrums', i, 'alpha', 1)
					setPropertyFromGroup('playerStrums', i, 'visible', true)
					setPropertyFromGroup('opponentStrums', i, 'alpha', 1)
					setPropertyFromGroup('opponentStrums', i, 'visible', true)
					
				end
				
			end
			

			----------------------------------scoreTxt stuff----------------------------------
			--oh my god
			if not (getTextFont('scoreTxt') == 'VCR OSD Mono' or getTextFont('scoreTxt') == 'Pixel Arial 11 Bold')
			and not (getTextFont('scoreTxtP2') == getTextFont('scoreTxt')) then
			
				local font1 = ''
				local font2 = ''
				
				--Player 1 score
				if string.find(getTextFont('scoreTxt'), 'fonts/') then
					local _, a = string.find(getTextFont('scoreTxt'), 'fonts/')
					font1 = string.sub(getTextFont('scoreTxt'), a + 1)
				else
					font1 = getTextFont('scoreTxt')
				end

				--Player 2 score
				if string.find(getTextFont('scoreTxtP2'), 'fonts/') then
					local _, b = string.find(getTextFont('scoreTxtP2'), 'fonts/')
					font2 = string.sub(getTextFont('scoreTxtP2'), b + 1)
				else
					font2 = getTextFont('scoreTxtP2')
				end

				--check and set the font
				if not (font1 == font2) then
					setTextFont('scoreTxtP2', font1)
				end
			
			else
			
				if getTextFont('scoreTxt') == 'VCR OSD Mono' and not (getTextFont('scoreTxtP2') == 'VCR OSD Mono') then
					setTextFont('scoreTxtP2', 'vcr.ttf')
				end
				
				if getTextFont('scoreTxt') == 'Pixel Arial 11 Bold' and not (getTextFont('scoreTxtP2') == 'Pixel Arial 11 Bold') then
					setTextFont('scoreTxtP2', 'pixel.otf')
				end
			
			end

			if not (getTextSize('scoreTxtP2') == getTextSize('scoreTxt')) then
				setTextSize('scoreTxtP2', getTextSize('scoreTxt'))
			end
			
			setProperty('scoreTxtP2.visible', getProperty('scoreTxt.visible'))
			setProperty('scoreTxtP2.alpha', getProperty('scoreTxt.alpha'))
			screenCenter('scoreTxtP2', 'x')
			
		end
		----------------------------------end of score stuff----------------------------------
	
		--note stuff
		for i = 0, getProperty('notes.length')-1 do
		
			--ignore note logic and stuff (a bit complicated)
			if (not (getPropertyFromGroup('notes', i, 'rating') == 'noteCheck' or getPropertyFromGroup('notes', i, 'rating') == 'ignore')) 
			and (getPropertyFromGroup('notes', i, 'mustPress') == false and getPropertyFromGroup('notes', i, 'hitByOpponent') == false) or getPropertyFromGroup('notes', i, 'mustPress') == true then

				--get notes that can be ignored
				if (getPropertyFromGroup('notes', i, 'ignoreNote') == true or getPropertyFromGroup('notes', i, 'hitCausesMiss')) and not (getPropertyFromGroup('notes', i, 'noteType') == '') then
					setPropertyFromGroup('notes', i, 'rating', 'ignore')
					--debugPrint('ignore note: ', i, ' with noteType: ', getPropertyFromGroup('notes', i, 'noteType'))
				else
					setPropertyFromGroup('notes', i, 'rating', 'noteCheck')
				end

				if getPropertyFromGroup('notes', i, 'mustPress') == false then
					setPropertyFromGroup('notes', i, 'ignoreNote', true)
					--debugPrint('noteID = '..tonumber(i)..' - noteType = '..getPropertyFromGroup('notes', i, 'noteType')..' - tag = '..getPropertyFromGroup('notes', i, 'rating'))
				end
			
			end
			
		
			--opponent note stuff
			if getPropertyFromGroup('notes', i, 'mustPress') == false then
			
				--check if the note is too late or it can be hit
				if cpuControlled == false then

					if getPropertyFromGroup('notes', i, 'strumTime') > getPropertyFromClass('Conductor', 'songPosition') - (getPropertyFromClass('Conductor', 'safeZoneOffset') * getPropertyFromGroup('notes', i, 'lateHitMult'))
						and getPropertyFromGroup('notes', i, 'strumTime') < getPropertyFromClass('Conductor', 'songPosition') + (getPropertyFromClass('Conductor', 'safeZoneOffset') * getPropertyFromGroup('notes', i, 'earlyHitMult')) then
							setPropertyFromGroup('notes', i, 'canBeHit', true)
					else
						setPropertyFromGroup('notes', i, 'canBeHit', false)
					end
					
					if getPropertyFromGroup('notes', i, 'strumTime') < getPropertyFromClass('Conductor', 'songPosition') - getPropertyFromClass('Conductor', 'safeZoneOffset') and getPropertyFromGroup('notes', i, 'hitByOpponent') == false then
						setPropertyFromGroup('notes', i, 'tooLate', true)
					end
				
				else
				
					if getPropertyFromGroup('notes', i, 'strumTime') < getPropertyFromClass('Conductor', 'songPosition') then
						setPropertyFromGroup('notes', i, 'canBeHit', true)
					end
					
				end
				
				
				
				--P2 botplay
				if cpuControlled == true then

					if getPropertyFromGroup('notes', i, 'canBeHit') and not (getPropertyFromGroup('notes', i, 'rating') == 'ignore') and getPropertyFromGroup('notes', i, 'hitByOpponent') == false then
					
						setPropertyFromGroup('notes', i, 'strumTime', getPropertyFromClass('Conductor', 'songPosition')) --make bot hit notes perfectly
						setPropertyFromGroup('notes', i, 'noteData', getPropertyFromGroup('notes', i, 'noteData') % 4) --just in case
						
						callOnLuas('goodNoteHitP2', {i, getPropertyFromGroup('notes', i, 'noteData'), getPropertyFromGroup('notes', i, 'noteType'), getPropertyFromGroup('notes', i, 'isSustainNote')}, false, false)
						
					end
					
				end
				
				

				--note missed
				if getPropertyFromClass('Conductor', 'songPosition') > (getProperty('noteKillOffset') - 10) + getPropertyFromGroup('notes', i, 'strumTime') then

					if cpuControlled == false and not (getPropertyFromGroup('notes', i, 'rating') == 'ignore') and getProperty('endingSong') == false 
					and (getPropertyFromGroup('notes', i, 'tooLate') or getPropertyFromGroup('notes', i, 'hitByOpponent') == false) then
						--debugPrint('note missed: ', i)
						callOnLuas('noteMissP2', {i}, false, false)
					end
					
					setPropertyFromGroup('notes', i, 'active', false)
					setPropertyFromGroup('notes', i, 'visible', false)

					removeFromGroup('notes', i)
					
				end
				
				
				--smooth remove of sustain notes (not done yet)
				if getPropertyFromGroup('notes', i, 'isSustainNote') == true and getPropertyFromGroup('notes', i, 'hitByOpponent') == true then
				
					local center = getPropertyFromGroup('opponentStrums', getPropertyFromGroup('notes', i, 'noteData'), 'y') + (getPropertyFromClass('Note', 'swagWidth') / 2)
				
					if getPropertyFromGroup('notes', i, 'y') <= center then
						removeFromGroup('notes', i)
					end
					
				end
			
			end
			
		end
		
		if cpuControlled == false and getProperty('inCutscene') == false then
			keyHoldShit()
		end
		
		
	--set stuff for going back to normal opponent (when botplay key is pressed)
	elseif makeChanges == true then
	
		setProperty('scoreTxtP2.visible', false)
	
		if isCharacter(defaultCharacter) == true then setProperty(defaultCharacter..'.debugMode', false) end
		
		if getProperty('scoreTxtP2.visible') == true then
			setProperty('scoreTxtP2.visible', false)
		end
		
		for i = 0, getProperty('notes.length')-1 do
		
			if not (getPropertyFromGroup('notes', i, 'mustPress')) then

				if getPropertyFromGroup('notes', i, 'ignoreNote') == true then 
					setPropertyFromGroup('notes', i, 'ignoreNote', false) 
				end
				
			end
			
		end
		
		makeChanges = false
	
	end
	
	
	--end screen stuff
	if inEndScreen == true then
	
		if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.ENTER') then
			endContinue = true
			endSong()
		end
		
		--didn't add this so you dont accidentally press escape and lose your progress lmao
		--[[
		if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.ESCAPE') then
			exitSong()
		end
		--]]
		
		continueTxtSine = continueTxtSine + (180 * elapsed)
		setProperty('continueTxt.alpha', 1 - math.sin((math.pi * continueTxtSine) / 180))
	
	end

end


-------------------head bop-------------------
function onBeatHit()

	if playable == true then
	
		--Player 2
		if isCharacter(defaultCharacter) == true then
	
			if curBeat % getProperty(defaultCharacter..'.danceEveryNumBeats') == 0 and not (getProperty(defaultCharacter..'.animation.curAnim') == nil) 
			and (not (string.find(getProperty(defaultCharacter..'.animation.curAnim.name'), 'sing')) or string.find(getProperty(defaultCharacter..'.animation.curAnim.name'), 'miss')) then
				dance(defaultCharacter)
			end
		
		end
		
		
		--Player 1
		if differentCharactersMode == true or mustPressSwap == true then
		
			if isCharacter(swapCharacterP1) == true then 
		
				if curBeat % getProperty(swapCharacterP1..'.danceEveryNumBeats') == 0 and not (getProperty(swapCharacterP1..'.animation.curAnim') == nil) 
				and (not (string.find(getProperty(swapCharacterP1..'.animation.curAnim.name'), 'sing')) or string.find(getProperty(swapCharacterP1..'.animation.curAnim.name'), 'miss')) then
					dance(swapCharacterP1)
				end
			
			end
		
		end
				
	end

end


-------------------head bop on countdown ticks-------------------
function onCountdownTick(tick)

	if playable == true then
	
		--Player 2
		if isCharacter(defaultCharacter) == true then 

			if tick % getProperty(defaultCharacter..'.danceEveryNumBeats') == 0 and not (getProperty(defaultCharacter..'.animation.curAnim') == nil) then
				dance(defaultCharacter)
			end
		
		end


		--Player 1
		if differentCharactersMode == true or mustPressSwap == true then
		
			if isCharacter(swapCharacterP1) == true then

				if tick % getProperty(swapCharacterP1..'.danceEveryNumBeats') == 0 and not (getProperty(swapCharacterP1..'.animation.curAnim') == nil) then
					dance(swapCharacterP1)
				end
				
			end
		
		end
	
	end
	
end


-------------------PSYCH ENGINE INPUT-------------------
function onKeyPressP2(key)

	--local keyName = getKeyFromID(key)	--why was I adding this lol
	
	if playable and getProperty('startedCountdown') and getProperty('paused') == false and key > -1 then
	
		if getProperty('generatedMusic') and getProperty('endingSong') == false then

			local canMiss = not getPropertyFromClass('ClientPrefs', 'ghostTapping')
			
			local pressNotes = {}
			local notesStopped = false
			
			--get all notes that can be hit and sort them based on strumTime
			local sortedNotesList = {}
			for i = 0, getProperty('notes.length')-1 do
			
				if getPropertyFromGroup('notes', i, 'mustPress') == false and getPropertyFromGroup('notes', i, 'isSustainNote') == false then
				
					if getPropertyFromGroup('notes', i, 'canBeHit') and getPropertyFromGroup('notes', i, 'tooLate') == false and getPropertyFromGroup('notes', i, 'hitByOpponent') == false then
					
						if getPropertyFromGroup('notes', i, 'noteData') == key then
							sortedNotesList[#sortedNotesList + 1] = i
						end
						canMiss = true
					
					end
				
				end
				
			end
			table.sort(sortedNotesList, sortHitNotes())
			
			if #sortedNotesList > 0 then
			
				for epicNote = 1, #sortedNotesList do

					for doubleNote = 1, #pressNotes do
						
						if math.abs(getPropertyFromGroup('notes', sortedNotesList[doubleNote], 'strumTime') - getPropertyFromGroup('notes', sortedNotesList[epicNote], 'strumTime')) < 1 then
							removeFromGroup('notes', sortedNotesList[doubleNote])
						else
							notesStopped = true
						end
						
					end
					
					if notesStopped == false then
						callOnLuas('goodNoteHitP2', {sortedNotesList[epicNote], getPropertyFromGroup('notes', sortedNotesList[epicNote], 'noteData'), getPropertyFromGroup('notes', sortedNotesList[epicNote], 'noteType'), getPropertyFromGroup('notes', sortedNotesList[epicNote], 'isSustainNote')}, false, false)
						pressNotes[#pressNotes + 1] = sortedNotesList[epicNote]
					end
				
				end
				
			else

				--miss press when no ghost tapping
				if canMiss == true then
					noteMissPressP2(key)
				end
			
			end

		end
	
	end

end


--sort function
function sortHitNotes()
	
	return function(a, b)

		if (getPropertyFromGroup('notes', a, 'lowPriority') and getPropertyFromGroup('notes', b, 'lowPriority') == false) then
			return 1
		elseif (getPropertyFromGroup('notes', a, 'lowPriority') == false and getPropertyFromGroup('notes', b, 'lowPriority')) then
			return -1
		end

		return getPropertyFromGroup('notes', a, 'strumTime') < getPropertyFromGroup('notes', b, 'strumTime')
	
	end
	
end


-------------------when note hit-------------------
function goodNoteHitP2(id, noteData, noteType, isSustainNote)

	if getPropertyFromGroup('notes', id, 'hitByOpponent') == false then
	
		if (getPropertyFromGroup('notes', id, 'mustPress') == true or getPropertyFromGroup('notes', id, 'hitByOpponent') == true) then return end
		
		--just in case
		if tostring(noteType) == '0' or noteType == 'None' then noteType = '' end
		
		
		--dupe note detector
		for i = 1, getProperty('notes.length') do
			
			if not (i == id) and getPropertyFromGroup('notes', i, 'mustPress') == false and getPropertyFromGroup('notes', i, 'isSustainNote') == false then
			
				if getPropertyFromGroup('notes', i, 'noteData') == noteData then
			
					if math.abs(getPropertyFromGroup('notes', i, 'strumTime') - getPropertyFromGroup('notes', id, 'strumTime')) < 1 then
						--debugPrint('removed ', i, ' with difference of ', math.abs(getPropertyFromGroup('notes', i, 'strumTime') - getPropertyFromGroup('notes', id, 'strumTime')))
						removeFromGroup('notes', i)
					end
				
				end
						
			end
			
		end
		
		
		--camera zoom thingy
		if not (formatToSongPath(getPropertyFromClass('PlayState', 'SONG.song')) == 'tutorial') and mustPressSwap == false then
			setProperty('camZooming', true)
		end
		
		
		--hitsound
		if getPropertyFromClass('ClientPrefs', 'hitsoundVolume') > 0 and getPropertyFromGroup('notes', id, 'hitsoundDisabled') == false then
			playSound('hitsound', getPropertyFromClass('ClientPrefs', 'hitsoundVolume'))
		end


		--notes that makes you miss
		if getPropertyFromGroup('notes', id, 'hitCausesMiss') == true then

			--make a splash even when not sick rating
			if not (getPropertyFromGroup('notes', id, 'noteSplashDisabled') and isSustainNote) and doNoteSplashes == true then
				spawnNoteSplash(id)
			end

			if getPropertyFromGroup('notes', id, 'noMissAnimation') == false then

				if noteType == 'Hurt Note' then
					playAnim(defaultCharacter, 'hurt', true)
					if isCharacter(defaultCharacter) == true then setProperty(defaultCharacter..'.specialAnim', true) end
				end
				
			end

			--setPropertyFromGroup('notes', id, 'wasGoodHit', true)
			setPropertyFromGroup('notes', id, 'hitByOpponent', true)
			
			callOnLuas('noteMissP2', {id})

			removeFromGroup('notes', id)
				
			return
			
		end
		
		--score
		if isSustainNote == false then
			comboP2 = comboP2 + 1
			if comboP2 > 9999 then combo = 9999 end
			if lessMemoryUsage == false then popUpScore(id) end --I thought the memory issues were from the input but I guess I was wrong
		end
		
		--health drain
		if getProperty('health') > getPropertyFromGroup('notes', id, 'hitHealth') * getProperty('healthGain') and doHealthDrainP2 == true then
			setProperty('health', getProperty('health') - getPropertyFromGroup('notes', id, 'hitHealth') * getProperty('healthGain'))
		end

		--animations and stuff
		if getPropertyFromGroup('notes', id, 'noAnimation') == false then

			local animToPlay = getProperty('singAnimations')[noteData + 1]
			local animSuffix = getPropertyFromGroup('notes', id, 'animSuffix')
			
			if noteType == 'Alt Animation' or altAnim then animSuffix = '-alt' end
			
			if getPropertyFromGroup('notes', id, 'gfNote') then
			
				if not (getProperty('gf') == nil) then
				
					playAnim('gf', animToPlay..animSuffix, true)
					
					--if no animation with alt anims, play normal animation
					if not (animSuffix == '') and not (getProperty('gf.animation.curAnim.name') == animToPlay..animSuffix) then
						playAnim('gf', animToPlay, true)
					end
				
					setProperty('gf.holdTimer', 0)
					
					gfSinging = true
					
				end
				
			else
			
				playAnim(defaultCharacter, animToPlay..animSuffix, true)
				
				--if no animation with alt anims, play normal animation
				if not (animSuffix == '') and not (getProperty(defaultCharacter..'.animation.curAnim.name') == animToPlay..animSuffix) then
					playAnim(defaultCharacter, animToPlay, true)
				end
				
				if isCharacter(defaultCharacter) == true then setProperty(defaultCharacter..'.holdTimer', 0) end
				
				setProperty(defaultCharacter..'.specialAnim', false)
				
				gfSinging = false
				
			end
			
			if noteType == 'Hey!' then
			
				playAnim(defaultCharacter, 'hey', true)
				
				if isCharacter(defaultCharacter) == true then
					setProperty(defaultCharacter..'.specialAnim', true)
					setProperty(defaultCharacter..'.heyTimer', 0.6)
				end
				
				if not (getProperty('gf') == nil) then
					playAnim('gf', 'cheer', true)
					setProperty('gf.specialAnim', true)
					setProperty('gf.heyTimer', 0.6)
				end
				
			end
		
		end
		
		--strum animations
		local time = 0

		if isSustainNote then
		
			if cpuControlled == true then
				time = time + 0.15
			end
		
			if string.find(getPropertyFromGroup('opponentStrums', noteData, 'animation.curAnim.name'), 'end') == nil then
				strumPlayAnim(noteData, 'confirm', true, time)
			end
			
		else
		
			if cpuControlled == true then
				time = 0.15
			end
			
			strumPlayAnim(noteData, 'confirm', true, time)
			
		end
		
		--setPropertyFromGroup('notes', id, 'wasGoodHit', true)
		setPropertyFromGroup('notes', id, 'hitByOpponent', true)
		
		setProperty('vocals.volume', 1)
		
		--debugPrint('note hit: ', id)
		
		--for other lua scripts
		if mustPressSwap == true then
			callOnLuas('goodNoteHit', {id, noteData, noteType, isSustainNote}, false, true, {scriptName})
		else
			callOnLuas('opponentNoteHit', {id, noteData, noteType, isSustainNote})
		end

		if isSustainNote == false then
			removeFromGroup('notes', id)
		end
		
	end
	
end


-------------------when note missed-------------------
function noteMissP2(id)

	if getPropertyFromGroup('notes', id, 'isSustainNote') == true and string.find(getPropertyFromGroup('notes', id, 'animation.curAnim.name'), 'end') then return end

	--remove dupe note (does this work?)
	if lessMemoryUsage == false then
	
		for i = 0, getProperty('notes.length')-1 do
		
			if not (id == i) and getPropertyFromGroup('notes', id, 'mustPress') == false and getPropertyFromGroup('notes', id, 'noteData') == getPropertyFromGroup('notes', i, 'noteData')
			and getPropertyFromGroup('notes', id, 'isSustainNote') == getPropertyFromGroup('notes', i, 'isSustainNote') and math.abs(getPropertyFromGroup('notes', id, 'strumTime') - getPropertyFromGroup('notes', i, 'strumTime')) < 1 then
				removeFromGroup('notes', i)
			end
			
		end
	
	end


	--set some stuff
	comboP2 = 0
	setProperty('health', getProperty('health') + getPropertyFromGroup('notes', id, 'missHealth') * getProperty('healthLoss'))
	if getProperty('instakillOnMiss') then
		setProperty('vocals.volume', 0)
		setProperty('health', 2)
	end
	
	songMissesP2 = songMissesP2 + 1
	if getPropertyFromGroup('notes', id, 'hitCausesMiss') == false then noteMissesP2 = noteMissesP2 + 1 end
	setProperty('vocals.volume', 0)
	if getProperty('practiceMode') == false then scoreP2 = scoreP2 - 10 end
	
	totalPlayedP2 = totalPlayedP2 + 1
	if lessMemoryUsage == false then RecalculateRating(true) end
	
	
	--anims
	local char = defaultCharacter
	if getPropertyFromGroup('notes', id, 'gfNote') then
		char = 'gf'
	end
	
	local animSuffix = getPropertyFromGroup('notes', id, 'animSuffix')
	
	if getPropertyFromGroup('notes', id, 'noteType') == 'Alt Animation' or altAnim then 
		animSuffix = '-alt' 
	end

	if getPropertyFromGroup('notes', id, 'noMissAnimation') == false then
	
		if isCharacter(char) == false or getProperty(char..'.hasMissAnimations') then
	
			playAnim(char, getProperty('singAnimations')[getPropertyFromGroup('notes', id, 'noteData') + 1]..'miss'..animSuffix, true)
			
			--if no animation with alt anims, play normal animation
			if not (animSuffix == '') and not (getProperty(char..'.animation.curAnim.name') == getProperty('singAnimations')[getPropertyFromGroup('notes', id, 'noteData') + 1]..'miss'..animSuffix) then
				playAnim(char, getProperty('singAnimations')[getPropertyFromGroup('notes', id, 'noteData') + 1]..'miss', true)
			end
		
		end
		
	end
	
	if mustPressSwap == true then
		callOnLuas('noteMiss', {id, getPropertyFromGroup('notes', id, 'noteData'), getPropertyFromGroup('notes', id, 'noteType'), getPropertyFromGroup('notes', id, 'isSustainNote')}, false, true, {scriptName})
	end
	
end


-------------------when no ghost tapping-------------------
function noteMissPressP2(direction)

	if getPropertyFromClass('ClientPrefs', 'ghostTapping') == true then return end
	
	setProperty('health', getProperty('health') + 0.05 * getProperty('healthLoss'))
	if getProperty('instakillOnMiss') then
		setProperty('vocals.volume', 0)
		setProperty('health', 2)
	end
	
	comboP2 = 0
	
	if getProperty('practiceMode') == false then scoreP2 = scoreP2 - 10 end
	if getProperty('endingSong') == false then songMissesP2 = songMissesP2 + 1 end
	totalPlayedP2 = totalPlayedP2 + 1
	if lessMemoryUsage == false then RecalculateRating(true) end
	
	playSound('missnote'..getRandomInt(1, 3), getRandomFloat(0.1, 0.2))
	
	if isCharacter(defaultCharacter) == false or getProperty(defaultCharacter..'.hasMissAnimations') then
		playAnim(defaultCharacter, getProperty('singAnimations')[direction + 1]..'miss', true)
	end
	setProperty('vocals.volume', 0)

	if mustPressSwap == true then
		callOnLuas('noteMissPress', {direction})
	end
	
end


--splash (changed this to use real splashes because I was lazy and some issues that this had couldn't be fixed [looking at you custom color splashes])
function spawnNoteSplash(id)

	local noteData = getPropertyFromGroup('notes', id, 'noteData')
	local x = getPropertyFromGroup('opponentStrums', noteData, 'x')
	local y = getPropertyFromGroup('opponentStrums', noteData, 'y')

	--didn't want to use hscript but oh well
	runHaxeCode([[
		game.spawnNoteSplash(]]..x..[[, ]]..y..[[, game.notes.members[]]..id..[[].noteData, game.notes.members[]]..id..[[])
	]])
	
end


-------------------ratings and combo-------------------
function popUpScore(id)
	
	local noteDiff = math.abs(getPropertyFromGroup('notes', id, 'strumTime') - getPropertyFromClass('Conductor', 'songPosition') + getPropertyFromClass('ClientPrefs', 'ratingOffset'))

	setProperty('vocals.volume', 1)

	local daRating = judgeNote(noteDiff)
	
	--add rating and stuff
	for i = 1, #ratingsData do
	
		if daRating == ratingsData[i][1] then
		
			if getPropertyFromGroup('notes', id, 'ratingDisabled') == false then
				ratingsP2[ratingsData[i][1]..'s'] = ratingsP2[ratingsData[i][1]..'s'] + 1 --add 1 to rating variable (for example sicks = sicks + 1)
			end
			
			totalNotesHitP2 = totalNotesHitP2 + ratingsData[i][2]
			
			--note rating
			setPropertyFromGroup('notes', id, 'rating', ratingsData[i][1])
			setPropertyFromGroup('notes', id, 'ratingMod', ratingsData[i][2])

			if getProperty('practiceMode') == false then
				scoreP2 = scoreP2 + ratingsData[1][3] --change this to the bottom one when psych engine fixes notes giving same score lmao
				--scoreP2 = scoreP2 + ratingsData[i][3] 
			end

			--splash
			if ratingsData[i][4] == true and doNoteSplashes == true and getPropertyFromGroup('notes', id, 'noteSplashDisabled') == false then
				spawnNoteSplash(id)
			end
				
			ratingComboStuff(ratingsData[i][1], noteDiff)
			
		end
	
	end
	
	if getProperty('practiceMode') == false and getPropertyFromGroup('notes', id, 'ratingDisabled') == false then
		hitsP2 = hitsP2 + 1
		totalPlayedP2 = totalPlayedP2 + 1
		RecalculateRating(false)
	end

end


--combo and rating sprites
function ratingComboStuff(rating, noteDiff)

	if showCombo == false and showComboNum == false and showRating == false then return end
	
	makeLuaText('coolText', comboP2, 0, 0, 0)
	setTextSize('coolText', 32)
	screenCenter('coolText')
	setProperty('coolText.x', screenWidth * 0.35)

	local pixelShitPart1 = ""
	local pixelShitPart2 = ''

	if getPropertyFromClass('PlayState', 'isPixelStage') then
		pixelShitPart1 = 'pixelUI/'
		pixelShitPart2 = '-pixel'
	end

	local sprName = 'rating'..ratingCount
	local comboName = 'combo'..ratingCount
	

	--rating
	makeLuaSprite(sprName, pixelShitPart1..rating..pixelShitPart2)
	setObjectCamera(sprName, 'camHUD')
	screenCenter(sprName)
	setProperty(sprName..'.x', getProperty('coolText.x') - 40)
	setProperty(sprName..'.y', getProperty(sprName..'.y') - 60)
	setProperty(sprName..'.acceleration.y', 550)
	setProperty(sprName..'.velocity.y', getProperty(sprName..'.velocity.y') - getRandomInt(140, 175))
	setProperty(sprName..'.velocity.x', getProperty(sprName..'.velocity.x') - getRandomInt(0, 10))
	setProperty(sprName..'.visible', not getPropertyFromClass('ClientPrefs', 'hideHud') and showRating)
	setProperty(sprName..'.x', getProperty(sprName..'.x') + comboOffset[1])
	setProperty(sprName..'.y', getProperty(sprName..'.y') - comboOffset[2])
	
	setObjectOrder(sprName, getObjectOrder('strumLineNotes'))
		
	if showRating then
		addLuaSprite(sprName, false)
	end
	
	
	--combo
	makeLuaSprite(comboName, pixelShitPart1..'combo'..pixelShitPart2)
	setObjectCamera(comboName, 'camHUD')
	screenCenter(comboName)
	setProperty(comboName..'.x', getProperty('coolText.x'))
	setProperty(comboName..'.acceleration.y', getRandomInt(200, 300))
	setProperty(comboName..'.velocity.y', getProperty(comboName..'.velocity.y') - getRandomInt(140, 160))
	setProperty(comboName..'.visible', not getPropertyFromClass('ClientPrefs', 'hideHud') and showCombo)
	setProperty(comboName..'.x', getProperty(comboName..'.x') + comboOffset[1])
	setProperty(comboName..'.y', getProperty(comboName..'.y') - comboOffset[2])
	setProperty(comboName..'.y', getProperty(comboName..'.y') + 60)
	setProperty(comboName..'.velocity.x', getProperty(comboName..'.velocity.x') + getRandomInt(1, 10))
	
	setObjectOrder(comboName, getObjectOrder('strumLineNotes'))
	
	if showCombo and comboP2 >= 10 then
		addLuaSprite(comboName, false)
	end


	if not getPropertyFromClass('PlayState', 'isPixelStage') then
		scaleObject(sprName, 0.7, 0.7)
		setProperty(sprName..'.antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'))
		scaleObject(comboName, 0.7, 0.7)
		setProperty(comboName..'.antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'))
	else
		scaleObject(sprName, 6 * 0.85, 6 * 0.85)
		setProperty(sprName..'.antialiasing', false)
		scaleObject(comboName, 6 * 0.85, 6 * 0.85)
		setProperty(comboName..'.antialiasing', false)
	end

	updateHitbox(comboName)
	updateHitbox(sprName)
	
	
	--ms timing from kade engine
	if showMS then
	
		local msTiming = math.floor(noteDiff)
	
		makeLuaText('currentTimingShown', '0ms', 0, 0, 0)
		setObjectCamera('currentTimingShown', 'camHUD')
		setProperty('currentTimingShown.borderSize', 1)
		setTextSize('currentTimingShown', 20)
		setTextString('currentTimingShown', msTiming..'ms')
		setProperty('currentTimingShown.visible', not getPropertyFromClass('ClientPrefs', 'hideHud') and showMS)
		addLuaText('currentTimingShown', true)
		
		if rating == 'shit' or rating == 'bad' then
			setProperty('currentTimingShown.color', getColorFromHex('FF0000'))
		elseif rating == 'good' then
			setProperty('currentTimingShown.color', getColorFromHex('00FF00'))
		else
			setProperty('currentTimingShown.color', getColorFromHex('00FFFF'))
		end
		
		screenCenter('currentTimingShown')
		setProperty('currentTimingShown.x', getProperty(comboName..'.x') + 100)
		setProperty('currentTimingShown.y', getProperty(sprName..'.y') + 100)
		setProperty('currentTimingShown.acceleration.y', 600)
		setProperty('currentTimingShown.velocity.y', getProperty('currentTimingShown.velocity.y') - 150)
		setProperty('currentTimingShown.velocity.x', getProperty('currentTimingShown.velocity.x') + getProperty(comboName..'.velocity.x'))
		
		updateHitbox('currentTimingShown')
	
	end
	
	
	--combo numbers
	local separatedScore = {}
	
	if comboP2 >= 1000 then
		separatedScore[#separatedScore + 1] = math.floor(comboP2 / 1000) % 10
	end
	separatedScore[#separatedScore + 1] = math.floor(comboP2 / 100) % 10
	separatedScore[#separatedScore + 1] = math.floor(comboP2 / 10) % 10
	separatedScore[#separatedScore + 1] = comboP2 % 10


	local daLoop = 0
	local xThing = 0
	for i = 1, #separatedScore do
	
		local comboNumName = i..'num'..ratingCount
		
		makeLuaSprite(comboNumName, pixelShitPart1..'num'..separatedScore[i]..pixelShitPart2)
		setObjectCamera(comboNumName, 'camHUD')
		screenCenter(comboNumName)
		setProperty(comboNumName..'.x', getProperty('coolText.x') + (43 * daLoop) - 90)
		setProperty(comboNumName..'.y', getProperty(comboNumName..'.y') + 80)
		
		setProperty(comboNumName..'.x', getProperty(comboNumName..'.x') + comboOffset[3])
		setProperty(comboNumName..'.y', getProperty(comboNumName..'.y') - comboOffset[4])

		if not getPropertyFromClass('PlayState', 'isPixelStage') then
			setProperty(comboNumName..'.antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'))
			scaleObject(comboNumName, 0.5, 0.5)
		else
			setProperty(comboNumName..'.antialiasing', false)
			scaleObject(comboNumName, 6, 6)
		end
		updateHitbox(comboNumName)

		setProperty(comboNumName..'.acceleration.y', getRandomInt(200, 300))
		setProperty(comboNumName..'.velocity.y', getProperty(comboNumName..'.velocity.y') - getRandomInt(140, 160))
		setProperty(comboNumName..'.velocity.x', getRandomInt(-5, 5))
		setProperty(comboNumName..'.visible', not getPropertyFromClass('ClientPrefs', 'hideHud'))
		
		setObjectOrder(comboNumName, getObjectOrder('strumLineNotes'))

		--if comboP2 >= 10 or comboP2 == 0 then
		if showComboNum then
			addLuaSprite(comboNumName, false)
		end
		
		daLoop = daLoop + 1
		if getProperty(comboNumName..'.x') > xThing then xThing = getProperty(comboNumName..'.x') end
		
	end
	setProperty(comboName..'.x', xThing + 50)

	runTimer(sprName, crochet * 0.001, 1)
	runTimer(comboName, crochet * 0.001, 1)
	runTimer('num'..ratingCount, crochet * 0.002, 1)
	if showMS then runTimer('currentTimingShown', crochet * 0.001, 1) end
	
	ratingCount = ratingCount + 1
	
	if ratingCount > 100 then
		ratingCount = 0
	end

end


-------------------timers and tweens-------------------
function onTimerCompleted(tag)

	if string.find(tag, 'rating') or string.find(tag, 'combo') or tag == 'currentTimingShown' then
		doTweenAlpha(tag, tag, 0, 0.2)
	end
	
	if string.find(tag, 'num') then
		doTweenAlpha('1'..tag, '1'..tag, 0, 0.2)
		doTweenAlpha('2'..tag, '2'..tag, 0, 0.2)
		doTweenAlpha('3'..tag, '3'..tag, 0, 0.2)
		doTweenAlpha('4'..tag, '4'..tag, 0, 0.2)
	end
	
	if string.find(tag, 'splash') then
		removeLuaSprite(tag, true)
	end
	
end


function onTweenCompleted(tag)

	if string.find(tag, 'rating') or string.find(tag, 'combo') or tag == 'currentTimingShown' then
		removeLuaSprite(tag, true)
	end
	
	if string.find(tag, 'num') then
		removeLuaSprite('1'..tag, true)
		removeLuaSprite('2'..tag, true)
		removeLuaSprite('3'..tag, true)
		removeLuaSprite('4'..tag, true)
	end
	
end


--judgement
function judgeNote(diff)

	local timingWindows = {getPropertyFromClass('ClientPrefs', 'sickWindow'), getPropertyFromClass('ClientPrefs', 'goodWindow'), getPropertyFromClass('ClientPrefs', 'badWindow')};
	local windowNames = {'sick', 'good', 'bad'}

	for i = 1, 4 do

		if diff <= timingWindows[math.floor(math.min(i, 4) + 0.5)] then
			return windowNames[i];
		end
		
	end
	return 'shit';
	
end


--change scoreTxt stuff
function RecalculateRating(badHit)

	local ratingStuff = getPropertyFromClass('PlayState', 'ratingStuff') --for same ratings as player 1

	if totalPlayedP2 < 1 then
		ratingNameP2 = '?'
	else

		--Rating Percent
		ratingPercentP2 = math.min(1, math.max(0, totalNotesHitP2 / totalPlayedP2))
		
		--Rating Name
		if ratingPercentP2 >= 1 then
			ratingNameP2 = ratingStuff[#ratingStuff][1] --last string
		else
		
			for i = 1, #ratingStuff do
			
				if ratingPercentP2 < ratingStuff[i][2] then
					ratingNameP2 = ratingStuff[i][1]
					break
				end
				
			end
			
		end
		
		ratingFCP2 = ''
		if ratingsP2.sicks > 0 then ratingFCP2 = 'SFC' end
		if ratingsP2.goods > 0 then ratingFCP2 = 'GFC' end
		if ratingsP2.bads > 0 or ratingsP2.shits > 0 then ratingFCP2 = 'FC' end
		if songMissesP2 > 0 and songMissesP2 < 10 then ratingFCP2 = 'SDCB'
		elseif songMissesP2 >= 10 then ratingFCP2 = 'Clear' end
		
	end

	updateScore(badHit)
	
end


--update scoreTxt stuff (this makes memory go higher for some reason)
function updateScore(miss)

	if ratingNameP2 == '?' then
		setProperty('scoreTxtP2.text', 'Score: '..scoreP2..' | Misses: '..songMissesP2..' | Rating: '..ratingNameP2)
	else
		setProperty('scoreTxtP2.text', 'Score: '..scoreP2..' | Misses: '..songMissesP2..' | Rating: '..ratingNameP2..' ('..floorDecimal(ratingPercentP2 * 100, 2)..'%) - '..ratingFCP2)
	end

	if getPropertyFromClass('ClientPrefs', 'scoreZoom') and miss == false then
		
		setProperty('scoreTxtP2.scale.x', 1.075)
		setProperty('scoreTxtP2.scale.y', 1.075)
		
		doTweenX('scoreTxtP2scaleX', 'scoreTxtP2.scale', 1, 0.2)
		doTweenY('scoreTxtP2scaleY', 'scoreTxtP2.scale', 1, 0.2)
		
	end

end


-------------------end screen-------------------
if playable == true and doEndScreen == true and lessMemoryUsage == false then

	function onEndSong()
	
		if endContinue == false then
			startEndScreen()
			return Function_Stop
		end
	
		return Function_Continue
		
	end

	function startEndScreen()

		inEndScreen = true
		setProperty('inCutscene', true)
		setProperty('camHUD.visible', false)
		
		setProperty('vocals.volume', 0)
		playMusic(formatToSongPath(getPropertyFromClass('ClientPrefs', 'pauseMusic')), 1)
		
		
		--make sprites
		makeLuaSprite('endBG', '', 0, 0)
		makeGraphic('endBG', screenWidth, screenHeight, '000000')
		setProperty('endBG.alpha', 0.6)
		setObjectCamera('endBG', 'camOther')
		addLuaSprite('endBG', true)

		makeLuaText('endTxt', '', 0, 0, 150)
		setObjectCamera('endTxt', 'camOther')
		setTextSize('endTxt', 25)
		addLuaText('endTxt', true)
		
		makeLuaText('continueTxt', 'PRESS ENTER TO CONTINUE', 0, 0, screenHeight - 100)
		setObjectCamera('continueTxt', 'camOther')
		setTextSize('continueTxt', 40)
		addLuaText('continueTxt', true)
		
		makeLuaText('songNameTxt', (songName..' - '..difficultyName):upper(), 0, 0, 60)
		setObjectCamera('songNameTxt', 'camOther')
		setTextSize('songNameTxt', 35)
		addLuaText('songNameTxt', true)
		

		--texts
		local scoreTxtP2 = 'Score: '..scoreP2..' | Misses: '..songMissesP2..' | Rating: '..ratingNameP2
		
		if not (ratingNameP2 == '?') then
			scoreTxtP2 = 'Score: '..scoreP2..' | Misses: '..songMissesP2..' | Rating: '..ratingNameP2..' ('..floorDecimal(ratingPercentP2 * 100, 2)..'%) - '..ratingFCP2
		end
		
		setTextString('endTxt', [[
		
		PLAYER 1:
		
		]]..getProperty('scoreTxt.text')..' | Notes hit: '..hitsP1..[[
		
		
		
		
		PLAYER 2:
		
		]]..scoreTxtP2..' | Notes hit: '..hitsP2..[[
		
		
		
		
		
		TOTAL NOTES P1: ]]..(hitsP1 + getProperty('songMisses'))..[[
		
		
		
		TOTAL NOTES P2: ]]..(hitsP2 + noteMissesP2)..[[
		
		]])

		screenCenter('endTxt', 'x')
		screenCenter('continueTxt', 'x')
		screenCenter('songNameTxt', 'x')

	end

end


-------------------player 1 swapped functions-------------------
if playable == true then

	if differentCharactersMode == true or mustPressSwap == true then

		function goodNoteHit(id, noteData, noteType, isSustainNote)
		
			--camera zoom thingy
			if mustPressSwap == true and not (formatToSongPath(getPropertyFromClass('PlayState', 'SONG.song')) == 'tutorial') then
				setProperty('camZooming', true)
			end

			if getPropertyFromGroup('notes', id, 'inEditor') == false then
		
				local animToPlay = getProperty('singAnimations')[noteData + 1]
				local animSuffix = getPropertyFromGroup('notes', id, 'animSuffix')
				local char = 'dad'
				
				if differentCharactersMode == true then
					char = swapCharacterP1
				end
					
				if noteType == 'Alt Animation' or altAnim then animSuffix = '-alt' end
					
				if getPropertyFromGroup('notes', id, 'gfNote') then
					
					if not (getProperty('gf') == nil) then
						
						playAnim('gf', animToPlay..animSuffix, true)
							
						--if no animation with alt anims, play normal animation
						if not (animSuffix == '') and not (getProperty('gf.animation.curAnim.name') == animToPlay..animSuffix) then
							playAnim('gf', animToPlay, true)
						end
						
						setProperty('gf.holdTimer', 0)
						
						gfSingingP1 = true
							
					end
						
				else
					
					playAnim(char, animToPlay..animSuffix, true)
					
					--if no animation with alt anims, play normal animation
					if not (animSuffix == '') and not (getProperty(char..'.animation.curAnim.name') == animToPlay..animSuffix) then
						playAnim(char, animToPlay, true)
					end
					
					if isCharacter(char) == true then setProperty(char..'.holdTimer', 0) end
					
					setProperty(char..'.specialAnim', false)
					
					gfSingingP1 = false
					
				end
				
				if getPropertyFromGroup('notes', id, 'noteType') == 'Hey!' then
				
					playAnim(char, 'hey', true)
					
					if isCharacter(char) == true then
						setProperty(char..'.specialAnim', true)
						setProperty(char..'.heyTimer', 0.6)
					end
					
					if not (getProperty('gf') == nil) then
						playAnim('gf', 'cheer', true)
						setProperty('gf.specialAnim', true)
						setProperty('gf.heyTimer', 0.6)
					end
					
				end
			
			end
			
			if isSustainNote == false then
				hitsP1 = hitsP1 + 1
				totalNotesP1 = totalNotesP1 + 1
			end
			
			if mustPressSwap == true then
				callOnLuas('opponentNoteHit', {id, noteData, noteType, isSustainNote}, false, true, {scriptName})
			end

		end
		
		
		function noteMiss(id, noteData, noteType, isSustainNote)
		
			local char = 'dad'
				
			if differentCharactersMode == true then
				char = swapCharacterP1
			end
				
			if getPropertyFromGroup('notes', id, 'gfNote') then
				char = 'gf'
			end
			
			local animSuffix = getPropertyFromGroup('notes', id, 'animSuffix')
			
			if noteType == 'Alt Animation' or altAnim then animSuffix = '-alt' end

			if isCharacter(char) == false or getProperty(char..'.hasMissAnimations') then
			
				playAnim(char, getProperty('singAnimations')[noteData + 1]..'miss'..animSuffix, true)
				
				--if no animation with alt anims, play normal animation
				if not (animSuffix == '') and not (getProperty(char..'.animation.curAnim.name') == getProperty('singAnimations')[noteData + 1]..'miss'..animSuffix) then
					playAnim(char, getProperty('singAnimations')[noteData + 1]..'miss', true)
				end
				
			end

		end
		
	else

		function goodNoteHit(id, noteData, noteType, isSustainNote)
		
			if isSustainNote == false then
				hitsP1 = hitsP1 + 1
			end
			
		end

	end

end


--gameover for P1
if playable == true and cannotDieP1 == true then

	function onGameOver()
	
		if getProperty('health') < 0 then
			setProperty('health', 0)
		end
		
		return Function_Stop
		
	end

end


function animThingP1(elapsed)

	if ((differentCharactersMode == true) or (mustPressSwap == true and differentCharactersMode == false)) and isCharacter(swapCharacterP1) == true then
	
		--makes the player 1 not dance
		if getProperty(swapCharacterP1..'.debugMode') == false then setProperty(swapCharacterP1..'.debugMode', true) end

		--a
		animControlP1(elapsed)
		
		--hey timer
		if getProperty(swapCharacterP1..'.heyTimer') > 0 then
			setProperty(swapCharacterP1..'.heyTimer', getProperty(swapCharacterP1..'.heyTimer') - elapsed)
		end
		
		--special anims
		if getProperty(swapCharacterP1..'.heyTimer') <= 0 then
		
			if getProperty(swapCharacterP1..'.specialAnim') == true then
			
				if getProperty(swapCharacterP1..'.animation.curAnim.finished') == true then
					setProperty(swapCharacterP1..'.specialAnim', false)
					dance(swapCharacterP1)
				end
				
			end
			setProperty(swapCharacterP1..'.heyTimer', 0)
			
		end
		
		--loop anim
		if getProperty(swapCharacterP1..'.animation.curAnim.finished') and getProperty(swapCharacterP1..'.specialAnim') == false then
			playAnim(swapCharacterP1, getProperty(swapCharacterP1..'.animation.curAnim.name')..'-loop', true)
		end
		
	end

end


function animThingP2(elapsed)

	if isCharacter(defaultCharacter) == true then 
		
		--makes the opponent not dance
		if getProperty(defaultCharacter..'.debugMode') == false then setProperty(defaultCharacter..'.debugMode', true) end
		
		--a
		animControlP2(elapsed)
		
		--hey timer
		if getProperty(defaultCharacter..'.heyTimer') > 0 then
			setProperty(defaultCharacter..'.heyTimer', getProperty(defaultCharacter..'.heyTimer') - elapsed)
		end

		--special anims
		if getProperty(defaultCharacter..'.heyTimer') <= 0 then
		
			if getProperty(defaultCharacter..'.specialAnim') == true then
			
				if getProperty(defaultCharacter..'.animation.curAnim.finished') == true then
					setProperty(defaultCharacter..'.specialAnim', false)
					dance(defaultCharacter)
				end
				
			end
			setProperty(defaultCharacter..'.heyTimer', 0)
			
		end

		--loop anim
		if getProperty(defaultCharacter..'.animation.curAnim.finished') and getProperty(defaultCharacter..'.specialAnim') == false then
			playAnim(defaultCharacter, getProperty(defaultCharacter..'.animation.curAnim.name')..'-loop', true)
		end
	
	end

end


--idle anim thing for sing animations
function animControlP1(elapsed)

	--player 1 hold timer
	if not (string.find(getProperty(swapCharacterP1..'.animation.curAnim.name'), 'idle') or string.find(getProperty(swapCharacterP1..'.animation.curAnim.name'), 'dance')) then
		setProperty(swapCharacterP1..'.holdTimer', getProperty(swapCharacterP1..'.holdTimer') + elapsed)
	end
	
	local controlHoldArray = {
		keyPressed('left'), 
		keyPressed('down'), 
		keyPressed('up'),
		keyPressed('right')
	}

	if getProperty('cpuControlled') == true or (gfSingingP1 == true) then
		controlHoldArray = {false, false, false, false}
	end
	
	--check if the player 1 is not holding any keys and then make the animation go back to idle
	if table.contains(controlHoldArray, true) == false then
	
		if not (getProperty(swapCharacterP1..'.animation.curAnim') == nil) and getProperty(swapCharacterP1..'.holdTimer') > (getPropertyFromClass('Conductor', 'stepCrochet') * 0.0011 * getProperty(swapCharacterP1..'.singDuration')) and getProperty(defaultCharacter..'.skipDance') == false then
			
			if (string.find(getProperty(swapCharacterP1..'.animation.curAnim.name'), 'sing') and not (string.find(getProperty(swapCharacterP1..'.animation.curAnim.name'), 'miss'))) then
				dance(swapCharacterP1)
			end
			
		end
		
	end
		
end


--just a copy of above but for P2
function animControlP2(elapsed)

	--opponent hold timer
	if not (string.find(getProperty(defaultCharacter..'.animation.curAnim.name'), 'idle') or string.find(getProperty(defaultCharacter..'.animation.curAnim.name'), 'dance')) then
		setProperty(defaultCharacter..'.holdTimer', getProperty(defaultCharacter..'.holdTimer') + elapsed)
	end
	
	local controlHoldArray = {}
	
	--add keys to array (for extra keys and notes woahh)
	for i = 1, #keys do
		controlHoldArray[i] = getPropertyFromClass('flixel.FlxG', 'keys.pressed.'..keys[i]:upper())
	end
	
	if cpuControlled == true or (gfSinging == true) then
	
		for i = 1, #keys do
			controlHoldArray[i] = false
		end
		
	end
	
	--check if you are not holding any keys and then make the animation go back to idle
	if table.contains(controlHoldArray, true) == false then
	
		if not (getProperty(defaultCharacter..'.animation.curAnim') == nil) and getProperty(defaultCharacter..'.holdTimer') > (getPropertyFromClass('Conductor', 'stepCrochet') * 0.0011 * getProperty(defaultCharacter..'.singDuration')) and getProperty(defaultCharacter..'.skipDance') == false then
		
			if (string.find(getProperty(defaultCharacter..'.animation.curAnim.name'), 'sing') and not (string.find(getProperty(defaultCharacter..'.animation.curAnim.name'), 'miss'))) then
				dance(defaultCharacter)
			end
			
		end
		
	end
		
end


-------------------other useful functions-------------------

--strum
function strumPlayAnim(id, anim, forced, resetTime)

	if resetTime == nil then resetTime = 0 end
	if forced == nil then forced = false end
	
	--resets the animation
	if forced == true then
		setPropertyFromGroup('strumLineNotes', id, 'animation.name', nil)
	end
	
	setPropertyFromGroup('strumLineNotes', id, 'animation.name', anim) --play animation
	setPropertyFromGroup('strumLineNotes', id, 'resetAnim', resetTime)
	
	--center offsets and origins
	setPropertyFromGroup('strumLineNotes', id, 'origin.x', getPropertyFromGroup('strumLineNotes', id, 'frameWidth') / 2)
	setPropertyFromGroup('strumLineNotes', id, 'origin.y', getPropertyFromGroup('strumLineNotes', id, 'frameHeight') / 2)
	setPropertyFromGroup('strumLineNotes', id, 'offset.x', (getPropertyFromGroup('strumLineNotes', id, 'frameWidth') - getPropertyFromGroup('strumLineNotes', id, 'width')) / 2)
	setPropertyFromGroup('strumLineNotes', id, 'offset.y', (getPropertyFromGroup('strumLineNotes', id, 'frameHeight') - getPropertyFromGroup('strumLineNotes', id, 'height')) / 2)

end


function isCharacter(char)

	if char == 'boyfriend' or char == 'dad' or char == 'gf' then
		return true
	end
	
	return false

end


function dance(char)

	if getProperty(char..'.specialAnim') == false then

		--make character dance
		if isCharacter(char) == true and getProperty(char..'.danceIdle') then
		
			setProperty(char..'.danced', not getProperty(char..'.danced'))
			
			if getProperty(char..'.danced') then
				playAnim(char, 'danceRight'..getProperty(char..'.idleSuffix'))
			else
				playAnim(char, 'danceLeft'..getProperty(char..'.idleSuffix'))
			end
			
		else
			playAnim(char, 'idle'..getProperty(char..'.idleSuffix'))
		end
		
		--debugPrint('dance')
	
	end
				
end


--taken from source code (Highscore.floorDecimal)
function floorDecimal(value, decimals)

	if decimals < 1 then
		return math.floor(value)
	end

	local tempMult = 1
	for i = 0, decimals-1 do
		tempMult = tempMult * 10
	end
	local newValue = math.floor(value * tempMult)
	return newValue / tempMult
	
end


--really useful
function table.contains(table, val)

	for i = 1, #table do

		if table[i] == val then
			return true
		end

	end
	return false

end


--for the tutorial camera thing
function formatToSongPath(path)
	return path:lower():gsub(' ', '-')
end


--unused but could be useful
function getKeyFromID(key)

	if key > -1 and not (key == nil) then
		return keys[key + 1]
	end
	
	return -1

end