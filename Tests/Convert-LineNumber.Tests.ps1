Describe "Convert-LineNumber" {
    Import-Module ModuleBuilder -DisableNameChecking -Verbose:$False

    $ModulePath = Join-Path (Get-Module ModuleBuilder).ModuleBase ModuleBuilder.psm1
    $ModuleRoot = Resolve-Path "$PSScriptRoot\..\Source"

    $ModuleFiles = Get-ChildItem $ModuleRoot -File -Recurse -Filter *.ps1

    It 'Should map a line number in the Output\Module to the right file in the Source\' {
        $SourceLocation = Convert-LineNumber $ModulePath 3
        Join-Path $ModuleRoot $SourceLocation.ScriptName | Resolve-Path | Should -Be $ModuleFiles[0].FullName
        $SourceLocation.ScriptLineNumber | Should -Be 2
    }

    It 'Should map a line number in the Output\Module to the right file in the Source\' {
        $ModuleSource = Get-Content $ModulePath

        for($i=0; $i -lt 5; $i++) {

            $lineNumber = Get-Random -min 2 -max $ModuleSource.Count
            while($ModuleSource[$lineNumber] -match "^#REGION") {
                $lineNumber++
            }

            $SourceLocation = Convert-LineNumber $ModulePath $lineNumber

            $line = (Get-Content (Join-Path $ModuleRoot $SourceLocation.ScriptName))[$SourceLocation.ScriptLineNumber]
            try {
                $ModuleSource[$lineNumber] | Should -Be $line
            } catch {
                throw "Failed to match ModuleSource line $lineNumber to $($SourceLocation.ScriptName) line $($SourceLocation.ScriptLineNumber).`nExpected $Line`nBut got  $($ModuleSource[$lineNumber])"
            }
        }
    }

}