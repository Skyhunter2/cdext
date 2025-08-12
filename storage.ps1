$aliases = @()
$rem = NewAlias -name rem -value Remove
$aliases += $rem


$aliases += NewAlias -name "-s" -value Save
$aliases += NewAlias -name s -value Save

$aliases += NewAlias -name sa -value SaveAlias
#$aliases += NewAlias -name Check -value List

foreach ($alias in $aliases) {
    $n = $alias.name 
    $v = $alias.value
    Set-Alias -Name $n -Value $v -Scope Global
    Write-Host "$n set as $v"
}

#All user defined alias will go here
#Tode figure out a better way to store them then Add-Content 
Set-Alias -Name check -Value Get-ChildItem -Scope Global
#Set-Alias -Name samba -Value .\sam-ba.exe -x 'C:\Users\orion.newell\Work Folders\Automated Testers\Current_Production_Files\ProductionTestersRelease\UniversalTester\Modules\Chameleon+\TesterCode\ngp_install_tester_code.qml' -Scope Global
Set-Alias -Name samb -Value .\sam-ba.exe -Scope Global
if(AliasExists) {
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "function ltcngpfunc { .\sam-ba.exe -x 'C:\Users\orion.newell\Work Folders\Automated Testers\Current_Production_Files\ProductionTestersRelease\UniversalTester\Modules\Chameleon+\TesterCode\ngp_install_tester_code.qml'  }" 
}
Set-Alias -Name ltcngp -Value ltcngpfunc -Scope Global
