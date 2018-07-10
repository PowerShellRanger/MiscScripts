Import-Module -Name PoshBots -ErrorAction Stop

$BaseUri = "http://powershell-rangers.azurewebsites.net/"
$GameName = "Travis"
$PlayerName = "Blue"
$Player1Memory = ""
$Player2Name = "Red"
$Player2Memory = ""


function Move-TravBot
{    
    <#
    .Synopsis
       Move PoshBot bots
    .DESCRIPTION
        This is your playground. You can only use the following global variables: 
        $PlayerName
        $Player1Memory
        The following commands are available
        Get-Surroundings $PlayerName
        Get-Score
        Move-Up $PlayerName
        Move-Down $PlayerName
        Move-Left $PlayerName
        Move-Right $PlayerName
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding()]
    Param
    (
        # PlayerName
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string]$PlayerName,

        # GameName
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string]$GameName,

        # Opponent
        [Parameter()]        
        [string]$Opponent,

        # Memory
        [Parameter()]        
        [string]$Memory

    )
    
    $surroundings = Get-Surroundings -PlayerName $PlayerName -GameName $GameName
    $arrayOfSurroundings = New-Object System.Collections.ArrayList
    foreach ($y in 0..4) {        
        foreach ($x in 0..4) {
            switch ($x) {
                { $y -eq 0 -and $_ -eq 0 } { $movesToSquare = 4; $direction = 'Up' , 'Up' , 'Left' , 'Left'; $quadrant = 'NW' }
                { $y -eq 0 -and $_ -eq 1 } { $movesToSquare = 3; $direction = 'Up' , 'Up' , 'Left'; $quadrant = 'NW' }
                { $y -eq 0 -and $_ -eq 2 } { $movesToSquare = 2; $direction = 'Up' , 'Up'; $quadrant = 'N' }
                { $y -eq 0 -and $_ -eq 3 } { $movesToSquare = 3; $direction = 'Up' , 'Up' , 'Right'; $quadrant = 'NE' }
                { $y -eq 0 -and $_ -eq 4 } { $movesToSquare = 4; $direction = 'Up' , 'Up' , 'Right' , 'Right'; $quadrant = 'NE' }
                { $y -eq 1 -and $_ -eq 0 } { $movesToSquare = 3; $direction = 'Up' , 'Left' , 'Left'; $quadrant = 'NW' }
                { $y -eq 1 -and $_ -eq 1 } { $movesToSquare = 2; $direction = 'Up' , 'Left'; $quadrant = 'NW' }
                { $y -eq 1 -and $_ -eq 2 } { $movesToSquare = 1; $direction = 'Up'; $quadrant = 'N' }
                { $y -eq 1 -and $_ -eq 3 } { $movesToSquare = 2; $direction = 'Up' , 'Right'; $quadrant = 'NE' }
                { $y -eq 1 -and $_ -eq 4 } { $movesToSquare = 3; $direction = 'Up' , 'Right' , 'Right'; $quadrant = 'NE' }
                { $y -eq 2 -and $_ -eq 0 } { $movesToSquare = 2; $direction = 'Left' , 'Left'; $quadrant = 'W' }
                { $y -eq 2 -and $_ -eq 1 } { $movesToSquare = 1; $direction = 'Left'; $quadrant = 'W' }
                { $y -eq 2 -and $_ -eq 2 } { $movesToSquare = 0; $direction = 0; $quadrant = 'center' }
                { $y -eq 2 -and $_ -eq 3 } { $movesToSquare = 1; $direction = 'Right'; $quadrant = 'E' }
                { $y -eq 2 -and $_ -eq 4 } { $movesToSquare = 2; $direction = 'Right' , 'Right'; $quadrant = 'E' }
                { $y -eq 3 -and $_ -eq 0 } { $movesToSquare = 3; $direction = 'Down' , 'Left' , 'Left'; $quadrant = 'SW' }
                { $y -eq 3 -and $_ -eq 1 } { $movesToSquare = 2; $direction = 'Down' , 'Left'; $quadrant = 'SW' }
                { $y -eq 3 -and $_ -eq 2 } { $movesToSquare = 1; $direction = 'Down'; $quadrant = 'S' }
                { $y -eq 3 -and $_ -eq 3 } { $movesToSquare = 2; $direction =  'Down' , 'Right'; $quadrant = 'SE' }
                { $y -eq 3 -and $_ -eq 4 } { $movesToSquare = 3; $direction =  'Down' , 'Right' , 'Right'; $quadrant = 'SE' }
                { $y -eq 4 -and $_ -eq 0 } { $movesToSquare = 4; $direction =  'Down' , 'Down' , 'Left' , 'Left'; $quadrant = 'SW' }
                { $y -eq 4 -and $_ -eq 1 } { $movesToSquare = 3; $direction =  'Down' , 'Down' , 'Left'; $quadrant = 'SW' }
                { $y -eq 4 -and $_ -eq 2 } { $movesToSquare = 2; $direction =  'Down' , 'Down'; $quadrant = 'S' }
                { $y -eq 4 -and $_ -eq 3 } { $movesToSquare = 3; $direction =  'Down' , 'Down' , 'Right'; $quadrant = 'SE' }
                { $y -eq 4 -and $_ -eq 4 } { $movesToSquare = 4; $direction =  'Down' , 'Down' , 'Right' , 'Right'; $quadrant = 'SE' }
            }

            switch ($surroundings[$y][$x]) {
                { -not $_.Owner } { $points = $surroundings[$y][$x].Points }
                { $_.Owner -like $PlayerName } { $points = $surroundings[$y][$x].Points / 2 }                    
                { $_.Owner -notlike $PlayerName -and $_.Owner } { $points = $surroundings[$y][$x].Points * 2 }                    
                    default { $points = $surroundings[$y][$x].Points }
            }

            switch ($surroundings[$y][$x]) {                
                { $x -eq 1 -and (-not $surroundings[$y][$x - 1].Points) -and $_.Points } { $nearWhatWall = 'LeftWall' }
                { $y -eq 1 -and (-not $surroundings[$y - 1][$x].Points) -and $_.Points } { $nearWhatWall = 'TopWall' }
                { $x -eq 3 -and (-not $surroundings[$y][$x + 1].Points) -and $_.Points } { $nearWhatWall = 'RightWall' }
                { $y -eq 3 -and (-not $surroundings[$y + 1][$x].Points) -and $_.Points } { $nearWhatWall = 'BottomWall' }
                    default { $nearWhatWall = "" }
            }

            $result = [PSCustomObject] @{
                Points = $points
                Owner = $surroundings[$y][$x].Owner
                Occupied = $surroundings[$y][$x].Occupied
                'y-axis' = $y
                'x-axis' = $x
                Moves = $movesToSquare
                Direction = $direction
                Position = $nearWhatWall
                Quadrant = $quadrant
            }
            [void]$arrayOfSurroundings.Add($result) 
        }
    }

    #$currentPosition = $arrayOfSurroundings.Where({$_.Occupied -eq $PlayerName})  
    #$arrayOfSurroundings | ft -AutoSize

    $randomMove = "" 
    # check looping in circle with opponent 
    if ($arrayOfSurroundings.Where({$_.Occupied -and $_.Occupied -notlike $PlayerName -and (($_.'y-axis' -eq 3 -and $_.'x-axis' -eq 1) -or ($_.'y-axis' -eq  1 -and $_.'x-axis' -eq 3) -or ($_.'y-axis' -eq  1 -and $_.'x-axis' -eq 1) -or ($_.'y-axis' -eq 3 -and $_.'x-axis' -eq 1))})) {
        $randomMove = Get-Random -Minimum 1 -Maximum 5
    }    

    if (-not $randomMove) {
        $maxNumberValueOfSquare = ($arrayOfSurroundings.Where({(-not $_.Position -or $_.Points -ge 4) -and -not $_.Occupied -and $_.Moves -eq 1 -and ($_.Owner -or $_.Points -ge 4)  -and $_.Owner -notlike $PlayerName}).Points | Measure-Object -Maximum).Maximum
    
        $nextMove = $arrayOfSurroundings.Where({$_.Points -and $_.Points -eq $maxNumberValueOfSquare -and -not $_.Occupied -and $_.Moves -eq 1}) | select -First 1                
    } 
    
    if (-not $nextMove) {
        $quadrants = New-Object System.Collections.ArrayList
        foreach ($quadrant in ($arrayOfSurroundings.Quadrant | select -Unique)) {
            switch ($quadrant) {
                { $_ -like 'NW' -or $_ -like 'N' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                { $_ -like 'NE' -or $_ -like 'N' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                { $_ -like 'SW' -or $_ -like 'S' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                { $_ -like 'SE' -or $_ -like 'S' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
            }
            $results = [PSCustomObject] @{
                Name = 'Quadrant'
                Location = $quadrant
                Points = ($quadrantPoints | Measure-Object -Sum).Sum
            }
            $quadrants.Add($results) | Out-Null
        }

        $quadrantWithMostPoints = $quadrants.Where({$_.Location.Length -eq 2}) | sort Points | select -Last 1

        switch ($quadrantWithMostPoints) {
            { $_.Location -like 'NW' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'N' -or $_.Quadrant -like 'W' -and $_.Moves -eq 1}) | sort Points | select -Last 1 }
            { $_.Location -like 'NE' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'N' -or $_.Quadrant -like 'E' -and $_.Moves -eq 1}) | sort Points | select -Last 1 }
            { $_.Location -like 'SE' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'S' -or $_.Quadrant -like 'E' -and $_.Moves -eq 1}) | sort Points | select -Last 1 }
            { $_.Location -like 'SW' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'S' -or $_.Quadrant -like 'W' -and $_.Moves -eq 1}) | sort Points | select -Last 1 }
        }    

    }
        
    $splatPoshBotParams = @{
        PlayerName = $PlayerName
        GameName = $GameName
    }

    if ($randomMove) {
        #added default and switch statement to handle getting stuck in a corner. need to look into
        switch ($randomMove) {
            1 { Move-PoshBot @splatPoshBotParams -Direction Up -Verbose }
            2 { Move-PoshBot @splatPoshBotParams -Direction Down -Verbose }
            3 { Move-PoshBot @splatPoshBotParams -Direction Left -Verbose }
            4 { Move-PoshBot @splatPoshBotParams -Direction Right -Verbose }
        }
    }
    else {
        Move-PoshBot @splatPoshBotParams -Direction $nextMove.Direction
    }
    
    <#
    if ($randomMove) {
        #added default and switch statement to handle getting stuck in a corner. need to look into
        switch ($randomMove) {
            1 { Move-PoshBot @splatPoshBotParams -Direction Up -Verbose }
            2 { Move-PoshBot @splatPoshBotParams -Direction Down -Verbose }
            3 { Move-PoshBot @splatPoshBotParams -Direction Left -Verbose }
            4 { Move-PoshBot @splatPoshBotParams -Direction Right -Verbose }
        }
    }
    else {
        $nextPossibleMoves = @()
        foreach ($targetSqaure in $targetSquaresToGoAfter) {            
            $nextPossibleMoves += $arrayOfSurroundings.Where({$_.Moves -eq ($targetSqaure.Moves + 1) -and (-not $_.Position -or $_.Points -ge 4) -and -not $_.Occupied -and $_.Direction -contains $targetSqaure.Direction -and $_.Points})
        }        
        
        $bestMoveNextRound = $nextPossibleMoves | sort Points | select -last 1
        $bestMoveCurrentRound = $targetSquaresToGoAfter.Where({$bestMoveNextRound.Direction -contains $_.Direction}) |  select -First 1

        if (!$bestMoveCurrentRound) {
            $randomMove = Get-Random -Minimum 1 -Maximum 5
            switch ($randomMove) {                
                1 { Move-PoshBot @splatPoshBotParams -Direction Up -Verbose }
                2 { Move-PoshBot @splatPoshBotParams -Direction Down -Verbose }
                3 { Move-PoshBot @splatPoshBotParams -Direction Left -Verbose }
                4 { Move-PoshBot @splatPoshBotParams -Direction Right -Verbose }
            }
        }
        else {
            Move-PoshBot @splatPoshBotParams -Direction $bestMoveCurrentRound.Direction   
        }        
    }    
    #>
    Get-Score -GameName $GameName
}

function Move-Player2
{
  
    $surroundings = Get-Surroundings -PlayerName $Player2Name -GameName $GameName
    $randomMove = Get-Random -Minimum 1 -Maximum 5
    switch($randomMove)
    {
        1 { Move-PoshBot -PlayerName $Player2Name -GameName $GameName -Direction Up -Verbose }
        2 { Move-PoshBot -PlayerName $Player2Name -GameName $GameName -Direction Down -Verbose }
        3 { Move-PoshBot -PlayerName $Player2Name -GameName $GameName -Direction Left -Verbose }
        4 { Move-PoshBot -PlayerName $Player2Name -GameName $GameName -Direction Right -Verbose }
    }
}

$currentMap = Invoke-RestMethod -Method Get -Uri "$BaseUri/api/map/$GameName"
while(-not $currentMap.Winner)
{
    Move-TravBot -PlayerName $Player1Name -GameName $GameName -Opponent '' -Memory '' 
    Move-Player2

    $currentMap = Invoke-RestMethod -Method Get -Uri "$BaseUri/api/map/$GameName"

    #Start-Sleep -Milliseconds 500    
}