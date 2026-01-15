--Seleccionamos la base de datos "Laboratorio_Analisis_Clinicos"
USE Laboratorio_Analisis_Clinicos
GO

--Insertamos nuevos registros a la tabla EMPLEADO_LABORATORIO
INSERT INTO EMPLEADO_LABORATORIO 
    (ID_Empleado, Nombre, Primer_Apellido, Segundo_Apellido, DNI, Dirección, Número_Teléfono, Fecha_Contratación, Salario, Foto_Empleado)
VALUES
    (1, 'Juan', 'Perez', 'Sanchez', '87654321Y', 'Calle Secundaria 45', '698765432', '2025-02-10', 1600.00, NULL),
    (2, 'Lucia', 'Martinez', 'Gomez', '11223344Z', 'Avenida Central 78', '677889900', '2025-03-05', 1500.00, NULL),
    (3, 'Carlos', 'Ramirez', 'Tui', '99887766X', 'Plaza Mayor 3', '633221144', '2025-04-01', 1700.00, NULL);

--Vamos a configurar un cursor que nos muestre los datos de cada trabajador para saber el salario de cada uno
--El cursor se llama "SalarioEmpleado_Cursor". Lo declaramos y con SELECT elegimos los atributos que queremos que se muestren
DECLARE SalarioEmpleado_Cursor CURSOR FOR  
	SELECT Nombre, Primer_Apellido, Segundo_Apellido, Salario 
	FROM EMPLEADO_LABORATORIO; 

OPEN SalarioEmpleado_Cursor; --Activamos el cursor y lo posicionamos antes del primer registro  
FETCH NEXT FROM SalarioEmpleado_Cursor; --Mueve el cursor a la siguiente fila (o la primera si es la primera vez) y devuelve los datos 
WHILE @@FETCH_STATUS = 0 --Sigue iterando mientras haya filas disponibles
   BEGIN  
	   FETCH NEXT FROM SalarioEmpleado_Cursor --Avanzamos al siguiente registro
   END;
CLOSE SalarioEmpleado_Cursor; --Cerramos el cursor  
DEALLOCATE SalarioEmpleado_Cursor; --Liberamos memoria  
GO

--Ahora crearemos un cursor para los backups
--Empezamos seleccionando la base de datos de sistema "master"
USE master
GO

--Declaramos las variables
DECLARE @nombrebasededatos VARCHAR(50) --Nombre de la base de datos 
DECLARE @ruta VARCHAR(256) --Ruta de la carpeta donde se guardarán los backups
DECLARE @nombreArchivo VARCHAR(256) --Ruta completa y nombre del archivo
DECLARE @fechaArchivo VARCHAR(20) --Fecha en formato añomesdía que se incluirá en el nombre del backup

--Definimos la ruta del backup
SET @ruta = 'C:\BACKUP SCRIPT 2\CURSORES BACKUP\' 

--Obtenemos la fecha en formato añomesdía
SELECT @fechaArchivo = CONVERT(VARCHAR(20),GETDATE(),112) 

--Declaramos un cursor llamado "cursor_backup" que recorrerá los nombres de todas las bases de datos excluyendo las que no tengan el 
--nombre de "Laboratorio_Analisis_Clinicos". Esto lo hacemos desde sysdatabases porque contiene la lista de todas las bases del servidor
DECLARE cursor_backup CURSOR FOR 
SELECT name 
FROM MASTER.dbo.sysdatabases 
WHERE name in ('Laboratorio_Analisis_Clinicos') 

OPEN cursor_backup --Activamos el cursor y lo posicionamos antes de la primera fila
FETCH NEXT FROM cursor_backup INTO @nombrebasededatos --Obtenemos el primer nombre de las bases de datos y lo guardamos en @nombrebasededatos

WHILE @@FETCH_STATUS = 0 --El bucle va a iterar sobre todas las bases de datos que no sean 'master','model','msdb' o 'tempdb' 
BEGIN  
      SET @nombreArchivo = @ruta + @nombrebasededatos + '_' + @fechaArchivo + '.BAK' --Crea el nombre del archivo backup
      BACKUP DATABASE @nombrebasededatos TO DISK = @nombreArchivo --Ejecuta el backup de la base de datos

      FETCH NEXT FROM cursor_backup INTO @nombrebasededatos --Avanza a la siguiente base de datos
END 

CLOSE cursor_backup --Cerramos el cursor 
DEALLOCATE cursor_backup --Liberamos memoria
--En este caso sólo ha hecko backup de Laboratorio_Analisis_Clinicos porque es lo que hemos especificado
--Laboratorio_Analisis_Clinicos_20251123.BAK

--Para finalizar vamos a crear un recorrido para mostrar las direcciones de los empleados
USE Laboratorio_Analisis_Clinicos
GO

DECLARE @Objeto_ID varchar(60)  --Creamos la variable que contiene el id de cada fila
DECLARE Objeto_cursor CURSOR  --Declaramos el cursor
FOR SELECT CAST(ID_Empleado AS NVARCHAR(20)) FROM EMPLEADO_LABORATORIO; --Hacemos un casteo del tipo int a string
 
OPEN Objeto_cursor --Abrimos el cursor
 
FETCH NEXT FROM Objeto_cursor INTO @Objeto_ID --Primer resultado
 
WHILE @@FETCH_STATUS = 0 --Iteramos
BEGIN
 
SELECT Dirección --Lanzamos la consulta que saca la dirección
FROM EMPLEADO_LABORATORIO
WHERE ID_Empleado = @Objeto_ID --Le decimos que el ID tiene que ser el mismo que el ID del bucle
 
FETCH NEXT FROM Objeto_cursor INTO @Objeto_ID --Avanza a la siguiente fila

END

CLOSE Objeto_cursor --Cerramos el cursor
DEALLOCATE Objeto_cursor --Liberamos memoria