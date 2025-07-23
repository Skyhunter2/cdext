param (
    $name,
    $value
)

#code $PROFILE.CurrentUserAllHosts

#If the profile does not already exist, creates a file to append functions too.
if(!(Test-Path -Path $PROFILE.CurrentUserAllHosts)) {
    New-Item -path $PROFILE -type File -Force
}

$AliasStorageFilePath = $PROFILE.CurrentUserAllHosts #Stores the alias in the powershell profile 

#todo: Implement this as a script for storing alias definitions, then call it in C# to store aliases 
#todo: Needs to have the functions persists so that they can be permantly set as an alias.
#Figure out the best way to do this. 

#Clear-Content -Path $AliasStorageFilePath
#Puts the script alias in the file
#Add-Content -Path $AliasStorageFilePath -Value "function worldfunc { Write-Host `"Hello World`" }" #`nSet-Alias -Name hello -value worldfunc -Scope Global"

#Set-Alias -Name test -value .\alias.ps1 -Scope Global

#Set-Alias -Name hello -value worldfunc -Scope Global

#Creates a an alias for the function. 
#Set-Alias -Name cdext -Value C:\Users\orion.newell\Documents\cdext.ps1 -Scope Global 


#Adds a new alias
function New {
    param (
        $name,
        $value
    )
    Set-Alias -Name $name -Value -$value
}

#The definition of the function
function Aliasfunc {
    Write-Host $value
    cmd /c $value
}
#Aliasfunc

#Set-Alias -Name $name -Value Aliasfunc -Scope Global

#Lists known alias'
function List {
    param (
        $List
    )
    Write-Host "wip"
}

function Remove {
    param (
        $value,
        $all
    )
    if($all) {
        Clear-Content -Path $AliasStorageFilePath -Exclude "init"
    }
}

function PrintFunctionAsString {
    param (
        [Parameter(Mandatory=$true)]$name
    )

    $FunctionObject = Get-Command -Name $name -CommandType Function
    $FunctionString = $FunctionObject.ScriptBlock.ToString()
    return "function $name { $FunctionString }"   
}


#Functions related to pathway management

#Saves either current directory or user can name a specific pathway to save as
function Save {
    param (
        [Parameter(Mandatory=$true)]$name,
        $value
    )
    if($null -eq $value) {
        Set-Alias -Name $name -Value $pwd
    } else {
        Set-Alias -Name $name -Value $value
    } 
}

function cd_to {
    param (
        $path
    )
    Set-Location $path.ToString()
}

#intilializes program and sets the defualt alias to be referenced by the cdext script

#Change powershell to be able to parse spaces properly
function initialize() {
    $fileContent = Get-Content -Path $AliasStorageFilePath
    if ($fileContent[1] -eq "#init") {
        #TODO: Develop better check system because this one is kinda bad :)
    } else {
        Write-Host "Initializing CDEXT"
        Add-Content -Path $AliasStorageFilePath -Value "#init" -Force #puts a 'tag' in the profile to check if the program has been previously initialized.

        #
        Add-Content -Path $AliasStorageFilePath -Value "Set-Alias -Name cdext -Value `$PWD\cdext.ps1 -Scope Global" 
        #Add-Content -Path $AliasStorageFilePath -Value "Set-Alias -Name cd_to -Value `$PWD\cdext.ps1 -Scope Global" #Todo: Make powershell able to parse the space in between here 
        Add-Content -Path $AliasStorageFilePath -Value  "function New {param (`$name,`$value) Set-Alias -Name `$name -Value -`$value}"
        Add-Content -Path $AliasStorageFilePath -Value "Set-Alias -Name new -Value new"

        #Remove Functionality
        $RemoveStr = PrintFunctionAsString -name Remove
        Add-Content -Path $AliasStorageFilePath -Value $RemoveStr
        Set-Alias -Name "-remove" -Value Remove
        Set-Alias -Name "-rem" -Value Remove
        Set-Alias -Name "-R" -Value Remove

        #save Functionality
        $SaveStr = PrintFunctionAsString -name Save
        Add-Content -Path $AliasStorageFilePath -Value $SaveStr
        Set-Alias -Name -save -Value Save
        Set-Alias -Name -sav -Value Save
        Set-Alias -Name -sa -Value Save
        Set-Alias -Name "-s" -Value Save
    }
}

initialize
. $PROFILE.CurrentUserAllHosts
notepad.exe $PROFILE.CurrentUserAllHosts
