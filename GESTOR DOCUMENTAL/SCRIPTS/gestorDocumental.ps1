function establecerHorario {

    $file_users=Import-Csv -Path ..\CSV\usuarios.csv -Delimiter ';'
    foreach ($user in $file_users) { 
        net user $user.cuenta $user.horario
    }
}
function ocultarUsuarios {

    $file_users=Import-Csv -Path ..\CSV\usuarios.csv -Delimiter ';'
    foreach ($user in $file_users) { 
        REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /V $user.cuenta /T REG_DWORD /D 0
    }

}
function ayudaBorrar {
    param ( 
           [string]$Titulo = 'Usuarios Locales - Gestor Documental - Ayuda' 
     )

     param ( 
           [string]$Bienvenida = '                       Bienvenid@' 
     ) 

     $Today = (Get-Date).DateTime

     Clear-Host 
     Write-Host $Bienvenida $env:USERNAME
     Write-Host
     Write-Host $Today 
     Write-Host
     Write-Host "================ $Titulo ================" 
     Write-Host "En el menu de Eliminacion tenemos dos apartados:"
     Write-Host "1: El primer aprtado elimina todos los usuarios y grupos creados anteriormente"
     Write-Host "2: El segundo aprtado elimina todos los directorios creados anteriormente"

     pause

}
function ayudaCrear {
    param ( 
           [string]$Titulo = 'Usuarios Locales - Gestor Documental - Ayuda' 
     )

     param ( 
           [string]$Bienvenida = '                       Bienvenid@' 
     ) 

     $Today = (Get-Date).DateTime

     Clear-Host 
     Write-Host $Bienvenida $env:USERNAME
     Write-Host
     Write-Host $Today 
     Write-Host
     Write-Host "================ $Titulo ================" 
     Write-Host "En el menu de Creación tenemos dos apartados:"
     Write-Host "1: El primer aprtado crea todos los usuarios y grupos"
     Write-Host "2: El segundo aprtado crea todos los directorios"
     Write-Host "3: El tercer aprtado establece todos los permisos"

     pause
}
function establecePermisos {

    $file_permisos=Import-Csv -Path ..\CSV\permisos.csv -Delimiter ';'
    foreach ($permisos in $file_permisos) {
        $GetACL = Get-Acl $permisos.ruta
        $accessControlType=[System.Security.AccessControl.AccessControlType]::Allow
        $objectUG=New-Object System.Security.Principal.NTAccount($permisos.grupo)
        $Allinherit = [system.security.accesscontrol.InheritanceFlags]"ContainerInherit, ObjectInherit"
        $Allpropagation = [system.security.accesscontrol.PropagationFlags]"None"
        $Permissions = [System.Security.AccessControl.FileSystemRights]$permisos.permiso
        $AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule($objectUG, $Permissions, $AllInherit, $Allpropagation, $accessControlType)
        $GetACL.AddAccessRule($AccessRule)
        Set-Acl -aclobject $GetACL -Path $permisos.ruta
    }

}
function quitaHerencia {

    $file_directory=Import-Csv -Path ..\CSV\directorios.csv -Delimiter ';'
    foreach ($directory in $file_directory) { 
        $acl = Get-Acl $directory.ruta

        #Quitar herencia dejando los permisos
        $acl.SetAccessRuleProtection($true,$true)

        #Quitar los permisos a Usuarios y Usuarios Autentificados
        $accessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule("Usuarios","FullControl","Allow") 
        $acl.RemoveAccessRule($accessRule1)
        $accessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("Usuarios autentificados","FullControl","Allow")
        $acl.RemoveAccessRule($accessRule2)

        $acl | Set-Acl  $directory.ruta
    }
}
function borraDirectorios {

    Remove-Item -Path D:\Publico -Recurse
    return

}
function creaDirectorios {

    $file_directory=Import-Csv -Path ..\CSV\directorios.csv -Delimiter ';'
    foreach ($directory in $file_directory) { 
        New-Item -Path $directory.ruta -ItemType Directory
    }

    return

}
function borraUsuariosGrupos {

    $file_users=Import-Csv -Path ..\CSV\usuarios.csv -Delimiter ';'
    foreach ($user in $file_users) { 
        Remove-LocalUser $user.cuenta

    }
    $file_groups=Import-Csv -Path ..\CSV\grupos.csv -Delimiter ';'
    foreach ($group in $file_groups) { 
        Remove-LocalGroup $group.nombre
    }

    

    return
}
function creaUsuariosGrupos {
    $file_groups=Import-Csv -Path ..\CSV\grupos.csv -Delimiter ';'
    foreach ($group in $file_groups) { 
        New-LocalGroup -Name $group.nombre -Description $group.Descripcion
    }

    $file_users=Import-Csv -Path ..\CSV\usuarios.csv -Delimiter ';'
    foreach ($user in $file_users) { 
        $clave=ConvertTo-SecureString $user.password -AsPlainText -Force
        New-LocalUser -Name $user.cuenta -Description $user.descripcion -Password $clave
        #Añadimos la cuenta de usuario en el grupo de Usuarios del sistema
        Add-LocalGroupMember -Group $user.grupo -Member $user.cuenta
        Add-LocalGroupMember -Group usuarios -Member $user.cuenta

    }

    $file_users_groups=Import-Csv -Path ..\CSV\usuarios_agrupos.csv -Delimiter ';'
    foreach ($groupUsers in $file_users_groups) {
        Add-LocalGroupMember -Group $groupUsers.grupo -Member $groupUsers.usuario
    }
}
function submenu_ayuda
{
     param ( 
           [string]$Titulo = 'Usuarios Locales - Gestor Documental - Ayuda' 
     )

     param ( 
           [string]$Bienvenida = '                       Bienvenid@' 
     ) 

     $Today = (Get-Date).DateTime

     Clear-Host 
     Write-Host $Bienvenida $env:USERNAME
     Write-Host
     Write-Host $Today 
     Write-Host
     Write-Host "================ $Titulo ================"
     Write-Host "1: Ayuda sobre el menu de creación "
     Write-Host "2: Ayuda sobre el menu de eliminación "
     Write-Host "s: Volver al menu principal."
do
{
     $input = Read-Host "Por favor, pulse una opción"
     switch ($input)
     {
           '1' {
                ayudaCrear
                return
           } '2' {
                ayudaBorrar
                return
           } 's' {
                "Saliendo del submenu..."
                return
           } 
     }
}
until ($input -eq 'q')
}
function submenu_borrar
{
     param ( 
           [string]$Titulo = 'Usuarios Locales - Gestor Documental - Borrar' 
     )

     param ( 
           [string]$Bienvenida = '                       Bienvenid@' 
     ) 

     $Today = (Get-Date).DateTime

     Clear-Host 
     Write-Host $Bienvenida $env:USERNAME
     Write-Host
     Write-Host $Today 
     Write-Host
     Write-Host "================ $Titulo ================"
     Write-Host "1: Eliminación de usuarios y grupos locales "
     Write-Host "2: Eliminación de Directorios "
     Write-Host "s: Volver al menu principal."
do
{
     $input = Read-Host "Elegir una Opción"
     switch ($input)
     {
           '1' {
                borraUsuariosGrupos
                return
           } '2' {
                borraDirectorios
                return
           } 's' {
                "Saliendo del submenu..."
                return
           } 
     }
}
until ($input -eq 'q')
}
function submenu_crear
{
     param ( 
           [string]$Titulo = 'Usuarios Locales - Gestor Documental - Crear' 
     )

     param ( 
           [string]$Bienvenida = '                       Bienvenid@' 
     ) 

     $Today = (Get-Date).DateTime

     Clear-Host 
     Write-Host $Bienvenida $env:USERNAME
     Write-Host
     Write-Host $Today 
     Write-Host
     Write-Host "================ $Titulo ================"
     Write-Host "1: Creación de usuarios y grupos locales "
     Write-Host "2: Creación de directorios "
     Write-Host "3: Establecer permisos"
     Write-Host "4: Extra"
     Write-Host "s: Volver al menu principal."
do
{
     $input = Read-Host "Por favor, pulse una opción"
     switch ($input)
     {
           '1' {
                creaUsuariosGrupos
                ocultarUsuarios
                #establecerHorario
                return
           } '2' {
                creaDirectorios
                return
           } '3' {
                quitaHerencia
                quitaHerencia
                establecePermisos
                return
           } '4' {
                Write-Host "La función extra es la creación de carpetas para el usuario de alumnado y profesorado por si acaso"
                return
           } 's' {
                "Saliendo del submenu..."
                return
           } 
     }
}
until ($input -eq 'q')
}

#Función que nos muestra un menú por pantalla con 3 opciones, donde una de ellas es para acceder
# a un submenú) y una última para salir del mismo.

function mostrarMenu 
{ 

     param ( 
           [string]$Titulo = 'Usuarios Locales - Gestor Documental' 
     )

     param ( 
           [string]$Bienvenida = '                       Bienvenid@' 
     ) 

     $Today = (Get-Date).DateTime

     Clear-Host 
     Write-Host $Bienvenida $env:USERNAME
     Write-Host
     Write-Host $Today 
     Write-Host
     Write-Host "================ $Titulo ================" 
     Write-Host "1. Crear" 
     Write-Host "2. Borrar"
     Write-Host "3. Ayuda" 
     Write-Host "s. Presiona 's' para salir"
}

do 
{ 
     mostrarMenu 
     $input = Read-Host "Elegir una Opción" 
     switch ($input) 
     { 
           '1'  { 
                submenu_crear
           } '2' { 
                submenu_borrar
           } '3' {
                submenu_ayuda
           } 's' {
                'Saliendo del script...'
                return 
           }  
     } 
     pause 
} 
until ($input -eq 's')