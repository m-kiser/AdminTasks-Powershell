# Script Name: prompts.ps1
# Author: m-kiser

# Ensure the script runs in the "Requirements1" folder
$folderPath = Get-Location  
Set-Location -Path $folderPath

# Function to list .log files with regex and save them to DailyLog.txt
function List-LogFiles {
    $date = Get-Date -Format "yyyy-MM-dd"
    $logFiles = Get-ChildItem -Path $folderPath | Where-Object { $_.Name -match '^.*\.log$|^.*\.LOG$' }
    $logFiles | ForEach-Object { "$date - $_.Name" } | Out-File -FilePath "DailyLog.txt" -Append
}

# Function to list files in Requirements1 sorted in alphabetical order
function List-Contents {
    $contents = Get-ChildItem -Path $folderPath | Sort-Object Name
    $contents | Format-Table Name | Out-File -FilePath "contents.txt"
}

# Function to list CPU and memory usage
function List-CPUMemoryUsage {
    $cpuUsage = Get-CimInstance Win32_Processor | Select-Object LoadPercentage
    $memoryUsage = Get-CimInstance Win32_OperatingSystem | Select-Object FreePhysicalMemory, TotalVisibleMemorySize

    Write-Host "CPU Load: $($cpuUsage.LoadPercentage)%"
    Write-Host "Memory Usage: $([math]::round((($memoryUsage.TotalVisibleMemorySize - $memoryUsage.FreePhysicalMemory) / $memoryUsage.TotalVisibleMemorySize) * 100))%"
}

# Function to list running processes sorted by virtual size
function List-Processes {
    try {
        # Get all running processes and sort by VirtualMemorySize (least to greatest)
        $processes = Get-Process | Sort-Object VirtualMemorySize

        # Select the process name and its virtual memory size
        $sortedProcesses = $processes | Select-Object @{Name="Process Name"; Expression={$_.Name}},
						      @{Name="Virtual Memory Size (Bytes)";Expression={$_.VirtualMemorySize}}

        # Display the sorted processes in grid format
        $sortedProcesses | Out-GridView -Title "Process Sorted by Virtual Memory Size (Least to Greatest)"

    }
    catch {
        Write-Host "An error occurred while retrieving the processes: $_" -ForegroundColor Red
    }
}

# Start of the switch statement for user input
do {
    Write-Host "Choose an option:"
    Write-Host "1. List .log files and save to DailyLog.txt"
    Write-Host "2. List contents of Requirements1 folder sorted"
    Write-Host "3. List current CPU and memory usage"
    Write-Host "4. List running processes sorted by virtual size (least to greatest)"
    Write-Host "5. Exit"

    $userInput = Read-Host "Enter a number (1-5)"

    try {
        switch ($userInput) {
            1 {
                # List .log files and append the results to DailyLog.txt with the current date
                List-LogFiles
                Write-Host "Logged .log files to DailyLog.txt" -ForegroundColor Green
                break
            }
            2 {
                # List the files inside Requirements1 in alphabetical order and output to contents.txt
                List-Contents
                Write-Host "Listed contents of Requirements1 folder to contents.txt" -ForegroundColor Green
                break
            }
            3 {
                # List the current CPU and memory usage
                List-CPUMemoryUsage
                break
            }
            4 {
                # List running processes, sorted by virtual size, and display them in grid format
                List-Processes
                break
            }
            5 {
                # Exit the script
                Write-Host "Exiting script..." -ForegroundColor Yellow
                break
            }
            default {
                Write-Host "Invalid selection. Please choose a valid number (1-5)." -ForegroundColor Red
            }
        }
    }
    catch [System.OutOfMemoryException] {
        Write-Host "Out of Memory Exception occurred!" -ForegroundColor Red
    }
} while ($userInput -ne 5)

Write-Host "Script completed."
