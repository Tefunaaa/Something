#Requires AutoHotkey v2
#Include "otherFiles\SetupFunctions.ahk"
#Include "otherFiles\Images.ahk"
global TowerActivated := 0
if(FileExist("otherFiles\towerMacro.ahk")) {
    global TowerActivated := 1
    try {
        #Include "*i otherFiles\towerMacro.ahk"
    }
}

active := A_ScriptDir
global Xtl := 0, Ytl := 0, Xbr := 0, Ybr := 0
global startRaidTime := 0 
global elapedRaidTime := 0
global offset := 0
global reconnecting := 0
Send "{" walkInput " up}"
Send "{S up}"

/*
Function Name: ImageSearchFunctionOld()-

Parameters: 
@imagePath > file path to the image being used

Use: 
Searches the entire screen for an image. Much more inefficient, but useful for some scenarios when we don't
100% know where the image will be

Return:
@successful > true
@unsuccesful > false
*/
ImageSearchFunctionOld(imagePath) { ;make it so it only searches where we know the image will be
    CoordMode("Pixel", "Window")
    global FoundX, FoundY
    if(WinExist("ahk_exe RobloxPlayerBeta.exe")) {
        WinActivate("ahk_exe RobloxPlayerBeta.exe")
    } else {
        While !WinExist("ahk_exe RobloxPlayerBeta.exe") {
            Sleep(1000)
        }
        WinActivate("ahk_exe RobloxPlayerBeta.exe")
    }
    WinGetPos(&X, &Y, &W, &H, "ahk_exe RobloxPlayerBeta.exe")
    ;WinActivate("ahk_exe RobloxPlayerBeta.exe")
    if ImageSearch(&FoundX, &FoundY, 0, 0, W, H, imagePath) {
        CoordMode("Mouse", "Window")
        return true
    } else {
        CoordMode("Mouse", "Window")
        return false
        
    }
}


/*
Function Name: ImageSearchFunction()-

Parameters: 
@imagePath > file path to the image being used
@Xtl > Top left X of search area
@Ytl > Top left Y of search area
@Xbr > Bottom Right X of search area
@Ybr > Botth Right Y of search area

Use: 
Searches the entire screen for an image. Much more inefficient, but useful for some scenarios when we don't
100% know where the image will be

Return:
@successful > true
@unsuccesful > false
*/
ImageSearchFunction(imagePath, Xtl, Ytl, Xbr, Ybr) { ;make it so it only searches where we know the image will be
    CoordMode("Pixel", "Window")
    global FoundX, FoundY
    if(WinExist("ahk_exe RobloxPlayerBeta.exe")) {
        WinActivate("ahk_exe RobloxPlayerBeta.exe")
    } else {
        While !WinExist("ahk_exe RobloxPlayerBeta.exe") {
            Sleep(1000)
        }
        WinActivate("ahk_exe RobloxPlayerBeta.exe")
    }
    WinGetPos(&X, &Y, &W, &H, "ahk_exe RobloxPlayerBeta.exe")
    if ImageSearch(&FoundX, &FoundY, Xtl, Ytl, Xbr, Ybr, imagePath) {
        CoordMode("Mouse", "Window")
        return true
    } else {
        CoordMode("Mouse", "Window")
        return false
    }
}




joinPrivateSerLink() {
    Run("https://www.roblox.com/games/12886143095/QOL-Limited-Extend-Anime-Last-Stand?privateServerLinkCode=76538023244128955660713296420545")
    return
}

/*
Function Name: MainLoop()-

Parameters: 
@none

Use: 
Checks for various things to start

Variables:
@stuff

Return:
@none
*/
MainLoop() {
    ; Add main loop check
    ;UpdateCurrentProcess("Must have Update Log open to start. If you are stuck here, REJOIN PRIVATE SERVER. There is a set delay of **2 seconds**")
    if(Raid != Castle) {
        global psLink := PSLinkButton.Value
        if(psLink != "") {
            if(PSReconnectValue = 1) {
                if(reconnecting = 1) {
                    global reconnecting := 0
                    joinPrivateSerLink()
                }
            } else if (PSReconnectValue = 0){
                joinPrivateSerLink()
            }
        } else {
            forceSize()
        }
        while !ImageSearchFunction(step1perm, 546, 181, 583, 225) {
            if nextCheck() {
                continue
            }
            UpdateCurrentProcess("Looking for Update Log. If you are stuck here, you did something wrong. Follow #macro-setup")
            Sleep(200)
        }
        if(Raid = Leaf || Raid = Hell || Raid = Snowy || Raid = Marine) { ;If a raid is selected (1-4) then run MoveToRaid
            MoveToRaid() ;Initial move to raid 
        } else if (Raid = Slime || Raid = Tropical) { ;Slime Portal
            Click()
            Send "{Tab}"
            Sleep(5000)
            MoveToPortal()
        }
        while true {
            MainFunction()
        }
    } else if (Raid = Castle) {
        if(TowerActivated = 1) { 
            
        UpdateCurrentProcess("Looking for Tower UI")
        FloorNumber := FloorNumberEdit.Value
        InfinitySlot := InfinitySlotEdit.Value
        infinityCastle(FloorNumber, InfinitySlot)
        }
        ;MsgBox("Disabled!")
    }

}

