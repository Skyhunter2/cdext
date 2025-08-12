#If the profile does not already exist, creates a file to append functions too.
if(!(Test-Path -Path $PROFILE.CurrentUserAllHosts)) {
    New-Item -path $PROFILE -type File -Force
}

$AliasStorageFilePath = $PROFILE.CurrentUserAllHosts #Stores the alias in the powershell profile 

#todo: Implement this as a script for storing alias definitions, then call it in C# to store aliases 
#todo: Needs to have the functions persists so that they can be permantly set as an alias.
#Figure out the best way to do this. 

#----------------------------------------------
#Function for the CDext Script exclusively
#----------------------------------------------
function PrintFunctionAsString {
    param (
        [Parameter(Mandatory=$true)]$name
    )

    $FunctionObject = Get-Command -Name $name -CommandType Function
    $FunctionString = $FunctionObject.ScriptBlock.ToString()
    return "function $name { $FunctionString }"   
}

#----------------------------------------------
#Functions related to pathway management
#----------------------------------------------

#Lists known alias'
function List {
    param (
        $List
    )
    Write-Host "wip"
}

function Remove { 
    param (
        $name,
        $all
    )
    if($all) {
        Clear-Content -Path $AliasStorageFilePath -Exclude "#init"
        $env:VariableArray = ""; 
    }
    try {
        [Environment]::SetEnvironmentVariable($name,'')
        Remove-Item -Path Alias:\$name
    }
    catch {
        Write-Host "No pathway with that name"
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

#Saves either current directory or user can name a specific pathway to save as
function Save {
    param (
        [Parameter(Mandatory=$true)]$name,
        $value
    )

    if($null -eq $value) {
        $value = $pwd
    } 
    [Environment]::SetEnvironmentVariable($name,$value,'User') 
    Write-Host "$name routes to $value"
}

#Checks if an alias exists
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

#Instead of this, maybe have a variable called command that saves it as an alias instead
#So things like the ECE tester and Samba can be executed by a command
function SaveAlias { 
    param (
        [Parameter(Mandatory=$true)]$name,
        $value
    )

    if($null -eq $value) {
        $value = $pwd
    } 
    Set-Alias -Name $name -Value $value -Scope Global
    Write-Host "$name set as $value"
    #implement a check for a unique name and name for the function
    $funcstring = $value.toString()
    #implement a check for a unique name and name for the function
    $funcstring = $value.toString()
    $exist = AliasExists($name)
    if(!$exist) {
        Add-Content -Path $savepath -Value  "Add-Content -Path `$PROFILE.CurrentUserAllHosts -Value `"function $name+func { $funcstring }`" "
        Add-Content -Path $savepath -Value "Set-Alias -Name $name -Value $name -Scope Global"
        $env:VariableArray += $name + ";"
    } else { #Todo: add the ability to show what the alais is set to 
        Write-Host "That alias already exists: $name is set to " | Get-Alias -Name $name
    }
 }

#Sets the directory location to the specified paths
function CDto {
    param (
        [Parameter(Mandatory=$true)][String] $path
    )
    try {
        [Environment]::GetEnvironmentVariable($path) | Set-Location
    }
    catch {
        Write-Host "No such pathway exists"
    }
}

#Prints a list of all commands
function Help {
    Write-Host 
}

#Prints a list of all pathways
function List {
    Get-ChildItem Env:
}

#--------------------------------------------------
# intilializes program and sets the defualt alias 
# to be referenced by the cdext script
#-------------------------------------------------
#Change powershell to be able to parse spaces properly
function initialize() {
    $fileContent = Get-Content -Path $AliasStorageFilePath
    if ($null -ne $fileContent) {
        #TODO: Develop better check system because this one is kinda bad :)
        Write-Host "Program previously intialized"
    } else {
        $myArray = "cdto","list"
        $env:VariableArray = ($myArray -join ";") # Join with a semicolon
        
        New-Item -Path $path -ItemType script
        Write-Host "Initializing CDEXT"
        Add-Content -Path $AliasStorageFilePath -Value "#init" -Force #puts a 'tag' in the profile to check if the program has been previously initialized.

        #Add-Content $global:saves = @()
        #
        Add-Content -Path $AliasStorageFilePath -Value "Set-Alias -Name cdext -Value `$PWD\cdext.ps1 -Scope Global" 
        #Add-Content -Path $AliasStorageFilePath -Value "Set-Alias -Name cd_to -Value `$PWD\cdext.ps1 -Scope Global" #Todo: Make powershell able to parse the space in between here 
        Add-Content -Path $AliasStorageFilePath -Value  "function New {param (`$name,`$value) Set-Alias -Name `$name -Value -`$value}"
        Add-Content -Path $AliasStorageFilePath -Value "Set-Alias -Name new -Value new"

        $SaveAlias = PrintFunctionAsString -name SaveAlias
        Add-Content -Path $AliasStorageFilePath -Value $SaveAlias
        Add-Content -Path $AliasStorageFilePath -Value "Set-Alias -Name sa -Value SaveAlias"

        . $PROFILE.CurrentUserAllHosts

        #----------------------------------------

        #Remove Functionality
        $RemoveStr = PrintFunctionAsString -name Remove
        Add-Content -Path $AliasStorageFilePath -Value $RemoveStr
        #sa -Name "-remove" -Value Remove #Included by default due to the function names, so setting an alias for them is redundant
        sa -Name "-rem" -Value Remove
        sa -Name "-R" -Value Remove

        #save Functionality
        $SaveStr = PrintFunctionAsString -name Save
        Add-Content -Path $AliasStorageFilePath -Value $SaveStr
        #sa -Name save -Value Save #Included by default due to the function names, so setting an alias for them is redundant
        sa -Name sav -Value Save
        sa -Name "-s" -Value Save

        $SaveAlias = PrintFunctionAsString -name SaveAlias
        Add-Content -Path $AliasStorageFilePath -Value $SaveAlias
        sa -Name saveas -Value SaveAsAlias
        sa -Name savea -Value SaveAsAliass
        #Set-Alias -Name sa -Value SaveAsAlias

        $exist = PrintFunctionAsString -name AliasExists
        Add-Content -Path $AliasStorageFilePath -Value $exist

        $cd2 = PrintFunctionAsString -name CDto
        Add-Content -Path $AliasStorageFilePath -Value $cd2
        Set-Alias -Name cdto -Value CDto #also redundant

        $list = PrintFunctionAsString -name List
        Add-Content -Path $AliasStorageFilePath -Value $list
        Set-Alias -Name list -Value List #Todo: Change this
    }
}

initialize
. $PROFILE.CurrentUserAllHosts
code $PROFILE.CurrentUserAllHostsparam (
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
        $name,
        $all
    )
    if($all) {
        Clear-Content -Path $AliasStorageFilePath -Exclude "#init"
    }
    try {
        [Environment]::SetEnvironmentVariable($name,'')
    }
    catch {
        Write-Host "No pathway with that name"
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
        [Environment]::SetEnvironmentVariable($name,$pwd)
    } else {
        [Environment]::SetEnvironmentVariable($name,$value)
    } 
}


function SaveAsAlias {
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


function CDto {
    param (
        [String] $path
    )
    try {
        [Environment]::GetEnvironmentVariable($path) | Set-Location
    }
    catch {
        Write-Host "No such pathway exists"
    }
}

function Help {
    
}

#intilializes program and sets the defualt alias to be referenced by the cdext script

#Change powershell to be able to parse spaces properly
function initialize() {
    $fileContent = Get-Content -Path $AliasStorageFilePath
    if ($fileContent[1] -eq "#init") {
        #TODO: Develop better check system because this one is kinda bad :)
        Write-Host "Program previously intialized"
    } else {
        Write-Host "Initializing CDEXT"
        Add-Content -Path $AliasStorageFilePath -Value "#init" -Force #puts a 'tag' in the profile to check if the program has been previously initialized.

        #Add-Content $global:saves = @()
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
        Set-Alias -Name save -Value Save
        Set-Alias -Name sav -Value Save
        Set-Alias -Name sa -Value Save
        Set-Alias -Name "-s" -Value Save

        $SaveAlias = PrintFunctionAsString -name SaveAsAlias
        Add-Content -Path $AliasStorageFilePath -Value $SaveAlias
        Set-Alias -Name saveas -Value SaveAsAlias
        Set-Alias -Name savea -Value SaveAsAliass
        Set-Alias -Name sa -Value SaveAsAlias

        $cd2 = PrintFunctionAsString -name CDto
        Add-Content -Path $AliasStorageFilePath -Value $cd2
        Set-Alias -Name cdto -Value CDto

    }
}

initialize
. $PROFILE.CurrentUserAllHosts
notepad.exe $PROFILE.CurrentUserAllHosts

