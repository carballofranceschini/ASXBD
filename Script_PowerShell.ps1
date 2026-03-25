#1. POWERSHELL GENERAL

#1.b. VERSIONES Y POLÍTICA

#Consultamos versión de PowerShell
$PSVersionTable

#Comprobamos política actual
Get-ExecutionPolicy

#Modificamos la política actual por una sin restricciones
Set-ExecutionPolicy Unrestricted

#Comprobamos de nuevo la política para ver si se ha aplicado el cambio
Get-ExecutionPolicy

#1.c. AYUDAS

#Ver ayuda de los comandos
Get-Help

#Ver ayuda de los comandos filtrando por los referidos a SQL
Get-Help *SQL* 

#Ver ayuda de los comandos filtrando por los referidos a SQL, añadiendo ejemplos
Get-Help *SQL* -Examples

#Obtener ayuda de un comando en concreto
Get-Help Set-ExecutionPolicy

#Obtener ayuda de un comando en concreto y que muestre dicha ayuda en una ventana
Get-Help Set-ExecutionPolicy -ShowWindow

#1.d. COMANDOS EXTERNOS

#Algunos comandos externos que también funcionan en PowerShell
ipconfig
ping localhost -n 4

#1.e. ALIAS

#Obtener listado de alias 
Get-Alias

#Obtener alias de un comando específico
Get-Alias -Definition Get-Member

#Crear un nuevo alias para un comando
Set-Alias fecha Get-Date

#Pruebo el alias creado
fecha

#Eliminar un alias
Remove-Item Alias:fecha

#1.f. TUBERÍAS

#Redireccionamos la salida de un comando a un archivo .txt utilizando una tubería
Get-Alias | Out-File C:\PowerShell\Salida.txt

#Redireccionamos la salida de un comando a una nueva ventana
Get-Alias | Out-GridView

#2. POWERSHELL APLICADO A SQL SERVER

#2.a. INSTALACIÓN MÓDULO SQL SERVER

#Instalar cmdlets para sql server, pero con el -AllowClobber sobreescribimos datos si ya existen y evita errores
Install-Module -Name SqlServer -AllowClobber

#Comprobamos que se haya instalado
Get-Module SqlServer -ListAvailable

#Listado de los comandos de tipo cmdlet específicos de SQL Server y abiertos en una nueva ventana
Get-Command -Module SqlServer -CommandType Cmdlet | Out-GridView 

#2.b. SERVICIOS

#Búsqueda de servicios filtrando por nombre (audio) y con salida en formato de lista
Get-Service | Where-Object {$_.Name -like '*audio*'} | Format-List

#Lo mismo que lo anterior, pero filtrando con otra palabra (sql) y con la salida en formato de tabla ($_ es el alias de Get-Service)
Get-Service | Where-Object {$_.name -like '*sql*'} | Format-Table –AutoSize

#Comprobar el estado del servicio
Get-Service -Name 'MSSQLSERVER'

#Detener el servicio
Stop-Service -Name 'MSSQLSERVER'

#Comprobamos el estado del servicio para ver si se ha detenido
Get-Service -Name 'MSSQLSERVER'

#Iniciar el servicio
Start-Service -Name 'MSSQLSERVER'

#Comprobamos que se haya iniciado de nuevo
Get-Service -Name 'MSSQLSERVER'

#2.c. INVOKE-SQLCMD

#En primer lugar creo dos variables para utilizar con las sentencias
$server = "localhost"
$database = "Laboratorio_Analisis_Clinicos"

#Realizo un SELECT para comprobar que la tabla dbo.Paciente está vacía
Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT * FROM PACIENTE;" -TrustServerCertificate