/*
Function Name: mainFunction()-

Parameters: 
@none

Use: 
Main game loop for when it should be started.

Variables:
@stuff

Return:
@none
*/
MainFunction() { 
    if(upgradeStyle = 2) {
        SetupUpgrade()
    }
    global running := 1
    while running = 1 {
        if(lost = 1) {
            if(psLink != "") {
                if(PSReconnectValue = 1) {
                    if(reconnecting = 1) {
                        UpdateCurrentProcess(reconnecting " reconnecting value .. ")
                        global reconnecting := 0
                        joinPrivateSerLink()
                    }
                } else if (PSReconnectValue = 0) {
                    joinPrivateSerLink()
                }
            }
        }
        UpdateCurrentProcess("Starting")
        PlaceOrderSort() ;Sorts UnitData
        if lobbyCheck() { ;Checks for Lobby button / Forces lobby button if leaf lost
            continue
        }
        if raidFirstWave() { ;Calls to a function to return the First Wave path, then searches for it 
            continue
        }
        if leafySpawnCheck() { ;If the raid is leaf, needs more advanced logic because of 2 spawns. Does spawn as above
            continue
        }      
        raidSetup() ;Sets up the various maps (Dash, Scroll, Etc)
        global startRaidTime := A_min
        if setupAllUnits() {
            continue
        }
        UpdateCurrentProcess("Moving to Setup/End")
        ;if != 0
        if(upgradeStyle = 1) { ;Main upgrade styel
            setupMainUnit()
        } else if (upgradeStyle = 2) { ;Input upgrade boxes. This would mean that they have completed all their upgrades
            loop {
                if nextCheck() {
                    return
                } else {
                    sleep(1000)
                }
            }
            return
        }
        UpdateCurrentProcess("End of Loop")
    }
} 


/*
Function Name: placeOrderSort()-

Parameters: 
@none

Use: 
Sorts the units based on when they should be placed (Unit 2 is placed on wave1, Unit1 is placed on wave2, etc)

Variables:
@enabledUnits > number of enabled units

Return:
@none
*/
PlaceOrderSort() {
    enabledUnits := 0
    for i, unit in UnitData {
        if (unit.Enabled.Value = 1) {
            enabledUnits++
        }
    }

    if (enabledUnits > 1) {
        z := 0
        while (z < 2) {
            z += 1
            for i, unit in UnitData {
                if (i < enabledUnits && UnitData[i].Wave.Value > UnitData[i + 1].Wave.Value) {
                    Temp := UnitData[i]
                    UnitData[i] := UnitData[i + 1]
                    UnitData[i + 1] := Temp
                }
            }
        }
    }
}


/*
Function Name: lobbyCheck()-

Parameters: 
@none

Use: 
Checks for the lobby button, can also be used to check for it no matter what on a loss

Variables:
@stuff

Return:
@none
*/
lobbyCheck() {
    UpdateCurrentProcess("Checking for Update Log. If you are stuck on this, rejoin the private server.")
    if(Raid != 0) {
        if(lost = 1) {
            while !ImageSearchFunction(step1perm, 546, 181, 583, 225) {
                if nextCheck() {
                    return true
                }
                Sleep(200)
            }
            Sleep(5000)
            while !ImageSearchFunction(step1perm, 546, 181, 583, 225) {
                if nextCheck() {
                    return true
                }
                Sleep(200)
            }
            global lost := 0
            if(Raid != Slime && Raid != Tropical) {
                MoveToRaid()
            } else if(Raid = Slime || Raid = Tropical) {
                Click()
                Send "{Tab}"
                Sleep(5000)
                MoveToPortal()
            }
        } else if (ImageSearchFunction(step1perm, 546, 181, 583, 225)) {
            UpdateCurrentProcess("lobby found.")
            if(Raid != Slime) {
                MoveToRaid()
            } else if(Raid = Slime || Raid = Tropical) {
                Click()
                Send "{Tab}"
                Sleep(5000)
                MoveToPortal()
            }
        } 
    }
}


/*
Function Name: moveToRaid()-

Parameters: 
@none

Use: 
Move to raid logic

Variables:
@stuff

Return:
@none
*/
MoveToRaid() {
    ;Step 1 - Update Log
    ;Step 2 - Teleport
    ;Step 3 - Story
    ;Step 4 - Raid
    ;Step 5 - Close Teleport
    ;Step 6 - Find Raid Select Image
    ;Step 7 - Find Stage 6
    ;Step 8 - Start
    ;Step 9 - Start
    steps := []
    global i := 0
    z := 0
    while(z < 9) {
        i += 1
        z += 1
        if i = 6 {
            if (Raid = Snowy) {
                imagePath := raidMovePath . "6snowy.png"
            } else if (Raid = Leaf) {
                imagePath := raidMovePath . "6leaf.png" 
            } else if (Raid = Marine) {
                imagePath := raidMovePath . "6marine.png"
            } else if (Raid = Hell) {
                imagePath := raidMovePath . "6hell.png"
            }
        } else {
            imagePath := raidMovePath . i . ".png"
        }
        steps.push(imagePath)
    }
    ;UpdateCurrentProcess("Looking for 'Update Log.' Make sure to have it open.")
    ; shouldnt matter ? Sleep(5000) ; Delay for loading in
    ; Coordinate list for each index
    coordinates := [
        {x1: 546, y1: 181, x2: 583, y2: 225},  ; index 1
        {x1: 73, y1: 246, x2: 133, y2: 297},   ; index 2
        {x1: 282, y1: 177, x2: 527, y2: 325},  ; index 3
        {x1: 281, y1: 365, x2: 533, y2: 433},  ; index 4
        {x1: 496, y1: 112, x2: 555, y2: 166},  ; index 5
        {x1: 181, y1: 225, x2: 306, y2: 422},  ; index 6
        {x1: 340, y1: 374, x2: 463, y2: 407},  ; index 7
        {x1: 343, y1: 421, x2: 480, y2: 463},  ; index 8
        {x1: 320, y1: 402, x2: 492, y2: 452}   ; index 9
    ]
    for index, currentStep in steps {
        UpdateCurrentProcess("Looking for step " index)
        if(clickDelayInput.Value != 0) {
            UpdateCurrentProcess("Delaying for " clickDelayInput.Value " seconds")
            Sleep(clickDelayInput.Value*1000)
        }
        ; Get the coordinates based on index
        coord := coordinates[index]
        x1 := coord.x1, y1 := coord.y1, x2 := coord.x2, y2 := coord.y2

        if(index = 1 || index = 2 || index = 4 || index = 5 || index = 7 || index = 8 || index = 9) {
            while !ImageSearchFunction(currentStep, x1, y1, x2, y2) {
                Sleep(100)
                if nextCheck() {
                    return true
                }
            }
            moveToTarget()
        } else if (index = 3) {
            while !ImageSearchFunction(currentStep, x1, y1, x2, y2) {
                Sleep(100)
                if nextCheck() {
                    return true
                }
            }
            moveToTarget()
            Send("{WheelDown}")
        } else if (index = 6) {
            Send "{ " dashInput "}"
            Sleep(500)
            if !ImageSearchFunction(steps[6], x1, y1, x2, y2) {
                loop {
                    if (ImageSearchFunction(steps[6], x1, y1, x2, y2)) {
                        break
                    }
                    Send "{ " dashInput "}"
                    ;Send("{S down}")
                    Sleep(1000)
                }
            }
            moveToTarget()
            ;Send("{" walkInput " up}")
        }
    }
}


