--Usamos la base de datos Laboratorio_Analisis_Clinicos
USE Laboratorio_Analisis_Clinicos;
GO

--Creamos un nuevo esquema llamado "Esquema"
DROP SCHEMA IF EXISTS Esquema
GO
CREATE SCHEMA Esquema;
GO 

--Creamos la tabla de paciente dentro del esquema "Esquema" con sus correspondientes columnas
DROP TABLE IF EXISTS Esquema.PACIENTE
GO
CREATE TABLE Esquema.PACIENTE
(
    ID_Paciente INTEGER NOT NULL , 
    DNI VARCHAR (20) , 
    Nombre VARCHAR (50) , 
    Primer_Apellido VARCHAR (80) , 
    Segundo_Apellido VARCHAR (80) , 
    Fecha_Nacimiento DATE , 
    Sexo VARCHAR (20) , 
    Grupo_Sanguineo VARCHAR (20) , 
    Numero_Telefono VARCHAR (20) , 
    Direccion VARCHAR (100) , 
    Correo_Electronico VARCHAR (80)
);
GO 

--SELECT nos muestra el esquema con la tabla creada con los datos del archivo Pacientes.txt (el cual añadimos previamente desde "Tasks" > "Export Data")
SELECT * FROM Esquema.PACIENTE
GO   
     
--Ahora creamos una vista sobre el esquema Esquema.PACIENTE. En esta vista sólo estarán disponibles algunas de las columnas, 
--ya que el objetivo es manejar los permisos de los roles y los usuarios. Para ello haremos que los usuarios dentro del rol de "Analista" 
--puedan consultar sólo algunos de los datos de los pacientes, excluyendo información personal como DNI, dirección, etc.
DROP VIEW IF EXISTS Esquema.VistaPACIENTE
GO
CREATE VIEW Esquema.VistaPACIENTE
AS
SELECT 
   Nombre, Primer_Apellido, Segundo_Apellido, Fecha_Nacimiento, Sexo, Grupo_Sanguineo
FROM Esquema.PACIENTE;
GO

--Creamos rol de "Analista"
DROP ROLE IF EXISTS Analista
GO
CREATE ROLE Analista;
GO 

--Le damos permisos sobre la vista al rol de "Analista"
GRANT SELECT ON Esquema.VistaPACIENTE TO Analista;
GO 

--Creamos un usuario llamado "PaulaRobles" y lo añadimos al rol de "Analista"
DROP USER IF EXISTS PaulaRobles
GO
CREATE USER PaulaRobles WITHOUT LOGIN;
GO 
ALTER ROLE Analista
ADD MEMBER PaulaRobles;
GO 

--Ahora probaremos los permisos con el usuario "PaulaRobles"
EXECUTE AS USER = 'PaulaRobles';
GO 
--Al utilizar este SELECT sólo podremos ver los campos Nombre, Primer_Apellido, Segundo_Apellido, Fecha_Nacimiento, Sexo y Grupo_Sanguineo
--Esto se debe a que este rol sólo tiene permisos sobre la vista, no sobre la tabla entera
SELECT * FROM Esquema.VistaPACIENTE;
GO 

--Para comprobar que somos "PaulaRobles"
PRINT USER
GO

--Para volver a "dbo"
REVERT;
GO 
PRINT USER
GO

--Ahora probamos que los usuarios del rol de "Analista" no tienen permisos sobre la tabla de Esquema.PACIENTE
--El siguiente SELECT no funcionará porque sólo le hemos dado permisos sobre la vista, no directamente sobre la tabla del esquema
EXECUTE AS USER = 'PaulaRobles';
GO 
SELECT * FROM Esquema.PACIENTE;
GO 
--Falla: The SELECT permission was denied on the object 'PACIENTE', database 'Laboratorio_Analisis_Clinicos', schema 'Esquema'.

--Volvemos a ponernos como "dbo"
PRINT USER
GO
REVERT;
GO
PRINT USER
GO

