##!/usr/local/bin/bash
# Define path to text file
file_path="oficcialRaffles/raffle3.txt"

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

## Lot 4, 5
## Raffle 0 - Windows 
## Raffle 1 - Ubuntu Native 
## Raffle 2 - Linux Subsystem 
## Raffle 3 - Ubuntu VM 
## Raffle 4 - BSD

# Read lines of text file
text_lines=$(cat "$file_path")
counter=0
saveAllLogs=true
if [ -f "timeTook.txt" ]; then
    > "timeTook.txt"
fi

if ! [ -f "datos-auto.txt" ]; then
    echo "Filename      Scene      Accelerator     Sampler     Configuration     Time        OS      Lot     Machine" > "datos-auto.txt"
fi

paramOS=$1
paramLot=$2
paramMachine=$3

echo "*** Welcome to the script we will start generating PBRT images ***"

# Print each line
for line in $text_lines; do
    echo "RENDERING: $line"

    if [ "$saveAllLogs" = true ]; then
        concatenated_string="./pbrt './$line' > testing$counter.txt 2>&1"
    else
        concatenated_string="./pbrt './$line'"
    fi
    
    echo "$line" >> "timeTook.txt"
    echo "Command to be exceuted: $concatenated_string"

    startTime=$(date +%s.%N)
    eval "$concatenated_string" >> "timeTook.txt" 2>&1
    endTime=$(date +%s.%N)
    elapsedTime=$(echo "$endTime - $startTime" | bc)

    echo "The file $line has been rendered succesfully in $elapsedTime seconds."
    counter=$((counter+1))

    #Save data
    fullduration=$elapsedTime
    
    #For Linux this needs to be changed
    filename=$(echo "$line" | cut -d'/' -f3) #Change this if we move folders
    IFS='-' read -ra arr <<< "$filename"

    echo $filename

    if [ ${#arr[@]} -gt 3 ]
    then 
        scene=${arr[0]}-${arr[1]}
        accelerator=${arr[2]}
        sampler=${arr[3]}
    else 
        scene=${arr[0]}
        accelerator=${arr[1]}
        sampler=${arr[2]}
    fi

    IFS='.' read -ra arr2 <<< "$sampler"
    sampler=${arr2[0]}

    
    echo "$filename $scene $accelerator  $sampler $accelerator-$sampler  $fullduration  $paramOS  $paramLot  $paramMachine" >> "datos-auto.txt"
done

echo "*** Finished, all PBRT images have been rendered ***"