/*
Function Name: moveToPortal()-

Parameters: 
@none

Use: 
Move to portal logic

Variables:
@stuff

Return:
@none
*/
MoveToPortal() {
    ; Step 1 - Update Log
    ; Step 2 - Item Bag
    ; Step 3 - Portal Tab
    ; Step 4 - Search
    ; Step 5 - Send "portal name"
    ; Step 6 - Click Top Left Portal Box
    ; Step 7 - Activate
    ; Step 8 - Start Now
    steps := []
    z := 0
    while (z < 8) {
        if (z != 4 || z != 5 || z != 6) {
            z += 1
            imagePath := portalMovePath . z . ".png"
            steps.Push(imagePath)
        }
    }
    UpdateCurrentProcess("Looking for 'Update Log.' Make sure to have it open.")
    coordinates := [
        {x1: 546, y1: 181, x2: 583, y2: 225},  ; Step 1
        {x1: 16, y1: 302, x2: 68, y2: 359},   ; Step 2
        {x1: 266, y1: 191, x2: 372, y2: 230},  ; Step 3
        {x1: 0, y1: 0, x2: 0, y2: 0},  ; Step 4 (Handled separately)
        {x1: 0, y1: 0, x2: 0, y2: 0},  ; Step 5 (Handled separately)
        {x1: 0, y1: 0, x2: 0, y2: 0},  ; Step 6 (Handled separately)
        {x1: 147, y1: 166, x2: 657, y2: 465},  ; Step 7
        {x1: 27, y1: 405, x2: 118, y2: 446},  ; Step 8
    ]
    for index, currentStep in steps {
        UpdateCurrentProcess("Looking for step " index)
        if (clickDelayInput.Value != 0) {
            UpdateCurrentProcess("Delaying for " clickDelayInput.Value " seconds")
            Sleep(clickDelayInput.Value * 1000)
        }
        coord := coordinates[index]
        x1 := coord.x1, y1 := coord.y1, x2 := coord.x2, y2 := coord.y2
        if (index = 1 || index = 2 || index = 8) {
            while !ImageSearchFunction(currentStep, x1, y1, x2, y2) {
                Sleep(500)
            }
            Sleep(500)
            moveToTarget() ;this means it detected but click might not register? if doesnt click index3, wont detect index4, so index4 could click
        }  else if index = 3 { ;INVENTORY NOT LOADING
            checkCount := 0
            while !ImageSearchFunction(currentStep, x1, y1, x2, y2) { ;While doesnt find portal tab, if it doesnt find it after 5 seconds of searching click again
                Sleep(500)
                if(checkCount = 20) {
                    UpdateCurrentProcess("Attempting to re-open inventory")
                    MouseRelativeMove()
                    Click() ;Assume inventory was not opened, click again
                    Sleep(500)
                    CheckCount := 0 ;Resets count
                }
                checkCount += 1
            }
            Sleep(500)
            moveToTarget()
        } else if index = 4 {
            moveToManualTarget(408, 187)  ; Move to Search Bar
            Sleep(500)
            Click()
        } else if index = 5 {
            Sleep(10000)  ; Time for portals to load
            Send("{Backspace 5}")
            if(Raid = Slime) {
                Sleep(500)
                Send(slimeName)
                Sleep(500)
            } else if(Raid = Tropical) {
                Sleep(500)
                Send(tropicalName)
                Sleep(500)
            }
            MouseMove(0,-30,5,"R")
            MouseRelativeMove()
            Click() ;clicked off
            Sleep(500)
            Send "{" navInput "}"
            Sleep(500)
            Send "{Down}"
            Sleep(250)
            Send "{Down}"
            Sleep(250)
            Send "{Left}"
            Sleep(250)
            Send "{Left}"
            Sleep(250)
            Send "{Left}"
            Sleep(250)
            Send "{Left}"
            Sleep(250)
            Send "{Left}"
            Sleep(250)
            Send "{Left}"
            Sleep(250)
            Send "{Left}"
            Sleep(250)
        } else if index = 6 {
            if !checkAllTiers() { ;Found The Image
                ;handleTierSearchFallback([Tier5, Tier4, Tier3, Tier2, Tier1])
            }
        } else if index = 7 {
            while !ImageSearchFunctionOld(currentStep) {
                Sleep(500)
            }
            Sleep(1000)
            moveToTarget()
        }
    }
}


