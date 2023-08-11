<#
.SYNOPSIS
This script manages environment variables based on a specified .env file.

.DESCRIPTION
The script reads a path to a .env file from a .envrc file. Then, depending on the mode specified, it either loads or unloads the variables.

.PARAMETER Mode
The mode of operation. Acceptable values are 'allow', 'deny', and 'help'.

.EXAMPLE
.\winenv.exe allow

#>

param(
    [ValidateSet('allow', 'deny', 'help')]
    [string]$Mode = 'help'
)

function LoadEnvironmentVariables {
    # Extract the .env path
    $envrcFilePath = ".envrc"
    $dotenvLine = Get-Content $envrcFilePath | Where-Object { $_ -like "dotenv *" }
    $envFilePath = $dotenvLine -replace "dotenv ", ""
    $loadedVariables = @()

    # Check if the indicated .env file exists
    if (Test-Path $envFilePath) {
        # Read the .env file and process each line
        Get-Content $envFilePath | ForEach-Object {
            # Ignore empty or commented lines
            if ($_ -ne "" -and $_[0] -ne "#") {
                # Extract variable name and value
                $varName, $varValue = $_ -split "=", 2
                # Set the environment variable
                Invoke-Expression "`$env:$varName = '$varValue'"
                $loadedVariables += $varName
            }
        }
        Write-Output "Loaded the following environment variables: $($loadedVariables -join ', ')"
        Write-Output ""
    } else {
        Write-Error "File $envFilePath not found!"
    }
}

function UnloadEnvironmentVariables {
    # Load the .env path again
    $envrcFilePath = ".envrc"
    $dotenvLine = Get-Content $envrcFilePath | Where-Object { $_ -like "dotenv *" }
    $envFilePath = $dotenvLine -replace "dotenv ", ""

    # Check if the indicated .env file exists
    if (Test-Path $envFilePath) {
        # Read the .env file and process each line
        Get-Content $envFilePath | ForEach-Object {
            # Ignore empty or commented lines
            if ($_ -ne "" -and $_[0] -ne "#") {
                # Extract the variable name
                $varName = ($_ -split "=", 2)[0]
                # Unset the environment variable
                Invoke-Expression "`$env:$varName = `$null"
            }
        }
        Write-Output "Unload environment variables"
    } else {
        Write-Error "File $envFilePath not found!"
    }
}

switch ($Mode) {
    "allow" {
        LoadEnvironmentVariables
    }
    "deny" {
        UnloadEnvironmentVariables
    }
    "help" {
        Write-Output @"
winenv - A simple environment manager for Windows.

Created by: Murilo Simao
Version: 1.0

Arguments:
allow : Load environment variables from the specified .env file.
deny  : Unload the previously loaded environment variables.
help  : Display this help message.

Special thanks to the community for their support and feedback!
"@
    }
}
