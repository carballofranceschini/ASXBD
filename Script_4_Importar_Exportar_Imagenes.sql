--Utilizamos la base de datos de Laboratorio_Analisis_Clinicos
USE Laboratorio_Analisis_Clinicos
GO

--En caso de no haber datos, cargamos datos en la tabla de EMPLEADO_LABORATORIO, que es en la que posteriormente importaremos y 
--exportaremos imágenes para identificar a cada empleado
INSERT INTO EMPLEADO_LABORATORIO 
    (ID_Empleado, Nombre, Primer_Apellido, Segundo_Apellido, DNI, Dirección, Número_Teléfono, Fecha_Contratación, Salario, Foto_Empleado)
VALUES
    (1, 'Maria', 'Perez', 'Sanchez', '87654321Y', 'Calle Secundaria 45', '698765432', '2025-02-10', 16.00, NULL),
    (2, 'Juan', 'Martinez', 'Gomez', '11223344Z', 'Avenida Central 78', '677889900', '2025-03-05', 15.00, NULL),
    (3, 'Lucia', 'Ramirez', 'Tui', '99887766X', 'Plaza Mayor 3', '633221144', '2025-04-01', 17, NULL);

--Activamos los siguientes procedimientos almacenados
EXEC sp_configure 'show advanced options', 1; --Para activar opciones avanzadas
GO 
RECONFIGURE; --Para aplicar lo anterior
GO 
EXEC sp_configure 'Ole Automation Procedures', 1; --Activamos las Ole Automation Procedures
GO 
RECONFIGURE; --Para aplicar lo anterior
GO

--A continuación utilizamos el login de nuestro usuario "ASXBD_LCF\maqui" y lo añadimos al rol "bulkadmin"
ALTER SERVER ROLE [bulkadmin] ADD MEMBER [ASXBD_LCF\maqui] 
GO

USE Laboratorio_Analisis_Clinicos
GO

--Creamos un procedimiento almacenado para guardar una imagen en un empleado ya existente:
CREATE OR ALTER PROCEDURE dbo.usp_ImportarImagen (
     @ID_Empleado INT --Declaramos los parámetros de entrada
   , @RutaImagen NVARCHAR (1000)
   , @NombreImagen NVARCHAR (1000)
   )
AS
BEGIN 
   DECLARE @RutaCompletaDeEntrada NVARCHAR (2000); --Declaramos las variables
   DECLARE @tsql NVARCHAR (max);
   SET NOCOUNT ON --Lo usamos para que no muestre el mensaje de filas
   SET @RutaCompletaDeEntrada = CONCAT ( --Creamos la ruta completa
         @RutaImagen
         ,'\'
         , @NombreImagen
         );
-- En este caso UPDATE actualiza la imagen de un empleado agregado anteriormente
   SET @tsql = 'UPDATE EMPLEADO_LABORATORIO
        SET Foto_Empleado = BulkColumn
        FROM Openrowset(Bulk ''' + @RutaCompletaDeEntrada + ''', Single_Blob) AS img
        WHERE ID_Empleado = ' + CAST(@ID_Empleado AS NVARCHAR(20)) + '; 
    '; --Utilizamos cast para convertir un valor entero en un texto

   EXEC (@tsql) --Openrowset necesita utilizar una consulta en formato string
   SET NOCOUNT OFF --Desactivamos NOCOUNT
END
GO

--Ahora creamos el procedimiento almacenado para exportar imágenes
CREATE OR ALTER PROCEDURE dbo.usp_ExportarImagen (
    @ID_Empleado INT --Declaramos parámetros de entrada
   ,@RutaDestino NVARCHAR(1000)
   ,@NombreArchivo NVARCHAR(1000)
   )
AS
BEGIN
   DECLARE @DatosImagen VARBINARY (max); --Declaramos las variables
   DECLARE @RutaCompletaSalida NVARCHAR (2000);
   DECLARE @Obj INT
 
   SET NOCOUNT ON --Volvemos a utilizar NOCOUNT para que no muestre el mensaje de filas
 
   SELECT @DatosImagen = ( --Declaramos que la variable @DatosImagen almacena el binario de la imagen
         SELECT convert (VARBINARY (max), Foto_Empleado, 1)
         FROM EMPLEADO_LABORATORIO
         WHERE ID_Empleado = @ID_Empleado
         );
 
   SET @RutaCompletaSalida = CONCAT ( --Declaramos que la variable @RutaCompletaSalida contendrá el valor entero de la ruta
         @RutaDestino
         ,'\'
         , @NombreArchivo
         );
    BEGIN TRY --Comandos que ejecutamos
     EXEC sp_OACreate 'ADODB.Stream' ,@Obj OUTPUT; --Crea el stream (flujo de datos)
     EXEC sp_OASetProperty @Obj ,'Type',1; --Especificamos el tipo de dato en el stream, en este caso binario
     EXEC sp_OAMethod @Obj,'Open'; --Abrimos el stream
     EXEC sp_OAMethod @Obj,'Write', NULL, @DatosImagen; --Escribe en el stream el contenido del archivo
     EXEC sp_OAMethod @Obj,'SaveToFile', NULL, @RutaCompletaSalida, 2; --Guarda el contenido del stream en la ruta especificada
     EXEC sp_OAMethod @Obj,'Close'; --Cierra el stream
     EXEC sp_OADestroy @Obj; --Destruye el stream
    END TRY
    
 BEGIN CATCH --El CATCH sólo se ejecuta si hay algún error en el TRY
  EXEC sp_OADestroy @Obj; --Trata de destruir el stream, y como va a dar error en caso de ejecutarse, aparece el mensaje de error
 END CATCH
 
   SET NOCOUNT OFF --Desactivamos NOCOUNT
END
GO

--Después de haber creado los procedimientos comprobamos el estado de la tabla EMPLEADO_LABORATORIO con SELECT
SELECT * FROM EMPLEADO_LABORATORIO
GO

--Probamos el procedimiento para importar imágenes
exec dbo.usp_ImportarImagen '1','C:\IMAGENES_SCRIPT_4\ENTRADA','Empleado1.avif' 
GO

--Comprobamos que el empleado con ID 1 tenga su foto
SELECT * FROM EMPLEADO_LABORATORIO
GO

--Ahora probamos el procedimiento para exportar imágenes
exec dbo.usp_ExportarImagen '1','C:\IMAGENES_SCRIPT_4\SALIDA','Empleado1.avif'
GO

--Procedimiento almacenado que nos permite lanzar comandos del sistema operativo desde SQL (por defecto viene desactivado)
EXEC sp_configure 'xp_cmdshell', 1; 
GO 
RECONFIGURE; 
GO

--Con la siguiente línea ejecutamos el comando "dir C:\Rutadelacarpeta", que nos permite listar archivos de la carpeta en cuestión
xp_cmdshell "dir C:\IMAGENES_SCRIPT_4\SALIDA" 
go

--Deshabilitamos "xp_cmdshell"
EXEC sp_configure 'xp_cmdshell', 0; 
GO 
RECONFIGURE; 
GO