#Hago un INSERT para introducir datos en la tabla
Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO PACIENTE (ID_Paciente, DNI, Nombre, Primer_Apellido, Segundo_Apellido, Fecha_Nacimiento, Sexo, Grupo_Sanguíneo, Número_Teléfono, Dirección, Correo_Electrónico) VALUES (1, '22334455B', 'Pedro', 'Gomez', 'Ruiz', '1985-07-23', 'Masculino', 'B-', '600333444', 'Avenida Norte 12', 'pedro@example.com'), (2, '55667788C', 'Lucia', 'Martinez', 'Garcia', '1992-05-15', 'Femenino', 'O+', '600555666', 'Calle del Sol 21', 'lucia@example.com'), (3, '66778899D', 'Carlos', 'Ramirez', 'Torres', '1988-11-30', 'Masculino', 'AB+', '600777888', 'Avenida Central 78', 'carlos@example.com');" -TrustServerCertificate

#Realizo otro SELECT para comprobar que se hayan insertado los datos
Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT * FROM PACIENTE;" -TrustServerCertificate

#Igual que el SELECT anterior, pero con salida en una nueva ventana
Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT * FROM PACIENTE;" -TrustServerCertificate | ogv 

#2.d. BACKUP/RESTORE

#Crear backup con Invoke-Sqlcmd
Invoke-Sqlcmd -ServerInstance $server -Query “BACKUP DATABASE [$database] TO DISK = 'C:\Backup\Laboratorio.bak' WITH INIT, FORMAT;" -TrustServerCertificate

#Crear backup con el cmdlet Backup-SqlDatabase
Backup-SqlDatabase -ServerInstance $server -Database $database -BackupFile "C:\Backup\Laboratorio_cmdlet.bak"

#Igual que el comando anterior, pero con un parámetro para que se sobreescriba el backup si ya existe uno con el mismo nombre
Backup-SqlDatabase -ServerInstance $server -Database $database -BackupFile "C:\Backup\Laboratorio_cmdlet.bak" -Initialize

#Borro la base de datos y da error por estar en uso
Invoke-Sqlcmd -Serverinstance $server -Query “DROP DATABASE Laboratorio_Analisis_Clinicos” -TrustServerCertificate

