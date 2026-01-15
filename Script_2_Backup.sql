--Usamos la tabla de sistema "master"
USE master
GO

--Eliminamos si ya existe el procedimiento almacenado llamado "PROCEDIMIENTO_BACKUP"
DROP PROCEDURE IF EXISTS PROCEDIMIENTO_BACKUP
GO

--Si ya existe eliminamos la tabla temporal del sistema llamada "tablaTemporal"
DROP TABLE IF EXISTS [dbo].#tablaTemporal
GO

--Creamos o modificamos el procedimiento almacenado llamado "PROCEDIMIENTO_BACKUP"
CREATE OR ALTER PROC PROCEDIMIENTO_BACKUP
	@carpeta VARCHAR(256) --Parámetro de entrada para el procedimiento; será la ruta de la carpeta donde se guardará el backup
AS
--Con DECLARE creamos las variables
DECLARE @nombrebasededatos VARCHAR(50), --Nombre de la base de datos
@nombreArchivo VARCHAR(256), --Nombre que tendrá el archivo .bak
@fechaArchivo VARCHAR(20), --Fecha del archivo
@numeroBackups INT --Número de backups

--Creamos una tabla temporal llamada "tablaTemporal" con dos columnas, una con un id autoincremental (que empieza por 1 e irá 
--incrementando su valor de 1 en 1 por cada fila), y otra columna en la que irán los nombre de los backups
CREATE TABLE [dbo].#tablaTemporal 
	(id INT IDENTITY (1, 1), 
	name VARCHAR(200))

--Con SET le asignamos valor a la variable @fechaArchivo. En concreto obtenemos la fecha con GETDATE, con CONVERT la pasamos a
--VARCHAR, y con 112 indicamos que la fecha estará en formato añomesdía
SET @fechaArchivo = CONVERT(VARCHAR(20), GETDATE(), 112)

--Insertamos información en la tabla temporal, en concreto en la columna a la que llamamos "name", y especificamos que queremos añadir
--al listado la base de datos de "Laboratorio_Analisis_Clinicos" (nombre que sacamos de la tabla de sistema sysdatabases)
INSERT INTO [dbo].#tablaTemporal (name)
	SELECT name
	FROM master.dbo.sysdatabases
	WHERE name in ('Laboratorio_Analisis_Clinicos')

--Obtenemos la primera fila después de ordenar los registros por id de manera descendente. Esa primera fila tendrá el id más alto, 
--y ese valor se guarda en la variable @numeroBackups
SELECT TOP 1 @numeroBackups = id 
FROM [dbo].#tablaTemporal 
ORDER BY id DESC

--Creamos un bucle para ir iterando en la lista de bases de datos y poder realizar su backup
IF ((@numeroBackups IS NOT NULL) AND (@numeroBackups > 0)) --Comprobamos que la variable @numeroBackups no es nulo y es mayor que 0 (es decir, hay bbdd para hacer backups)
BEGIN
	DECLARE @backupactual INT --Declaramos la variable @backupactual, que usaremos como contador
	SET @backupactual  = 1 --Asignamos el valor inicial
	WHILE (@backupactual <= @numeroBackups) --Mientras que se cumpla condición, se ejecuta el bucle
		BEGIN
			SELECT
				@nombrebasededatos = name, --Guardamos en la variable el nombre de la base de datos de la iteración
				@nombreArchivo = @carpeta + name + '_' + @fechaArchivo + '.BAK' --Ruta + nombre del archivo de backup
				FROM [dbo].#tablaTemporal --De la tabla temporal, que es donde tenemos almacenadas las bases de datos (en este caso sólo la de "Laboratorio_Analisis_Clinicos")
				WHERE id = @backupactual --Cuyo id coincide con el contador
				BACKUP DATABASE @nombrebasededatos TO DISK = @nombreArchivo --Ejecución del backup con el nombre de la base de datos para que se almacene en el directorio @nombreArchivo
				SET @backupactual  = @backupactual  + 1 --Siguiente iteración con el contador +1
		END
END

--Comprobamos la tabla temporal y la borramos
SELECT * FROM [dbo].#tablaTemporal

DROP TABLE [dbo].#tablaTemporal
GO

--Ejecutamos el procedimiento almacenado y especificamos la ruta de la carpeta donde se guardará el backup
EXEC PROCEDIMIENTO_BACKUP 'C:\BACKUP SCRIPT 2\'
GO

--Para finalizar generamos clones. El primero sólo clona la estructura de la base de datos
USE Laboratorio_Analisis_Clinicos
DBCC CLONEDATABASE (Laboratorio_Analisis_Clinicos, Laboratorio_Analisis_Clinicos_Clone);
GO
--Database cloning for 'Laboratorio_Analisis_Clinicos' has started with target as 'Laboratorio_Analisis_Clinicos_Clone'.
--Database cloning for 'Laboratorio_Analisis_Clinicos' has finished. Cloned database is 'Laboratorio_Analisis_Clinicos_Clone'.
--Database 'Laboratorio_Analisis_Clinicos_Clone' is a cloned database. This database should be used for diagnostic purposes only and is not supported for use in a production environment.
--DBCC execution completed. If DBCC printed error messages, contact your system administrator.

--Completion time: 2025-11-22T21:48:29.1513327+01:00

--Para eliminar el clon de la base de datos utilizo las dos primeras líneas y luego elimino con DROP, ya que sino me daba error
ALTER DATABASE [Laboratorio_Analisis_Clinicos_Clone] 
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE IF EXISTS Laboratorio_Analisis_Clinicos_Clone;

--Con la siguiente línea también creamos un clon de la base de datos, pero en este caso se crea automáticamente un backup de dicho clon, 
--el cual se guarda (en mi caso) en C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\
DBCC CLONEDATABASE (Laboratorio_Analisis_Clinicos,Laboratorio_Analisis_Clinicos_Clone) WITH VERIFY_CLONEDB, BACKUP_CLONEDB;    
GO

--Para eliminar este último clon
ALTER DATABASE [Laboratorio_Analisis_Clinicos_Clone] 
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE IF EXISTS Laboratorio_Analisis_Clinicos_Clone;