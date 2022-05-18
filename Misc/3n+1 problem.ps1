#3n+1 problem

$num=Get-Random -Maximum ([Math]::Pow(31,84))
$mod=0
$outp=0
$noOfRuns=0

function Evaluate {
    $num = $outp
    $mod=$outp%2
    if ($mod -gt 0) {
        #ProcessifOdd
        $outp = (3 * $num + 1)
        TerminateIfOne
    } else {
        #ProcessIfEven
        $outp = $num/2
        TerminateIfOne
    }
}

function TerminateIfOne {
    Write-Host "Output after evaluation: "$outp
    $noOfRuns++
    if ($outp -eq 1) {
        Write-Host "Done after number of runs:" $noOfRuns
    } else {
        Evaluate
    }
}

function StartNow {
    $outp = $num
    Write-Host "`n****Start number****: "$outp
    Evaluate
}
StartNow