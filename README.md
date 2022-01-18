# Pester-Codewars

`ConvertTo-Codewars` converts an NUnit 2.5-compatible XML-report to Codewars format.

## Usage

```powershell
Import-Module -Name Pester
Import-Module -Name Pester-Codewars

$config = New-PesterConfiguration
$config.Should.ErrorAction = 'Continue'
$config.Output.Verbosity = 'None'
$config.Run.PassThru = $true

Invoke-Pester -Configuration $config | ConvertTo-NUnitReport | ConvertTo-Codewars
```
