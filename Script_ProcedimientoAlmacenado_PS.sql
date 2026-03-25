USE Laboratorio_Analisis_Clinicos
GO

CREATE PROCEDURE Datos_Paciente --Creamos un procedimiento almacenado con el nombre de 
--"Datos_Paciente"
	@ID_Paciente INT --Añadimos un parámetro de entrada de tipo integer, 
	--el cual será el número ID del paciente del que queramos obtener los datos
AS --Indicamos el inicio de la definición del procedimiento, es decir, cómo va a funcionar
BEGIN --Define el bloque de instrucciones que se ejecutarán, termina en el "END"
    SELECT --Consulta de los campos que nos interesan de la tabla PACIENTE
        ID_Paciente,
        Nombre,
        Primer_Apellido,
        Segundo_Apellido,
        Fecha_Nacimiento,
        Sexo,
        DNI,
        Número_Teléfono,
        Dirección
    FROM PACIENTE --Indicamos la tabla de la que se consultarán los datos
    WHERE ID_Paciente = @ID_Paciente; --Asociamos la variable @ID_Paciente al campo ID_Paciente, 
	--para que los datos que nos devuelva el procedimiento almacenado sean los del paciente deseado
END --Fin del procedimiento almacenado
GO

--Utilizamos el procedimiento almacenado para consultar los datos del paciente con ID_Paciente 2
EXEC Datos_Paciente @ID_Paciente = 2
GO