#Añado sentencia para cerrar conexiones activas y vuelvo a probar. Esta vez funciona
Invoke-Sqlcmd -Serverinstance $server -Query “ALTER DATABASE [$database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE Laboratorio_Analisis_Clinicos” -TrustServerCertificate

#Restauro la base de datos
Restore-SqlDatabase -Serverinstance $server -Database $database -Backupfile “C:\Backup\Laboratorio_cmdlet.bak” -TrustServerCertificate

#Backup con fecha y hora mediante variables
$date = Get-Date -Format yyyyMMddHHmmss
Backup-SqlDatabase -Serverinstance $server -Database $database -BackupFile "C:\Backup\$($database)_db_$($date).bak"

#2.e. DBATOOLS

#Instalar dbatools
Install-Module -Name "dbatools"

#Comprobar que las dbatools estén instaladas
Get-InstalledModule -Name "dbatools"

#2.f. PROCEDIMIENTOS ALMACENADOS DESDE POWERSHELL

#Probamos el procedimiento almacenado desde PowerShell
$datospaciente = Invoke-Sqlcmd -ServerInstance "localhost" -Database "Laboratorio_Analisis_Clinicos" -Query "EXEC Datos_Paciente @ID_Paciente = 2" -TrustServerCertificate

#Pruebo a que me devuelva los datos del paciente
$datospaciente

#Redirecciono el resultado con una tubería y lo muestro en forma de tabla seleccionando los datos concretos que quiero de vuelta
$datospaciente | Format-Table Nombre, Primer_Apellido, Segundo_Apellido, Sexo, DNI, Número_Teléfono

#3. LIBRERÍAS DE CLASES

#3.a. LIBRERÍAS SMO

#3.a.I. CREAR UNA BASE DE DATOS

#En caso de error por no encontrar la librería SMO empezamos ejecutando estos dos comandos
Install-Module SqlServer
Import-Module SqlServer

#Definimos dos variables, una para el nombre de la instancia y otra para el servidor
$InstanceName = "localhost"
$Server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $InstanceName

<# A continuación comprobamos la existencia de la base de datos con una propiedad del objeto $Server, que es Databases. 
En concreto queremos que se vean nombre, estado, dueño y fecha de creación #>
$Server.Databases | Select Name, Status, Owner, CreateDate

#Creamos una nueva base de datos llamada lcf
$dbName = "lcf"
$db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database($Server, $dbName)
$db.Create()

#Comprobamos que la base de datos se haya creado
$Server.Databases | Select Name, Status, Owner, CreateDate

#3.a.II. CONECTARSE A UNA BASE DE DATOS

<# Creamos la conexión con la base de datos. Para que funcione primero tenemos que crear una variable (en mi caso $MiConexion) en la 
que añadimos el parámetro -TrustServerCertificate. Esto se debe a que si al realizar la conexión con Get-DbaDatabase 
sólo ponemos como instancia de SQL “localhost” nos dará error por no confiar en el certificado, y Get-DbaDatabase no permite 
añadir el parámetro -TrustServerCertificate #>
$MiConexion = Connect-DbaInstance -SqlInstance LOCALHOST -TrustServerCertificate
Get-DbaDatabase -SqlInstance $MiConexion -Database lcf

#3.a.III. BORRAR UNA BASE DE DATOS

#En caso de ser necesario volvemos a crear las variables con el nombre de la instancia y el servidor
$InstanceName = "localhost"
$Server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $InstanceName

#Asignamos el nombre de la base de datos a la variable $dbName
$dbName = "lcf"

<#Creamos una estructura condicional en la que si en el servidor existe una base de datos con el nombre de “lcf”, la borra. 
Utilizamos KillDatabase en lugar de DropDatabase para que no dé error por si está activa en el momento de ejecutar el comando #>
$db = $Server.Databases[$dbName]
if ($db)
{
      $Server.KillDatabase($dbName)
}

#Comprobamos que se haya borrado
$Server.Databases | Select Name, Status, Owner, CreateDate

#3.b. LIBRERÍAS ADO.NET

#3.b.I. CREAR UNA BASE DE DATOS

#Creamos una variable con el nombre de la base de datos
$dbname = "lcf";

#Creamos la conexión y la abrimos
$con = New-Object Data.SqlClient.SqlConnection;
$con.ConnectionString = "Data Source=.;Initial Catalog=master;Integrated Security=True;";
$con.Open();

#Almacenamos una sentencia de SELECT en la variable $sql para comprobar la existencia de la base de datos "lcf"
$sql = "SELECT name
    FROM sys.databases
    WHERE name = '$dbname';";

<# Creamos un nuevo comando para lanzar el SELECT ($sql) contra la conexión creada ($con). Luego ejecutamos la consulta 
mediante ExecuteReader() y guardamos el resultado en $rd. Con la estructura condicional if ($rd.Read()) comprobamos 
si la consulta devuelve algún resultado. Si la base de datos existe, se muestra un mensaje indicando que ya existe y el 
programa finaliza; en caso contrario, no entra en el if y el programa continúa #>
$cmd = New-Object Data.SqlClient.SqlCommand $sql, $con;
$rd = $cmd.ExecuteReader();
if ($rd.Read())
{
    Write-Host "La base de datos $dbname ya existe";
    Return;
}
$rd.Close();
$rd.Dispose();

<# Creamos la base de datos, y lo primero que hacemos es cambiar el valor almacenado de la variable con la que hicimos el SELECT, 
cambiándolo por un CREATE DATABASE. Luego lo ejecutamos y con Write-Host hacemos que nos devuelva un mensaje de que la base de 
datos está creada #>
$sql = "CREATE DATABASE [$dbname];" 
$cmd = New-Object Data.SqlClient.SqlCommand $sql, $con;
$cmd.ExecuteNonQuery();
Write-Host "¡La base de datos $dbname se ha creado!";

#Cerramos y liberamos memoria
$cmd.Dispose();
$con.Close();
$con.Dispose();

#3.b.II. CREAR UNA TABLA EN UNA BASE DE DATOS

#Primero creamos las variables que almacenarán los nombres del servidor, la base de datos y la conexión
$Server = "localhost"
$Database = "lcf"
$ConnectionString = "Server=$Server;Database=$Database;Integrated Security=True;"

#Creamos la conexión
$SqlConn = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)

