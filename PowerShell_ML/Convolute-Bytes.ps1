function convolute-bytes($bytes){
    $container= @()
    $convolution= @(2,4,6,8)
    
    $iter= 4
    
    $x= 0
    
    while ($iter -le $bytes.count){
        $temp_container= @()
    
        if ($x -eq 0){
            $end= $iter - 1
            $chunk = $bytes[0..$end]
            $iter= $iter + 4
            $x++
        }
        
        if ($x -gt 0){
            $start= $iter - 4
            $end= $iter - 1
            $chunk= $bytes[$start..$end]
            $iter= $iter + 4
        }
    
        $y= 0
      
        while ($y -lt $convolution.count){
            write-output "$([int]$convolution[$y]) x $([int]$chunk[$y])"
            $temp_container+= [int]$convolution[$y] * [int]$chunk[$y]
            $y++
        }
        $container+= $($temp_container | measure-object -sum).sum
    }
    return $container
}

convolute-bytes $bytes
