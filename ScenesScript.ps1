# Define path to text file
$file_path = "oficcialRaffles/raffle0.txt"

## Lot 1, 3, 4, 5
## Raffle 0 - Windows 
## Raffle 1 - Ubuntu VM 
## Raffle 2 - Linux Subsystem 
## Raffle 3 - Ubuntu Native 
## Raffle 4 - BSD

## Lot 2
## Raffle 0 - Ubuntu Native 
## Raffle 1 - Ubuntu VM 
## Raffle 2 - Linux Subsystem 
## Raffle 3 - Windows 
## Raffle 4 - BSD

## Lot 4
## Raffle 0 - Windows 
## Raffle 1 - Ubuntu Native 
## Raffle 2 - Linux Subsystem 
## Raffle 3 - Ubuntu VM 
## Raffle 4 - BSD

# Read lines of text file
$text_lines = Get-Content $file_path
$counter = 0
$saveAllLogs = $true
if(Test-Path "timeTook.txt"){
    Clear-Content "timeTook.txt"
}

if(Test-Path "datos-auto.txt"){
    
}
else{
    "Filename      Scene      Accelerator     Sampler     Configuration     Time        OS      Lot     Machine"  | Out-File datos-auto.txt
}

$paramOS = $args[0]
$paramLot = $args[1]
$paramMachine = $args[2] 

Write-Output "*** Welcome to the script we will start generating PBRT images"

# Print each line
foreach ($line in $text_lines) {
    Write-Output "RENDERING: " $line

    if ($saveAllLogs -eq $true){
        $concatenated_string = ".\pbrt.exe '.\" + $line + "' > testing" + $counter + ".txt 2>&1"
    }
    else{
        $concatenated_string = ".\pbrt.exe '.\" + $line + "'"
    }
    
    $line | Out-File timeTook.txt -Append
    Write-Output "Command to be exceuted: "  $concatenated_string

    $startTime = Get-Date
    Measure-Command { Invoke-Expression $concatenated_string } | Out-File timeTook.txt -Append
    $endTime = Get-Date
    $elapsedTime = $endTime - $startTime

    Write-Output "The file $line has been rendered succesfully in $elapsedTime.totalSeconds seconds."
    $counter++

    #Save data
    $fullduration = $elapsedTime.totalSeconds
    
    #For Linux this needs to be changed
    
    $filename = $line.split("/")[2] #Change this if we move folders
    $attributes = $filename.split("-")
    if($attributes.Length -gt 3) { #For buddha-fractal-xxx-yyy
        $scene = "$($attributes[0])-$($attributes[1])"
        $accelerator = $attributes[2]
        $sampler = $attributes[3].split(".")[0]
    }
    else{
        $scene = $attributes[0]
        $accelerator = $filename.split("-")[1]
        $sampler = $filename.split("-")[2].split(".")[0]
    }
    
    Write-Output "$filename $scene $accelerator $sampler $accelerator-$sampler $fullduration $paramOS $paramLot $paramMachine"
    "$filename $scene $accelerator $sampler $accelerator-$sampler $fullduration $paramOS $paramLot $paramMachine" | Out-File datos-auto.txt -Append
}

Write-Output "*** Finished, all PBRT images have been rendered ***"