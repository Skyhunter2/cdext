$scriptGuid = "9897909" # Use a unique GUID for your specific script/task
$mutexName = "Global\" + $scriptGuid
$createdNew = $false
$script:SingleInstanceMutex = New-Object System.Threading.Mutex $true, $mutexName, ([ref]$createdNew)#Build


$PSModulePath = "C:\Users\orion.newell\Documents\WindowsPowerShell\Modules\CDExtension\CDExtension.psm1"
$UserProfilePath = $PROFILE.CurrentUserAllHosts
#Save the current value in the $p variable.
$p = [Environment]::GetEnvironmentVariable("PSModulePath")

#add the new path to the $p variable. Begin with a semi-colon separator.
$p += ";$PSModulePath"

#Add the paths in $p to the PSModulePath value.
[Environment]::SetEnvironmentVariable("PSModulePath",$p)

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


#If script is run already, no need to overwrite profile
$script:SingleInstanceMutex = New-Object System.Threading.Mutex $true, $mutexName, ([ref]$createdNew)

if (-not $createdNew) {
    Write-Warning "Another instance of this script is already running or has run recently. Exiting."
    # Optional: Release the mutex if you want the _next_ instance to run
    # $script:SingleInstanceMutex.Close() 
    exit
}

if(!(Test-Path -Path $PROFILE.CurrentUserAllHosts)) {
    New-Item -path $PROFILE -type File -Force
}
Add-Content -Path $UserProfilePath -Value "Import-Module -Name $PSModulePath -Verbose | Out-Null"
Add-Content -Path $UserProfilePath -Value "-Set-Alias -name cdto -value Update-Directory"
Add-Content -Path $UserProfilePath -Value "Set-Alias -name rem -value Remove"


# Ensures the mutex is released when the script finishes (recommended in a finally block)
# or when the variable goes out of scope (usually at script exit)
Register-EngineEvent -Source PowerShell.Exiting -Action {
    if ($script:SingleInstanceMutex) {
        $script:SingleInstanceMutex.ReleaseMutex()
        $script:SingleInstanceMutex.Dispose()
    }
}