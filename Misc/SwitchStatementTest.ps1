
function RunMe 
{
    param 
    (
        [string]$param1 ,[string]$param2
    )
    $returnThis="$param1 ======= $param2"
    #Pause
    return $returnThis
}


$listOfNums=1,2,3,4,5,6,7
foreach ($curNum in $listOfNums) 
{
    switch ($curNum) 
    {
        1 {$val1="one";$val2="two";$what=RunMe -param1 $val1 -param2 $val2;Write-Host $what}
        2 {$val1="three";$val2="four";$what=RunMe -param1 $val1 -param2 $val2;Write-Host $what}
        3 {$val1="five";$val2="six";$what=RunMe -param1 $val1 -param2 $val2;Write-Host $what}
        4 {$val1="seven";$val2="eight";$what=RunMe -param1 $val1 -param2 $val2;Write-Host $what}
        5 {$val1="nine";$val2="ten";$what=RunMe -param1 $val1 -param2 $val2;Write-Host $what}
    }
}
