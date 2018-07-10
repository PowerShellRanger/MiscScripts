$PlayerName = 'TravBot'
    #$surroundings = Get-Surroundings -PlayerName $PlayerName -GameName $GameName
    $surroundings = Get-Surroundings 
    $arrayOfSurroundings = New-Object System.Collections.ArrayList
    foreach ($x in 0..4) {        
        foreach ($y in 0..4) {
            switch ($y) {
                { $x -eq 0 -and $_ -eq 0 } { $movesToSquare = 4; $direction = 'Up' , 'Up' , 'Left' , 'Left'; $quadrant = 'NW' }
                { $x -eq 0 -and $_ -eq 1 } { $movesToSquare = 3; $direction = 'Up' , 'Left' , 'Left'; $quadrant = 'NW' }
                { $x -eq 0 -and $_ -eq 2 } { $movesToSquare = 2; $direction = 'Left' , 'Left'; $quadrant = 'W' }
                { $x -eq 0 -and $_ -eq 3 } { $movesToSquare = 3; $direction = 'Down' , 'Left' , 'Left'; $quadrant = 'SW' }
                { $x -eq 0 -and $_ -eq 4 } { $movesToSquare = 4; $direction = 'Down' , 'Down' , 'Left' , 'Left'; $quadrant = 'SW' }
                { $x -eq 1 -and $_ -eq 0 } { $movesToSquare = 3; $direction = 'Up' , 'Up' , 'Left'; $quadrant = 'NW' }
                { $x -eq 1 -and $_ -eq 1 } { $movesToSquare = 2; $direction = 'Up' , 'Left'; $quadrant = 'NW' }
                { $x -eq 1 -and $_ -eq 2 } { $movesToSquare = 1; $direction = 'Left'; $quadrant = 'W' }
                { $x -eq 1 -and $_ -eq 3 } { $movesToSquare = 2; $direction = 'Down' , 'Left'; $quadrant = 'SW' }
                { $x -eq 1 -and $_ -eq 4 } { $movesToSquare = 3; $direction = 'Down' , 'Down' , 'Left'; $quadrant = 'SW' }
                { $x -eq 2 -and $_ -eq 0 } { $movesToSquare = 2; $direction = 'Up' , 'Up'; $quadrant = 'N' }
                { $x -eq 2 -and $_ -eq 1 } { $movesToSquare = 1; $direction = 'Up'; $quadrant = 'N' }
                { $x -eq 2 -and $_ -eq 2 } { $movesToSquare = 0; $direction = 0; $quadrant = 'center' }
                { $x -eq 2 -and $_ -eq 3 } { $movesToSquare = 1; $direction = 'Down'; $quadrant = 'S' }
                { $x -eq 2 -and $_ -eq 4 } { $movesToSquare = 2; $direction = 'Down' , 'Down'; $quadrant = 'S' }
                { $x -eq 3 -and $_ -eq 0 } { $movesToSquare = 3; $direction = 'Up' , 'Up' , 'Right'; $quadrant = 'NE' }
                { $x -eq 3 -and $_ -eq 1 } { $movesToSquare = 2; $direction = 'Up' , 'Right'; $quadrant = 'NE' }
                { $x -eq 3 -and $_ -eq 2 } { $movesToSquare = 1; $direction = 'Right'; $quadrant = 'E' }
                { $x -eq 3 -and $_ -eq 3 } { $movesToSquare = 2; $direction =  'Down' , 'Right'; $quadrant = 'SE' }
                { $x -eq 3 -and $_ -eq 4 } { $movesToSquare = 3; $direction =  'Down' , 'Down' , 'Right'; $quadrant = 'SE' }
                { $x -eq 4 -and $_ -eq 0 } { $movesToSquare = 4; $direction =  'Up' , 'Up' , 'Right' , 'Right'; $quadrant = 'NE' }
                { $x -eq 4 -and $_ -eq 1 } { $movesToSquare = 3; $direction =  'Up' , 'Right' , 'Right'; $quadrant = 'NE' }
                { $x -eq 4 -and $_ -eq 2 } { $movesToSquare = 2; $direction =  'Right' , 'Right'; $quadrant = 'E' }
                { $x -eq 4 -and $_ -eq 3 } { $movesToSquare = 3; $direction =  'Down' , 'Right' , 'Right'; $quadrant = 'SE' }
                { $x -eq 4 -and $_ -eq 4 } { $movesToSquare = 4; $direction =  'Down' , 'Down' , 'Right' , 'Right'; $quadrant = 'SE' }
            }
            
            switch ($surroundings[$x][$y]) {
                { -not $_.Owner } { $points = $surroundings[$x][$y].Points }
                { $_.Owner -like $PlayerName } { $points = $surroundings[$x][$y].Points / 2 }                    
                { $_.Owner -notlike $PlayerName -and $_.Owner } { $points = $surroundings[$x][$y].Points * 2 }                    
                    default { $points = $surroundings[$x][$y].Points }
            }

            switch ($surroundings[$x][$y]) {                
                { $x -eq 1 -and (-not $surroundings[$x - 1][$y].Points) -and $_.Points } { $nearWhatWall = 'LeftWall' }
                { $y -eq 1 -and (-not $surroundings[$x][$y - 1].Points) -and $_.Points } { $nearWhatWall = 'TopWall' }
                { $x -eq 3 -and (-not $surroundings[$x + 1][$y].Points) -and $_.Points } { $nearWhatWall = 'RightWall' }
                { $y -eq 3 -and (-not $surroundings[$x][$y + 1].Points) -and $_.Points } { $nearWhatWall = 'BottomWall' }
                    default { $nearWhatWall = "" }
            }

            $result = [PSCustomObject] @{
                Points = $points
                Owner = $surroundings[$x][$y].Owner
                Occupied = $surroundings[$x][$y].Occupied
                'x-axis' = $x
                'y-axis' = $y                
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

        $opponentSquares = $arrayOfSurroundings.Where({ $_.Owner -and $_.Owner -notlike $PlayerName -and -not $_.Occupied })
        if ($opponentSquares) {
            $opponentSquaresOneMove = $opponentSquaresOneMove.Where({ $_.Moves -eq 1 })
            
            if ($opponentSquaresOneMove) {
                $nextMove = $opponentSquaresOneMove | sort Points | select -Last 1
            }
            else {
                $quadrants = New-Object System.Collections.ArrayList
                foreach ($quadrant in ($arrayOfSurroundings.Where({$_.Quadrant -notlike 'center'}).Quadrant | select -Unique)) {
                    switch ($quadrant) {
                        { $_ -like 'NW' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 2)}).Points }
                        { $_ -like 'NE' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 2)}).Points }
                        { $_ -like 'SW' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 2)}).Points }
                        { $_ -like 'SE' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 2)}).Points }
                        { $_ -like 'N' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 2)}).Points }
                        { $_ -like 'E' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 2)}).Points }
                        { $_ -like 'S' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 2)}).Points }
                        { $_ -like 'W' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 2)}).Points }
                    }
                    $results = [PSCustomObject] @{
                        Name = 'Quadrant'
                        Location = $quadrant
                        Points = ($quadrantPoints | Measure-Object -Sum).Sum
                    }
                    [void]$quadrants.Add($results)
                }

                # $quadrantWithMostPoints = $quadrants | sort Points | select -Last 1
            
                foreach ($quadrantWithMostPoints in ($quadrants | sort -Descending Points)) {            
                    if ($nextMove) {
                        continue
                    }
                    switch ($quadrantWithMostPoints.Location) {
                        { $_ -like 'NW' } { $nextMove = $opponentSquares.Where({$_.Quadrant -like 'N' -or $_.Quadrant -like 'W' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                        { $_ -like 'NE' } { $nextMove = $opponentSquares.Where({$_.Quadrant -like 'N' -or $_.Quadrant -like 'E' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                        { $_ -like 'SE' } { $nextMove = $opponentSquares.Where({$_.Quadrant -like 'S' -or $_.Quadrant -like 'E' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                        { $_ -like 'SW' } { $nextMove = $opponentSquares.Where({$_.Quadrant -like 'S' -or $_.Quadrant -like 'W' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                        { $_ -like 'N' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'N' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                        { $_ -like 'E' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'E' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                        { $_ -like 'S' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'S' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                        { $_ -like 'W' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'W' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                    }
                }  
            }
            
        }
        else {
            $maxNumberValueOfSquare = ($arrayOfSurroundings.Where({(-not $_.Position -or $_.Points -ge 4 -or ($_.Owner -notlike $PlayerName -and $_.Points -ge 4)) -and -not $_.Occupied -and $_.Moves -eq 1 -and $_.Points -ge 4 -and $_.Owner -notlike $PlayerName}).Points | Measure-Object -Maximum).Maximum
    
            $nextMove = $arrayOfSurroundings.Where({$_.Points -and $_.Points -eq $maxNumberValueOfSquare -and $_.Moves -eq 1}) | select -First 1
        }        
    } 
    
    if (-not $nextMove) {
        $quadrants = New-Object System.Collections.ArrayList
        foreach ($quadrant in ($arrayOfSurroundings.Where({$_.Quadrant -notlike 'center'}).Quadrant | select -Unique)) {
            switch ($quadrant) {
                { $_ -like 'NW' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                { $_ -like 'NE' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                { $_ -like 'SW' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                { $_ -like 'SE' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                { $_ -like 'N' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                { $_ -like 'E' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                { $_ -like 'S' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
                { $_ -like 'W' } { $quadrantPoints = $arrayOfSurroundings.Where({$_.Quadrant -like $quadrant -and (-not $_.Position -or $_.Points -ge 3)}).Points }
            }
            $results = [PSCustomObject] @{
                Name = 'Quadrant'
                Location = $quadrant
                Points = ($quadrantPoints | Measure-Object -Sum).Sum
            }
            $quadrants.Add($results) | Out-Null
        }

       # $quadrantWithMostPoints = $quadrants | sort Points | select -Last 1
       
        foreach ($quadrantWithMostPoints in ($quadrants | sort -Descending Points)) {            
            if ($nextMove) {
                continue
            }
            switch ($quadrantWithMostPoints.Location) {
                { $_ -like 'NW' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'N' -or $_.Quadrant -like 'W' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                { $_ -like 'NE' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'N' -or $_.Quadrant -like 'E' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                { $_ -like 'SE' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'S' -or $_.Quadrant -like 'E' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                { $_ -like 'SW' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'S' -or $_.Quadrant -like 'W' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                { $_ -like 'N' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'N' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                { $_ -like 'E' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'E' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                { $_ -like 'S' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'S' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
                { $_ -like 'W' } { $nextMove = $arrayOfSurroundings.Where({$_.Quadrant -like 'W' -and $_.Moves -eq 1 -and $_.Owner -notlike $PlayerName -and $_.Points}) | sort Points | select -Last 1 }
            }
        }                    
    }
        
    $splatPoshBotParams = @{
        PlayerName = $PlayerName
        GameName = $GameName
    }

    if ($randomMove -or -not $nextMove) {
        $randomMove = Get-Random -Minimum 1 -Maximum 5
        #added default and switch statement to handle getting stuck in a corner. need to look into
        switch ($randomMove) {
            1 { Move-Up $PlayerName }
            2 { Move-Down $PlayerName }
            3 { Move-Left $PlayerName }
            4 { Move-Right $PlayerName }
        }
    }
    else {
        #Move-PoshBot @splatPoshBotParams -Direction $nextMove.Direction
        switch ($nextMove.Direction) {
            'Up' { Move-Up $PlayerName }
            'Down' { Move-Down $PlayerName }
            'Left' { Move-Left $PlayerName }
            'Right' { Move-Right $PlayerName }
        }
    }