param (
    $name,
    $value
)

code $PROFILE.CurrentUserAllHosts

#If does not already exist, creates a file to append functions too.
if(!(Test-Path -Path ".\alias.ps1")) {
    New-Item -Path . -Name "alias.ps1" -ItemType "File" #-Value "This is a text string."
} else {
    #import-Alias -Path ".\alias.ps1" -Force
}
$AliasStorageFilePath = $PROFILE.CurrentUserAllHosts #Sets the created or existing file to contain the alias
                                      #All alais functions will be sored here.
                                      #Functions as a way to use the alias even outside the cdext tool

#todo: Implement this as a script for storing alias definitions, then call it in C# to store aliases 
#todo: Needs to have the functions persists so that they can be permantly set as an alias.
#Figure out the best way to do this. 

#notepad.exe $HOME\Documents\PowerShell\Profile.ps1

#Runs the CDEXT script
function worldfunc {
    Write-Host "Hello World"
}
#$name = cdextfunc

Clear-Content -Path $AliasStorageFilePath
#Puts the script alias in the file
Add-Content -Path $AliasStorageFilePath -Value "function worldfunc { Write-Host `"Hello World`" } `nSet-Alias -Name hello -value worldfunc -Scope Global"
#Add-Content -Path $AliasStorageFilePath -Value "param (`n`$func`n)"
#Add-Content -Path $AliasStorageFilePath -Value "if (`$func -eq 1) {write-host 'Success'}"
#Add-Content -Path $AliasStorageFilePath -Value "Get-ChildItem"

#Set-Alias -Name test -value .\alias.ps1 -Scope Global

Set-Alias -Name hello -value worldfunc -Scope Global

#Creates a an alias for the function. 
#Set-Alias -Name cdext -Value C:\Users\orion.newell\Documents\cdext.ps1 -Scope Global 


#Adds a new alias
function New {
    param (
        $name,
        $value
    )
    Write-Host "wip"
}

#The definition of the function
function Aliasfunc() {
    Write-Host $value
    cmd /c $value
}
#Aliasfunc

#Set-Alias -Name $name -Value Aliasfunc -Scope Global

#Lists known alias'
function List() {
    param (
        $List
    )
    Write-Host "wip"
}

#intilializes program and sets the defualt alias to be referenced by the cdext script
function initialize() {
    $fileContent = Get-Content -Path $AliasStorageFilePath
    if ($fileContent[0] -eq "init") {
        #TODO: Develop better check system because this one is kinda bad :)
    } else {
        Write-Host "Initializing CDEXT"
        Add-Content -Path $AliasStorageFilePath -Value "init" #puts a 'tag' in the profile to check if the program has been previously initialized.
        Add-Content -Path $AliasStorageFilePath -Value "function worldfunc { Write-Host `"Hello World`" } `nSet-Alias -Name hello -value worldfunc -Scope Global"
        ASet-Alias -Name cdext -Value $PWD\cdext.ps1 -Scope Global 
    }
}

initialize