# UPDATE ALL LLAMAS IN REVERSE ALPHABETICAL ORDER BECAUSE OF OCD

function Update-OllamaModels {
    <#
    .SYNOPSIS
    Updates Ollama models.

    .DESCRIPTION
    This function updates Ollama models by pulling the latest versions.

    .PARAMETER Confirm
    Prompts the user for confirmation before updating the models.

    .EXAMPLE
    powershell -ExecutionPolicy Bypass -File "C:\SDA1111\upla.ps1"
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
            $confirmation = Read-Host "`nDo you want to proceed with the updates? (Y/N)" -ForegroundColor Cyan

            if ($confirmation.ToUpper() -ne 'Y') {
                Write-Output "`nUpdate process cancelled by user." -ForegroundColor Red
                return
            }
        }

        Write-Host "`nUpdating models in reverse alphabetical order:`n" -ForegroundColor Cyan

        foreach ($model in $sortedModels) {
            try {
                Write-Output "`nUpdating model: $model"
                # Execute the 'ollama pull' command to update the model
                ollama pull $model | ForEach-Object { Write-Host $_ -ForegroundColor Green }
                Write-Output "--"
            } catch {
                Write-Error "Failed to update model $model. Error: $_" -ForegroundColor Red
            }
        }
        Write-Output "`nAll models have been processed.`n" -ForegroundColor Green
    } catch {
        Write-Error "An error occurred: $_" -ForegroundColor Red
    }
}

# Call the function
Update-OllamaModels -Confirm