#Creamos el comando SQL para crear la tabla
$CreateTableQuery = "CREATE TABLE PACIENTE (Nombre VARCHAR(50), Primer_Apellido VARCHAR(50), Segundo_Apellido VARCHAR(50), Fecha_Nacimiento DATE, Sexo VARCHAR(15), Numero_Telefono VARCHAR(15)"

#Abrimos la conexión
$SqlConn.Open()

#Creamos el comando SQL y le añadimos la instrucción para crear la tabla PACIENTE
$SqlCmd = $SqlConn.CreateCommand()
$SqlCmd.CommandText = $CreateTableQuery

#Ejecutamos el objeto que contiene la instrucción
$SqlCmd.ExecuteNonQuery()

#Añadimos un mensaje de confirmación
Write-Host "La tabla "PACIENTE" se ha creado exitosamente en la base de datos "$Database"."

#Cerramos la conexión
$SqlConn.Close()

#3.b.III. MOSTRAR DATOS DE UNA TABLA

#En primer lugar definimos la cadena de conexión
$ConnectionString = "Server=localhost;Database=lcf;Integrated Security=True;"

#Creamos la conexión a la base de datos
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)

#Creamos una consulta de SELECT para poder ver el contenido de la tabla
$Query = "SELECT * FROM PACIENTE;"

#Creamos el comando SQL que une la consulta SELECT y la conexión
$sqlCommand = New-Object System.Data.SqlClient.SqlCommand($Query, $sqlConnection)

#Abrimos la conexión
$sqlConnection.Open()

#Ejecutamos la consulta SELECT
$sqlReader = $sqlCommand.ExecuteReader()

<# Mostramos los resultados en pantalla con un while. Funciona de la siguiente manera: $sqlReader es un lector de datos (DataReader),
y .Read() sirve para avanzar a la siguiente fila. Devuelve True si hay datos, y False cuando ya no quedan filas. Es decir, que mientras 
haya otra fila en los resultados, sigue ejecutando el código #>
while ($sqlReader.Read()) {
    #Creamos la variable $Fila, la cual inicializa una cadena vacía y va acumulando los valores de todas las columnas
    $Fila = "" 
    #Creamos un bucle con for para recorrer todas las columnas
    for ($i = 0; $i -lt $sqlReader.FieldCount; $i++) { 
        #$sqlReader.GetValue($i) obtiene el valor de la columna en posición $i 
        $Fila += "$($sqlReader.GetValue($i)) " 
    }
    #Imprime en consola y .Trim elimina espacios al inicio y final
    Write-Host $Fila.Trim() 
}

#Cerramos el lector y la conexión
$sqlReader.Close()
$sqlConnection.Close()

#3.b.IV. BORRAR UNA BASE DE DATOS

#Creamos la instancia y la conexión
$connectionString = "server=localhost;database=master;integrated security=true"
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection($connectionString)

#Creamos el comando para borrar la base de datos (además de DROP añadimos un ALTER para cerrar conexiones activas y evitar errores)
$sqlCommand = New-Object System.Data.SqlClient.SqlCommand("ALTER DATABASE lcf SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE lcf", $sqlConnection)

#Abrimos la conexión
$sqlConnection.Open()

<#Creamos la variable $Confirm. Con ella preguntamos si se desea borrar la base de datos, y se guarda la respuesta del usuario 
(S para sí y N para no) #>
$Confirm = Read-Host "¿Deseas borrar la base de datos? (S/N):"

<# Creamos una condición con if en la que si el valor de $Confirm es S, se ejecuta el comando (ALTER y DROP DATABASE) y aparece el 
mensaje de que la base de datos ha sido borrada. En cambio, si el valor de $Confirm es N, no ocurre nada #>
if ($Confirm -eq "S") {
  $sqlCommand.ExecuteNonQuery()
  Write-Host "La base de datos lcf ha sido borrada."
}

#Cerramos la conexión
$sqlConnection.Close()