/*
Function Name: checkAllTiers()-

Parameters: 
@none

Use: 
Creates an array of tier/challenge images based on which ones re enabled

Variables:
@tierImages map > Map of all tier images
@challengeImages map > Map of all challenge images

Return:
@true > A tier+non excluded challenge was found, moves on to next step
@false > no image was found
*/
checkAllTiers() {
    ; Define the image variables for each tier
    tierImages := Map(
        6, Tier6Image,
        5, Tier5Image,
        4, Tier4Image,
        3, Tier3Image,
        2, Tier2Image,
        1, Tier1Image
    )
    challengeImages := Map(
        6, BarebonesImage,
        5, FlightImage,
        4, ShortRangeImage,
        3, SpeedyImage,
        2, TowerLimitImage,
        1, HighCostImage
    )
    ; Create a list of enabled tiers
    enabledImages := []
    for tierIndex, tierImage in tierImages {
        if (isTierEnabled(tierIndex)) {
            enabledImages.Push(tierImage)
        }
    }
    ; Create a list of enabled challenges
    enabledChallenges := []
    for challengeIndex, challengeImage in challengeImages {
        if (isChallengeEnabled(challengeIndex)) {
            enabledChallenges.Push(challengeImage)
        }
    }
    ; Pass the list of enabled images to the search function
    if (handleTierImageSearch(enabledImages, enabledChallenges)) {
        Send "{" navInput "}"
        return true  ; Stop if an image is found
    }
    return false  ; No image found, return false
}


;Passes in an index, returns the value of the index (1 if enabled, 0 if disabled)
isTierEnabled(tierIndex) {
    switch tierIndex {
        case 1: return Tier1
        case 2: return Tier2
        case 3: return Tier3
        case 4: return Tier4
        case 5: return Tier5
        case 6: return Tier6
    }
    return false
}


;Passes in an index, returns the value of the index (1 if enabled, 0 if disabled)
isChallengeEnabled(challengeIndex) {
    switch challengeIndex {
        case 1: return HighCost
        case 2: return Tower
        case 3: return Speedy
        case 4: return ShortRange
        case 5: return Flight
        case 6: return Barebones 
    }
    return false
}


/*
Function Name: handleTierImageSearch()-

Parameters: 
@enabledImages > array of all the enabled portal tier images
@enabledChallenges > array of all the enabled challenge images

Use: 
Uses the Left/Right arrows to search through the inventory for the selected tier/challenges

Variables:
@movedCounter > keep track of  where it is in a row, moves down every 6 moves
@x > used as a toggle to move left or right

@each > Index
@tierImage > object in enabledImages
@enabledImages > array of enabled tier images

@index > index
@enabledChallengeImage > object in enabledChallenges
@enabledChallenges > array of all the enabled challenge images

@challengeFound > used as a flag to skip over a correct tier excluded challenge

@location > used as a fail-safe to confirm that whatever gets selected is a portal

Return:
@true > a next check was found
@false > as long as the raid isn't leaf, it will return false after finding
*/
handleTierImageSearch(enabledImages, enabledChallenges) {
    MovedCounter := 0
    global x := 5 
    ; Start the loop to search through all enabled images
    while true {
        ; Iterate through each enabled tier image
        for each, tierImage in enabledImages {
            if ImageSearchFunction(tierImage, 161, 169, 800, 520) {
                challengeFound := false
                ; Iterate through each enabled challenge image
                for index, enabledChallengeImage in enabledChallenges {
                    if ImageSearchFunction(enabledChallengeImage, 161, 169, 800, 520) {
                        challengeFound := true
                        break  ; Exit loop if any challenge image is found
                    }
                }
                ; If no challenges are found, return true
                if !challengeFound {
                    return true
                }
            }
        }
        ; Navigation logic
        if (x > 0) {
            Send "{Right}"
        } else if (x < 0) {
            Send "{Left}"
        }
        Send "{Enter}"
        ;Sleep(500)
        ; Check for non-portal and exit if necessary
        if !ImageSearchFunction(Location, 66, 86, 778, 520) {
            if !ImageSearchFunction(Location, 66, 86, 778, 520) {
                if !ImageSearchFunction(Location, 66, 86, 778, 520) {
                    Send "{" navInput "}"
                    MsgBox("Triple confirmed no portal found. Closing for your safety. If it did not search for a portal, this means that you do not have UI navigation enabled, or did not change the UI Nav Keybind in your Macro UI settings.")
                    ExitApp
                }
            }
        }
        ;Sleep(100)
        ; Adjust movement after a certain number of moves
        if MovedCounter = 6 {
            for each, tierImage in enabledImages { ;check for far portal
                UpdateCurrentProcess("")
                if ImageSearchFunction(tierImage, 161, 169, 800, 520) {
                    challengeFound := false
                    ; Iterate through each enabled challenge image
                    for index, enabledChallengeImage in enabledChallenges {
                        if ImageSearchFunction(enabledChallengeImage, 161, 169, 800, 520) {
                            challengeFound := true
                            break  ; Exit loop if any challenge image is found
                        }
                    }
                    ; If no challenges are found, return true
                    if !challengeFound {
                        return true
                    }
                }
            }
            x := -x
            Send "{Down}"
            Sleep(100)
            Send "{Enter}"
            for each, tierImage in enabledImages { ;check for portal after moving down
                UpdateCurrentProcess("")
                if ImageSearchFunction(tierImage, 161, 169, 800, 520) {
                    challengeFound := false
                    ; Iterate through each enabled challenge image
                    for index, enabledChallengeImage in enabledChallenges {
                        if ImageSearchFunction(enabledChallengeImage, 161, 169, 800, 520) {
                            challengeFound := true
                            break  ; Exit loop if any challenge image is found
                        }
                    }
                    ; If no challenges are found, return true
                    if !challengeFound {
                        return true
                    }
                }
            }
            MovedCounter := 0
        }
        MovedCounter += 1
    }
    return false  ; Image not found, return false
}


