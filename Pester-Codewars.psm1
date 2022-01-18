function ConvertTo-Codewars {
   <#
    .SYNOPSIS
    Converts an NUnit 2.5-compatible XML-report to Codewars format
    .PARAMETER NUnitXML
    NUnit 2.5-compatible XML-report as an XML object.
    .EXAMPLE
    ```powershell
    Import-Module -Name Pester
    Import-Module -Name Pester-Codewars
    $config = New-PesterConfiguration
    $config.Should.ErrorAction = 'Continue'
    $config.Output.Verbosity = 'None'
    $config.Run.PassThru = $true
    Invoke-Pester -Configuration $config | ConvertTo-NUnitReport | ConvertTo-Codewars
    ```
   #>
   param (
       [parameter(Mandatory = $true, ValueFromPipeline = $true)]
       $NUnitXML
   )
   # Uncomment the following to see the XML.
   # Write-Output $NUnitXML.OuterXml
   # "test-results/test-suite" is a wrapper with type="PowerShell" and name="Pester"
   # "test-results/test-suite/results/test-suite" has name="./test.ps1"
   # "test-results/test-suite/results/test-suite/results" contains actual "test-suites"
   $NUnitXML.SelectNodes("test-results/test-suite/results/test-suite/results/*") | Foreach {$o=""} {$o += Get-TestSuite $_} {$o}
}

function Get-TestSuite($node) {
    $o = "`n<DESCRIBE::>$($node.name)`n"
    $node.SelectNodes("results/*") | Foreach {
        if ($_.get_Name() -eq 'test-suite') {
            # don't output ParameterizedTest itself
            if ($_.Type -eq "ParameterizedTest") {
                $_.SelectNodes("results/*") | Foreach {$o += Get-TestCase $_}
            } else {
                $o += Get-TestSuite $_
            }
        } else {
            $o += Get-TestCase $_
        }
    }
    $o + "`n<COMPLETEDIN::>$([math]::round(1000 * $node.time))`n"
}

function Get-TestCase($node) {
    $o = "`n<IT::>$($node.description)`n"
    if ($node.success -eq 'True') {
        $o += "`n<PASSED::>Test Passed`n"
    } else {
        # asertion failure and thrown error is treated as same failure
        # <failure><message></message><stack-trace></stack-trace></failure>
        $m = $node.failure.message -replace "`n", "<:LF:>"
        $s = $node.failure.'stack-trace' -replace "`n", "<:LF:>"
        $o += "`n<FAILED::>$m`n"
        $o += "`n<LOG:ESC:-Stack Trace>$s`n"
    }
    $o + "`n<COMPLETEDIN::>$([math]::round(1000 * $node.time))`n"
}

Export-ModuleMember -Function 'ConvertTo-Codewars'
