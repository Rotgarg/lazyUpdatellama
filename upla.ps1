# UPDATE ALL LLAMAS IN REVERSE ALPHABETICAL ORDER BECAUSE OF OCD

Write-Host "..red." -ForegroundColor Red
Write-Host "...green." -ForegroundColor Green
Write-Host "....cyan." -ForegroundColor Cyan
Write-Host ".....yellow." -ForegroundColor Yellow
Write-Host "-----ANSI-COLOR-TEST-----" -ForegroundColor Red

Write-Host "YOU ARE USING POWERSHELL VERSION" -ForegroundColor Yellow
$PSVersionTable.PSVersion

function Update-OllamaModels {
    <#
    .SYNOPSIS
    Updates Ollama models.

    .DESCRIPTION
    This function updates Ollama models by pulling the latest versions.

    .PARAMETER Confirm
    Prompts the user for confirmation before updating the models.

    .EXAMPLE
    powershell -ExecutionPolicy Bypass -File "C:\rot\upla.ps1"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$Confirm
    )

    try {
        # List all models and skip the header line
        $modelList = ollama list | Select-Object -Skip 1 | ForEach-Object {
            if ($_ -notmatch '^NAME\s+') {
                if ($_ -match '(\S+)\s+') {
                    $Matches[1]
                }
            }
        }

        if ($null -eq $modelList -or $modelList.Count -eq 0) {
            Write-Host "Failed to retrieve model list." -ForegroundColor Red
            return
        }

        # Sort models in reverse alphabetical order
        $sortedModels = $modelList | Sort-Object -Descending

        if ($sortedModels.Count -eq 0) {
            Write-Host "`nNo models found to update." -ForegroundColor Yellow
            return
        }

        # Confirmation before starting the update process
        if ($Confirm) {
            Write-Host "`nFound $($sortedModels.Count) model(s) that need updating:`n" -ForegroundColor Cyan
            $sortedModels | ForEach-Object { Write-Host "$_" }
            $confirmation = Read-Host "`nDo you want to proceed with the updates? (Y/N)"

            if ($confirmation.ToUpper() -ne 'Y') {
                Write-Host "`nUpdate process cancelled by user." -ForegroundColor Red
                return
            }
        }

        Write-Host "`nUpdating models in reverse alphabetical order:`n" -ForegroundColor Cyan

        $totalModels = $sortedModels.Count
        $currentModel = 0

        foreach ($model in $sortedModels) {
            $currentModel++
            try {
                Write-Host "`nUpdating model: $model ($currentModel/$totalModels)" -ForegroundColor Green
                # Execute the 'ollama pull' command to update the model and capture the output
                $updateOutput = & ollama pull $model 2>&1
                $updateOutput | ForEach-Object { Write-Host $_ -ForegroundColor Green }
                Write-Host "--" -ForegroundColor Green
            } catch {
                Write-Error "Failed to update model $model. Error: $_" -ForegroundColor Red
            }
        }
        Write-Host "`nAll models have been Upgrayedd.`n" -ForegroundColor Cyan
    } catch {
        Write-Error "An error occurred: $_" -ForegroundColor Red
    }
}

# Call the function
Update-OllamaModels -Confirm