/*
Function Name: raidStartingWave()-

Parameters: 
@none

Use: 
Searches until it finds the Wave1Path pre-setup using raidStartingWave()-

Variables:
@x1,y1,x2,y2 > parameters to sarch for

Return:
@true > a next check was found
@false > as long as the raid isn't leaf, it will return false after finding
*/
raidFirstWave() {
    if(Raid != Leaf) {
        UpdateCurrentProcess("Looking for map spawn")
        if(Raid = Slime || Raid = Tropical) { ;Offset wave because of challenge
            global x1 := 369
            global y1 := 35
            global x2 := 438
            global y2 := 91
        } else {
            global x1 := 419
            global y1 := 38
            global x2 := 470
            global y2 := 74
        }
        while !ImageSearchFunction(raidStartingWave(), x1, y1, x2, y2) {
            Sleep(500)
            if nextCheck() {
                return true
            }
        }
        return false
    } if(Raid = Leaf) {
        return false
    }
}


/*
Function Name: raidStartingWave()-

Parameters: 
@none

Use: 
Gets the Wave1 image (pre setup)

Variables:
@snowyWave1 > 
@marineWave1 >
@hellWave1 >
@slimeWave1 >
@tropicalWave1 >
< All Wave1 Paths pre setup

Return:
@true > wave path
*/
raidStartingWave() {
    if(Raid = Snowy) { ;Snowy Wave 1 Path
        return snowyWave1 
    } else if (Raid = Marine) { ;Marine Wave 1 Path
        return marineWave1
    } else if (Raid = Hell) { ;Hell Wave 1 Path
        return hellWave1
    } else if (Raid = Slime) { ;Slime Wave 1 Path
        return slimeWave1
    } else if (Raid = Tropical) { ;Tropical Wave 1 Path
        return tropicalWave1
    }
}


/*
Function Name: leafySpawnCheck()-

Parameters: 
@none

Use: 
Since leafy has 2 spawns, needs to check both and return the spawn based on what it finds. This is currently the only map where this is needed, can be used for other maps in the future

Variables:
@leafWave1 > Starting leaf wave for spawn1
@leafWave2 >  Starting leaf wave for spawn2
@leafWave1rock > Starting leaf spawn 1 wave after zooming in once
@leafWave2rock > Starting leaf spawn 2 wave after zooming in once
@leafySpawn > returns 1 if spawn1, 2 if spawn2


Return:
@true > a spawn was found
*/
leafySpawnCheck() {
    global leafySpawn := 0
    if (Raid = leaf) { ;Gets Leaf Spawn + Leaf Wave 1 Path
        UpdateCurrentProcess("Locating Map Spawn")
        ;while !(ImageSearchFunction(leafWave0Spawn1, 387, 36, 427, 75) || ImageSearchFunction(leafWave0Spawn2, 387, 36, 427, 75) || ImageSearchFunction(leafWave1Spawn1, 387, 36, 427, 75)) {
        ;    if nextCheck() {
        ;        return true
        ;    }
        ;    Sleep(200)
        ;}  
        ;UpdateCurrentProcess("Scrolling In")
        ;Send "{Wheelup}"
        Sleep(100)
        UpdateCurrentProcess("Looking For Leafy Spawn")
        while true {
            if(ImageSearchFunction(leafWave1Spawn1, 387, 36, 427, 75) || ImageSearchFunction(leafWave0Spawn1, 387, 36, 427, 75)) {
                global leafySpawn := 1 
                UpdateCurrentProcess("Leafy Spawn 1 Found")
                return 
            } else if (ImageSearchFunction(leafWave0Spawn2, 387, 36, 427, 75)) {
                UpdateCurrentProcess("Leafy Spawn 2 Found")
                global leafySpawn := 2
                return 
            }
            if nextCheck() {
                return true
            }
        }
        return
    }
    return
}


/*
Function Name: raidSetup()-

Parameters: 
none

Use: 
Depending on the raid, does the nedded setup. Example: walk forward 

Variables:
@currentPath > uses getImagePath()- to get the wave to look for 

Return:
@none
*/
raidSetup() {
    if(Raid = Snowy || Raid = Slime || Raid = Marine || Raid = Hell || Raid = Tropical) { ;Snowy + Tropical Setup // Just zooms out
        if(Raid = Snowy) {
            UpdateCurrentProcess("Snowy Spawn Found")
        } else if (Raid = Slime) {
            UpdateCurrentProcess("Slime Spawn Found")
        } else if(Raid = Hell) {
            UpdateCurrentProcess("Hell Spawn Found")
        } else if(Raid = Marine) {
            UpdateCurrentProcess("Marine Spawn Found")
        } else if(Raid = Tropical) {
            UpdateCurrentProcess("Tropical Spawn Found")
        }
        if(Raid != Slime) {
            if(Raid = Hell || Raid = Marine) {
                Loop(23) {
                    Send "{W down}"
                    Sleep(100)
                    Send "{W up}"
                }
            }
            UpdateCurrentProcess("Zooming Out")
            Sleep(200)
            i := 0
            while(i < 10) {
                i += 1
                Sleep(100)
                Send "{Wheeldown}"
            }
            Sleep(200)
        }
    }
}