--Ahora vamos a crear un procedimiento almacenado para insertar valores en la tabla Esquema.PACIENTE
CREATE OR ALTER PROC Esquema.InsertarNuevoPaciente

   @ID_Paciente INTEGER,
   @DNI VARCHAR(20),
   @Nombre VARCHAR(50),
   @Primer_Apellido VARCHAR(80),
   @Segundo_Apellido VARCHAR(80),
   @Fecha_Nacimiento DATE,
   @Sexo VARCHAR(20),
   @Grupo_Sanguineo VARCHAR(20),
   @Numero_Telefono VARCHAR(20),
   @Direccion VARCHAR(100),
   @Correo_Electronico VARCHAR(80)
AS
BEGIN
   INSERT INTO Esquema.PACIENTE
   ( ID_Paciente, DNI, Nombre, Primer_Apellido, Segundo_Apellido, Fecha_Nacimiento, Sexo, Grupo_Sanguineo, Numero_Telefono, Direccion, Correo_Electronico )
   VALUES
   ( @ID_Paciente, @DNI, @Nombre, @Primer_Apellido, @Segundo_Apellido, @Fecha_Nacimiento, @Sexo, @Grupo_Sanguineo, @Numero_Telefono, @Direccion, @Correo_Electronico );
END;
GO 

--Vamos a crear el rol de "Administrativo", el cual podrá insertar nuevos pacientes mediante el procedimiento almacenado
DROP ROLE IF EXISTS Administrativo
GO
CREATE ROLE Administrativo;
GO 
GRANT EXECUTE ON SCHEMA::[Esquema] TO Administrativo;
GO 

--Creamos otro usuario llamado "AnaMarras" que estará dentro del rol "Administrativo"
DROP USER IF EXISTS AnaMarras
GO
CREATE USER AnaMarras WITHOUT LOGIN;
GO 
ALTER ROLE Administrativo
ADD MEMBER AnaMarras;
GO

--Nos impersonamos como "AnaMarras" e intentamos insertar datos en la tabla Esquema.PACIENTE, pero falla porque no tiene permisos para ello
EXECUTE AS USER = 'AnaMarras';
GO 
INSERT INTO Esquema.PACIENTE
   ( ID_Paciente, DNI, Nombre, Primer_Apellido, Segundo_Apellido, Fecha_Nacimiento, Sexo, Grupo_Sanguineo, Numero_Telefono, Direccion, Correo_Electronico )
   VALUES
   (7,'44556677A','Ana','Santos','Moreno','1990-02-10','Femenino','A+','600111222','Calle Larga 5','ana@example.com');
GO 
--Falla: The INSERT permission was denied on the object 'PACIENTE', database 'Laboratorio_Analisis_Clinicos', schema 'Esquema'.

--Volvemos a "dbo"
REVERT;
GO

--Ahora probamos a usar el procedimiento almacenado que creamos antes con el usuario "AnaMarras"
EXECUTE AS USER = 'AnaMarras';
GO 
EXEC Esquema.InsertarNuevoPaciente
   @ID_Paciente = 7,
   @DNI = '44556677A',
   @Nombre = 'Ana',
   @Primer_Apellido = 'Santos',
   @Segundo_Apellido = 'Moreno',
   @Fecha_Nacimiento = '1990-02-10',
   @Sexo = 'Femenino',
   @Grupo_Sanguineo = 'A+',
   @Numero_Telefono = '600111222',
   @Direccion = 'Calle Larga 5',
   @Correo_Electronico = 'ana@example.com';
GO 
--(1 row affected)

--Confirmamos que estamos con el usuario "AnaMarras"
PRINT user
GO
--AnaMarras

--Volvemos a "dbo"
REVERT;
GO
PRINT USER
GO

--Finalmente comprobamos que haya funcionado la inserción de información con el procedimiento almacenado
SELECT ID_Paciente, DNI, Nombre, Primer_Apellido, Segundo_Apellido, Fecha_Nacimiento, Sexo, Grupo_Sanguineo, Numero_Telefono, Direccion, Correo_Electronico 
FROM Esquema.PACIENTE;
GO