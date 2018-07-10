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
        [object[]]$Memory

    )

     $splatPoshBotParams = @{
        PlayerName = $PlayerName
        GameName = $GameName
    }

    #if ($PSBoundParameters.ContainsKey('Memory')) {        
        if ($Memory.Direction) {                    
            if ($($Memory[0].Direction).Count -eq 1) {
                Move-PoshBot @splatPoshBotParams -Direction $($Memory[0].Direction)
                $Memory.Where({$_ -ne ($Memory | select -First 1)})
            }  
            else {
                Move-PoshBot @splatPoshBotParams -Direction $($Memory[0].Direction)[-1]              
                $Memory.Where({$_ -ne ($Memory | select -First 1)})
            }
        }           
    #}
    else {    
    
        $surroundings = Get-Surroundings -PlayerName $PlayerName -GameName $GameName
        $arrayOfSurroundings = New-Object System.Collections.ArrayList
        foreach ($y in 0..4) {        
            foreach ($x in 0..4) {
                switch ($x) {
                    { $y -eq 0 -and $_ -eq 0 } { $movesToSquare = 6; $direction = 'Up' , 'Up' , 'Left' , 'Down' , 'Left' , 'Up'; $quadrant = 'NW' }
                    { $y -eq 0 -and $_ -eq 1 } { $movesToSquare = 3; $direction = 'Up' , 'Up' , 'Left'; $quadrant = 'NW' }
                    { $y -eq 0 -and $_ -eq 2 } { $movesToSquare = 2; $direction = 'Up' , 'Up'; $quadrant = 'NW' }
                    { $y -eq 0 -and $_ -eq 3 } { $movesToSquare = 5; $direction = 'Right' , 'Right' , 'Up' , 'Left' , 'Up'; $quadrant = 'NE' }
                    { $y -eq 0 -and $_ -eq 4 } { $movesToSquare = 6; $direction = 'Right' , 'Right' , 'Up' , 'Left' , 'Up' , 'Right'; $quadrant = 'NE' }
                    { $y -eq 1 -and $_ -eq 0 } { $movesToSquare = 5; $direction = 'Up' , 'Up' , 'Left' , 'Down' , 'Left'; $quadrant = 'NW' }
                    { $y -eq 1 -and $_ -eq 1 } { $movesToSquare = 4; $direction = 'Up' , 'Up' , 'Left' , 'Down'; $quadrant = 'NW' }
                    { $y -eq 1 -and $_ -eq 2 } { $movesToSquare = 1; $direction = 'Up'; $quadrant = 'NW' }
                    { $y -eq 1 -and $_ -eq 3 } { $movesToSquare = 4; $direction = 'Right' , 'Right' , 'Up' , 'Left'; $quadrant = 'NE' }
                    { $y -eq 1 -and $_ -eq 4 } { $movesToSquare = 3; $direction = 'Right' , 'Right' , 'Up'; $quadrant = 'NE' }
                    { $y -eq 2 -and $_ -eq 0 } { $movesToSquare = 2; $direction = 'Left' , 'Left'; $quadrant = 'SW' }
                    { $y -eq 2 -and $_ -eq 1 } { $movesToSquare = 1; $direction = 'Left'; $quadrant = 'SW' }
                    { $y -eq 2 -and $_ -eq 2 } { $movesToSquare = 0; $direction = 0; $quadrant = 'center' }
                    { $y -eq 2 -and $_ -eq 3 } { $movesToSquare = 1; $direction = 'Right'; $quadrant = 'NE' }
                    { $y -eq 2 -and $_ -eq 4 } { $movesToSquare = 2; $direction = 'Right' , 'Right'; $quadrant = 'NE' }
                    { $y -eq 3 -and $_ -eq 0 } { $movesToSquare = 3; $direction = 'Left' , 'Left' , 'Down'; $quadrant = 'SW' }
                    { $y -eq 3 -and $_ -eq 1 } { $movesToSquare = 4; $direction = 'Left' , 'Left' , 'Down' , 'Right'; $quadrant = 'SW' }
                    { $y -eq 3 -and $_ -eq 2 } { $movesToSquare = 1; $direction = 'Down'; $quadrant = 'SE' }
                    { $y -eq 3 -and $_ -eq 3 } { $movesToSquare = 4; $direction = 'Down' , 'Down' , 'Right' , 'Up'; $quadrant = 'SE' }
                    { $y -eq 3 -and $_ -eq 4 } { $movesToSquare = 5; $direction = 'Down' , 'Down' , 'Right' , 'Up' , 'Right'; $quadrant = 'SE' }
                    { $y -eq 4 -and $_ -eq 0 } { $movesToSquare = 6; $direction = 'Left' , 'Left' , 'Down' , 'Right' , 'Down' , 'Left'; $quadrant = 'SW' }
                    { $y -eq 4 -and $_ -eq 1 } { $movesToSquare = 5; $direction = 'Left' , 'Left' , 'Down' , 'Right' , 'Down'; $quadrant = 'SW' }
                    { $y -eq 4 -and $_ -eq 2 } { $movesToSquare = 2; $direction = 'Down' , 'Down'; $quadrant = 'SE' }
                    { $y -eq 4 -and $_ -eq 3 } { $movesToSquare = 3; $direction = 'Down' , 'Down' , 'Right'; $quadrant = 'SE' }
                    { $y -eq 4 -and $_ -eq 4 } { $movesToSquare = 6; $direction = 'Down' , 'Down' , 'Right' , 'Up' , 'Right' , 'Down'; $quadrant = 'SE' }                    
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
            foreach ($quadrant in ($arrayOfSurroundings.Where({$_.Quadrant -notlike 'center'}).Quadrant | select -Unique)) {
                switch ($quadrant) {
                    { $_ -like 'NW'  } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                    { $_ -like 'NE'  } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                    { $_ -like 'SW'  } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                    { $_ -like 'SE'  } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                }
                $results = [PSCustomObject] @{
                    Name = 'Quadrant'
                    Location = $quadrant
                    Points = ($quadrantPoints | Measure-Object -Sum).Sum
                }
                $quadrants.Add($results) | Out-Null
            }

            $quadrantWithMostPoints = $quadrants | sort Points | select -Last 1

            switch ($quadrantWithMostPoints) {
                { $_.Location -like 'NW' } { $nextMoves = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrantWithMostPoints.Location }) | sort Moves}
                { $_.Location -like 'NE' } { $nextMoves = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrantWithMostPoints.Location }) | sort Moves}
                { $_.Location -like 'SE' } { $nextMoves = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrantWithMostPoints.Location }) | sort Moves}
                { $_.Location -like 'SW' } { $nextMoves = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrantWithMostPoints.Location }) | sort Moves}
            }
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
            if ($nextMove) {
                Move-PoshBot @splatPoshBotParams -Direction $nextMove.Direction
                [PSCustomObject] @{}
            }
            else {
                if (($nextMoves | select -First 1).Direction.Count -eq 1) {
                    Move-PoshBot @splatPoshBotParams -Direction ($nextMoves | select -First 1).Direction
                    $nextMoves.Where({$_ -ne ($nextMoves | select -First 1)})
                }  
                else {
                    Move-PoshBot @splatPoshBotParams -Direction ($nextMoves | select -First 1).Direction[-1]                
                    $nextMoves.Where({$_ -ne ($nextMoves | select -First 1)})
                }          
            }        
        }
    }
    
    #Get-Score -GameName $GameName
}