$github = "https://github.com/Skyhunter2/cdext"

<#
 .SYNOPSIS
  An extension to the change directory shell functionality. Saves the specified alias

 .DESCRIPTION
  Adds the ability to create shortcuts to frequently used directory for easy use.

 .PARAMETER SaveAlias
  Save a specific alias to global session. #todo: Implement this and the ability to save parameters

 .EXAMPLE
   # Saves the path specified by <value> as <name>. If value is blank, the current directory is specified
   Save <name> <value>

 .EXAMPLE
   # Changes the current directory to the one specified by <name>
   CD-Extension -Travel <name>

 .EXAMPLE
   # Alias for CD-Extension -Travel name
   cdto <name>
#>
function Save {
    [CmdletBinding()]
    [Alias("s")]
    param (
        [Parameter(Mandatory=$true)]$name,
        $value,
        [Parameter(HelpMessage="Saves as alias")]
        [Alias('sa', 'a')]
        [switch]$SaveAlias = $False
    )

    if($null -eq $value) {
        $value = $pwd
    } 
    if($SaveAlias -eq $False) {
        Set-Item env:$name -Value $value
        [Environment]::SetEnvironmentVariable($name,$value,'User') 
        #[Environment]::SetEnvironmentVariable($name,$value,'Machine') #unlcear if this works 
        Write-Host "$name routes to $value"
    } else {
        Write-Host "Alias functionality unimplemented. View source code at: $github if you wish to contribute."
        #SaveAlias -Name $name -Value $value
    }
    ## powershell.exe | Out-Null #Refreshes session to update envionmental variables. Might be a better way but I am not sure how
    #$env:Path = [System.Environment]::GetEnvironmentVariable($Name,'Machine') + ";" + [System.Environment]::GetEnvironmentVariable($Name,'User') 
}

<#
 .SYNOPSIS
  An extension to the change directory shell functionality. Removes the specified alias.

 .DESCRIPTION
  Allows the user to remove the shortcuts to frequently used directories.

 .PARAMETER Name
  Name should be one of the saved shortcuts

 .EXAMPLE
   # Change directory to path referenced by <name>
   remove <name>

 .EXAMPLE
   remove -a
#>
function Remove { 
    [CmdletBinding()]
    [Alias("rem")]
    param (
        $name,

        [Alias('a')]
        [switch]$All = $false
    )
    if($all) {
        Clear-Content -Path $UserProfilePath -Exclude "#init"
        $env:VariableArray = ""; 
    }
    if($RemAlias) {
        Write-Host "Alias functionality unimplemented. View source code at: $github if you wish to contribute."
    }
    try {
        [Environment]::SetEnvironmentVariable($name,'')
        #Remove-Item -Path Alias:\$name

        #Backups?
        # Remove-Item -Path Env:name
        # $env:name = $null
    }
    catch {
        Write-Host "No pathway with that name"
    }
}

<#
 .SYNOPSIS
  An extension to the change directory shell functionality.

 .DESCRIPTION
  Allows the user to Change Directory to shortcuts to frequently used directory for easy use.

 .PARAMETER Name
  Name should be one of the saved shortcuts

 .EXAMPLE
   # Change directory to path referenced by <name>
   cdto <name>
#>
function Update-Directory {
    [CmdletBinding()]
    [Alias("cdto")]
    param (
        [Parameter(Mandatory=$true)][String] $Name #reference to the path
    )
    try {
        $Session = $Env:CURRENT -split ' '
        if($Session[0] -eq $name) {
            $Session[1] | Set-Location 
        } else {
            [Environment]::GetEnvironmentVariable($Name) | Set-Location
        }
    }
    catch {
        Write-Host "No such pathway exists"
    }
}

#Helper Functions:
function AliasExists {
    param (
        $name
    )
    $doesExist = $false

    $retrievedString = $env:MY_ENV_VAR
    $retrievedArray = $retrievedString -split ";"
    foreach ($alias in $retrievedArray) {
        if ($name -eq $alias) {
            $doesExist = $true
        } 
    }
    return $doesExist
}

function SaveAlias { 
    param (
        [Parameter(Mandatory=$true)]$name,
        $value,
        [boolean] $new
    )

    if($null -eq $value) {
        $value = $pwd
    } 
    Set-Alias -Name $name -Value $value -Scope Global
    Write-Host "$name set as $value"
    #implement a check for a unique name and name for the function
    $funcstring = $value.toString()
    $exist = AliasExists($name)
    Write-Host ($Exist)
    if(!$exist) {
        $namefunc = $name + "func"
        Add-Content -Path $savepath -Value "Set-Alias -Name $name -Value $namefunc -Scope Global"
        Add-Content -Path $UserProfilePath -Value "function $namefunc { $funcstring }" #Adds function to profile 
        $env:VariableArray += $name + ";"
    } else { #Todo: add the ability to show what the alias is set to, currently not implemented
        Write-Host "That alias already exists: $name is set to " | Get-Alias -Name $name
    }
 }

 Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
  [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
  public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
"@

function Send-SettingChange {
  $HWND_BROADCAST = [IntPtr] 0xffff;
  $WM_SETTINGCHANGE = 0x1a;
  $result = [UIntPtr]::Zero

  [void] ([Win32.Nativemethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, "Environment", 2, 5000, [ref] $result))
}

 Export-ModuleMember -Function Update-Directory
 Export-ModuleMember -Function Remove
 Export-ModuleMember -Function Save