/*
Function Name: setupAllUnits()-

Parameters: 
@none

Use: 
Loops 6 times (6 units) and calls setupUnit()- if the unit is enaabled

Variables:

Return:
@true > unit was setup
*/
setupAllUnits() {
    loop 6 {
        if UnitData[A_Index].Enabled.Value = 1 {
            if setupUnit(A_Index) {
                return true
            }
        }
    }
}


/*
Function Name: setupUnit()-

Parameters: 
@i > Index of unit 

Use: 
Uses getImagePath()- to find the wave to check for, then once that wave is detected, uses PlaceUnit()- to place/confirm placement of unit

Variables:
@currentPath > uses getImagePath()- to get the wave to look for 

Return:
@true > 
@false > unit was not enabled, skips
*/
global totalPlace := 0
setupUnit(i) {
    UpdateCurrentProcess("Attempting to set up Unit " i)
    if(UnitData[i].Enabled.Value = 1) {
        global x1, y1, x2, y2
        global totalPlace += 1
        currentPath := getImagePath(i)
        imageName := StrSplit(currentPath, "\").Pop()
        UpdateCurrentProcess("Unit " i " Image Path set to " imageName ". Starting search")
        if(Raid = Leaf || Raid = Slime || Raid = Tropical) {
            global x1 := 369
            global y1 := 35
            global x2 := 438
            global y2 := 91
        } else {
            global x1 := 419
            global y1 := 38
            global x2 := 470
            global y2 := 74
        }
        while !ImageSearchFunction(currentPath, x1, y1, x2, y2) {
            Sleep(200)
            if nextCheck() {
                return true
            }
        }
        UpdateCurrentProcess("Image Path of Unit " i " successfully located")
        PlaceUnit(i)
        UpdateCurrentProcess("Returned Setup Unit")
    } else {
        UpdateCurrentProcess("Unit " i " was not enabled.")
        return false
    }
}


/*
Function Name: getImagePath()-

Parameters: 
@i > Index of unit 

Use: 
Gets the wave file path using the index of the UnitData.Wave.Value

Variables:
@-WavePath > A set wave path to "filepath\wave" to concatenate the index and the file path

Return:
@imagePath > full wave path to the index wave file
*/
getImagePath(i) {
    if(Raid = Snowy) {
        wavePath := snowyWavePath
    } else if(Raid = Leaf) {
        if(leafySpawn = 1) {
            wavePath := leafWavePath1
            UpdateCurrentProcess("leafySpawn 1 used for WavePath")
        } else if(leafySpawn = 2) {
            wavePath := leafWavePath2
            UpdateCurrentProcess("leafySpawn 2 used for WavePath")
        } else {
            wavePath := leafWavePath1 ;default to path1 for error catching no path
            UpdateCurrentProcess("No path for leafy found. WavePath defaulted to leavePath1")
        }
    } else if (Raid = Marine) {
        wavePath := marineWavePath
    } else if (Raid = Hell) {
        wavePath := hellWavePath
    } else if (Raid = Slime) {
        wavePath := slimeWavePath
    } else if (Raid = Tropical) {
        wavePath := tropicalWavePath
    }
    waveValue := UnitData[i].Wave.Value
    imagePath := wavePath . WaveValue . ".png"
    return ImagePath
}


/*
Function Name: placeUnit()-

Parameters: 
@UnitNum > Index of unit 

Use: 
Gets all of the necessary unit data for placement (X/Y, Slot, Wait) and places the unit. Confirms unit placement by clicking the same spot and searching for the upgrade UI.
If using the "Upgrade to X" upgrade style, will go through the logic of upgrading directly after.

Variables:
@x > X position
@y > Y position
@slot > slot in hotbar of unit
@unit.Wait.Value > Wait time (converted to seconds) to delay unit placement

Return:
@none
*/
global CurrentlyUpgrading := 0
PlaceUnit(UnitNum) {
    ;Checks for [Enabled, Wait, X, Y, Slot, Upgrade]
    unit := UnitData[UnitNum]
    if(leafySpawn = 2) {
        x := unit.Xleaf2.Value
        y := unit.Yleaf2.Value
    } else {
        x := unit.X.Value
        y := unit.Y.Value
    }
    slot := unit.Slot.Value
    if(unit.Wait.Value != 0 && unit.Wait.Value != "") {
        Sleep(unit.Wait.Value*1000) ;convert for ms to s
    }
    UpdateCurrentProcess("Moving Mouse to X: " x " Y: " y)
    CoordMode("Mouse","Window")
    MouseMove(x, y, 5) 
    MouseRelativeMove()
    Send "{" slot " down}"
    Sleep(50)
    Send "{" slot " up}"
    Click() ;Place unit down
    Sleep(100)
    UpdateCurrentProcess("Locating Confirmation of Unit Placement. Attempting until confirmed")
    global tempY := y
    checkCount := 0
    currentOffset := 0
    while !ImageSearchFunction(upgrade, 28, 488, 63, 524) {
        Sleep(200) 
        Click() ;Keeps trying to click/place until it finds upgrade
        Sleep(200)
        if(checkCount > 2) {
            currentOffset += 5
            if(currentOffset <= 10) {
                tempY -= 8 ;This is for far range placements, may not be able to click at the same spot
            }
            checkCount := 0
        }
        MouseMove(x, tempY, 5) 
        if nextCheck() {
            return true
        }
        checkCount += 1
    }
    if(upgradeStyle = 1) {
        if(unit.MainUpgradeCheck.Value = 1) {
            global offset := tempY
        }
    }
    Click() ;Click off of upgrade menu
    UpdateCurrentProcess("Confirmed placement of Unit")  
    if(upgradeStyle = 1) { ;Main upgrade style, dont need to do anything else
        UpdateCurrentProcess("Returned Place Unit")
        return
    } else if (upgradeStyle = 2) {
        if(UnitData[UnitNum].MainUpgrade.Value > 0) {
            UpdateCurrentProcess("Unit Placed. Upgrading Until " UnitData[UnitNum].MainUpgrade.Value)
            findUpgradeLevel(UnitNum)
        } else {
            UpdateCurrentProcess("Unit Placed. No Upgrades Needed.")
        }
    }
}


/*
Function Name: findUpgradeLevel()-

Parameters: 
@i > index of unit 

Use: 
Gets the unit index, it's upgrade level, paths to the upggrade image, moves to upgrade button and upgrades until the specificed upgrade level is found
Will also check for the next units placement (if it exists) and stop upgrading and move to that unit if found

Variables:
@unit > UnitData index
@upgradeIndex > The input from user for the selected upgrade level (index+1 for level 0 and AHK being 0index array)
@upgradeImage > Uses the index of the upgrade level to get the image path
@NextWaveNeeded > A flag to check if there is a next unit in line to be checked for

Return:
@none
*/
findUpgradeLevel(i) {
    Sleep(100)
    MouseRelativeMove()
    Click() ;Open menu back up 
    Sleep(100)
    MouseRelativeMove()
    unit := UnitData[i]
    upgradeIndex := (unit.MainUpgrade.Value)+1 ;Upgrade 0 would be index1
    upgradeImage := upgrades[upgradeIndex]
    NextWaveNeeded := 0
    if(i != 6) {
        if(UnitData[i+1].Wave.Value != "") {
            if(UnitData[i+1].Wave.Value > 0) {
                nextUnitWave := getImagePath(i+1)
                NextWaveNeeded := 1
            }
        }
    }
    MouseMove(135, 505, 5)
    MouseRelativeMove()
    ;and while not next units wave // need to make sure there is another unit to be placed
    ;if unitdata[index] != length of unit 
    ;unitdata.length is always 6, could either add enabled units to a new array or check if != length 6,  and wave != ""
    while (!ImageSearchFunction(upgradeImage, 150, 383, 225, 411) && !ImageSearchFunction(maxImage, 188, 417, 247, 493)) { 
        if(NextWaveNeeded = 1) {
            if(Raid = Leaf || Raid = Tropical || Raid = Slime) {
                x1 := 387
                y1 := 36
                x2 := 427
                y2 := 75
            } else {
                x1 := 419
                y1 := 38
                x2 := 470
                y2 := 74
            }
            if(ImageSearchFunction(nextUnitWave, x1, y1, x2, y2)) {
                UpdateCurrentProcess("Next Units wave found. Returned findUpgradeLevel, moving on")
                return
            }
        }
        UpdateCurrentProcess("Checking for upgrade")
        if nextcheck() {
            return true
        } else {
            Sleep(500)
            Click()
        }
    }
    UpdateCurrentProcess("Unit " i " Successfully Upgraded. Moving on")
    MouseMove(0,30,5, "R")
    MouseRelativeMove()
    Click() ;Clicks off upgrade once upgrade level found to allow for better image searching
    ;While !detect max
}

; UPGRADE SETUP FOR IMAGES --------------------------------------------------------
global upgrades := []

SetupUpgrade() {
    i := 0
    while (i < 11) {
        upgradeFullPath := upgradePath . i . ".png" 
        upgrades.push(upgradeFullPath)
        i += 1
    }
}

; UPGRADE SETUP FOR IMAGES --------------------------------------------------------

/*
Function Name: setupMainUnit()-

Parameters: 

Use: 
Gets the X and Y of the unit that has "MainUpgradeCheck" enabled, moves to it, finds the upgrade, then upgrades that unit

Variables:
@Xpos > X position of the unit (needs to go back to it)
@Ypos > Y position of the unit (needs to go back to it)
@leafySpawn > if the 2nd map/spawn of leafy was used, needs to use the 2nd set of coords
@offset > When confiriming the placement of a unit, some are placed at a bad angle and the Y value needs to be offset upwards to open the upgrade menu faster. If one was used, it retrieves that and uses it again

Return:
@nextCheck > true (goes until one of the nextChecks are found)
*/
setupMainUnit() {
    unitIndex := findMainUpgrade()
    UpdateCurrentProcess("Setting up main upgrade unit")
    ;get X and Y of unit
    if(leafySpawn = 2) {
        global Xpos := UnitData[unitIndex].Xleaf2.Value
        global Ypos := UnitData[unitIndex].Yleaf2.Value
    } else {
        global Xpos := UnitData[unitIndex].X.Value
        global Ypos := UnitData[unitIndex].Y.Value
    }
    CoordMode("Mouse","Window")
    if(leafySpawn = 2) {
        if(offset != UnitData[unitIndex].Yleaf2.Value && offset != 0) {
            UpdateCurrentProcess("offset used")
            Ypos := offset
        }
    } else if (offset != UnitData[unitIndex].Y.Value && offset != 0) {
        UpdateCurrentProcess("offset used")
        Ypos := offset
    }
    UpdateCurrentProcess(ypos " offset: " offset)
    UpdateCurrentProcess("Moving Mouse to X: " Xpos " Y: " Ypos)
    MouseMove(Xpos, Ypos, 5)
    MouseRelativeMove()
    Sleep(100)
    Click()
    UpdateCurrentProcess("Opened Upgrade Menu")
    UpdateCurrentProcess("Attempting to find Upgrade Menu")
    while !ImageSearchFunction(upgrade, 28, 488, 63, 524) {
        Sleep(200)
        Click()
        Sleep(200)
        MouseMove(Xpos, Ypos, 5)
        if nextCheck() {  
            return true
        }
    }
    UpdateCurrentProcess("Found Upgrade Menu")
    global CurrentlyUpgrading := 1
    CoordMode("Mouse","Window")
    UpdateCurrentProcess("Moving Mouse to X: " 135 " Y: " 505)
    MouseMove(135, 505, 5)
    MouseRelativeMove()
    loop {
        if nextCheck() { ;Removed currently upgrading logic, just click if it doesn't detect
            return true
        } else {
            Sleep(2500)
            Click()
        }
    }
    return true
}


/*
Function Name: fineMainUpgrade()-

Parameters: 

Use: 
Gets the unit that has MainUpgradeCheck enabled

Variables:
@UnitData > UnitData array
@MainUpgradeCheck > Checkbox to toggle if the unit should be upgraded

Return:
@i > gets the index of the unit that has MainUpgradeCheck enabled (=1)
*/
findMainUpgrade() {
    for i, unit in UnitData {
        if unit.MainUpgradeCheck.Value = 1 {
            return i
        }
    }
}


/*
Function Name: nextCheck()-

Parameters: 
@imagePath > file path to the image being used

Use: 
Used to check throughout if one of the images (retry,defeat,leave,viewportal,reconnect,step1perm) is found

Variables:
@retry
@deafeat
@leave
@viewportal
@reconnect
@step1perm > Step 1 of moveToRaid image

@currentlyUpgrading > This is used for a previous loop to 'auto click' the upgrade menu. needs to be set to false
@lost > This is used as a flag at the start of the loop to ensure that nothing else happens until the lobby menu is found
@leafySpawn > Used as a flag to determine leafy spawn, needs to be reset

Return:
@found one of the checks > true
@nothing found > false
*/
nextCheck() {
    if(CurrentlyUpgrading = 1) { ;If setup (on upgrade) it will compare the current tick count to start and sleep for a longer time for less checks if the retry button shouldnt be ther eyet
        elapsedRaidTime := A_Min - startRaidTime
        if(elapsedRaidTime < 3) {
            ;8 divided by 4
            loop 4 {
                Sleep(2000)
                Click()
            }
        } else if(elapsedRaidTime > 12) { ;Raid has been going on for more than 12 minutes, should assume that it is the no unit bug, re-open and restart
            return true
        }
    }
    if(Raid != Slime && Raid != Tropical) {
        if ImageSearchFunction(Retry, 314, 400, 486, 434) {
            RetryX := FoundX
            RetryY := FoundY
            if(Raid = Leaf) {               
                if ImageSearchFunction(defeatImage, 373, 246, 449, 267) {
                    if ImageSearchFunction(leavebutton, 341, 400, 486, 434) {
                        UpdateCurrentProcess("Loss detected. Leaving")
                        ;- - - - -- - 
                        if(psLink = "" || PSReconnect = 1) {
                            Sleep(20000)
                            moveToTarget()
                        }
                        ; - - -- - 
                        global FoundX += 5
                        global FoundY += 5
                        resetFlags(1)
                        return true ;Re-opens private server
                    }
                } else {
                    moveToManualTarget(RetryX, RetryY)
                    resetFlags(0)
                    return true
                }
            } else {
                ;- - - - -- - - -- 
                moveToManualTarget(RetryX, RetryY)
                ; -= - - -- - -
                UpdateCurrentProcess("Win detected. Retrying")
                resetFlags(2)
                return true
            }
        }
    } else if (Raid = Slime || Raid = Tropical) {
        if ImageSearchFunction(viewPortal, 339, 391, 436, 435) {
            if ImageSearchFunction(leaveButton, 416, 383, 475, 443) {
                LeaveX := FoundX
                LeaveY := FoundY
                if ImageSearchFunction(defeatImage, 373, 246, 449, 267) {
                    UpdateCurrentProcess("Loss detected. Most likely clicked a bad portal or got 2nd spawn. Setting up next portal")
                } else {
                    UpdateCurrentProcess("Win detected. Leaving to Setup Next Portal")
                }
                ;- - - - -- - - --
                if(psLink = "" || PSReconnect = 1) {
                    moveToManualTarget(LeaveX, LeaveY)
                }
                ; -= - - -- - -
                Sleep(5000)
                resetFlags(1)
                return true
            }
        }   
    }


    if ImageSearchFunctionOld(Reconnect) {
        global CurrentlyUpgrading := 0 
        global leafySpawn := 0
        global lost := 1
        if(psLink = "") {
            if ImageSearchFunctionOld(ReconnectOld) {
                moveToTarget()
            }
        }
        reconnecting := 1
        UpdateCurrentProcess("Disconnect screen found. Reconnecting")
        return true
    }

    if(ImageSearchFunction(step1perm, 546, 181, 583, 225 )) {
        UpdateCurrentProcess("Lobby button found. Restarting Move to Raid")
        resetFlags(2)
    }
    return false
}

resetFlags(i) {
    global CurrentlyUpgrading := 0
    global leafySpawn := 0
    if(i = 1) {
        global lost := 1
    }
}



; Mouse move functions ------------------------------------------------------
;MouseRelativeMove()-
MouseRelativeMove() {
    MouseMove(1,1,5,"R")
    MouseMove(-1,-1,5,"R")
}

;moveToTarget()-
;Used after finding an image
moveToTarget() {
    MouseMove(FoundX, FoundY, 5)
    MouseRelativeMove()
    Click()
}

;moveToManualTarget()-
;Used to move to specific coords without finding an image
moveToManualTarget(x, y) {
    MouseMove(x, y, 5)
    MouseRelativeMove()
    Click()
}
; Mouse move functions ------------------------------------------------------