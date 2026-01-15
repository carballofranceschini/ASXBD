USE Laboratorio_Analisis_Clinicos;
GO

--Primero vamos a rellenar nuestra base de datos con algunos datos para no tener problemas con las FK

--1 EMPLEADO_LABORATORIO
INSERT INTO EMPLEADO_LABORATORIO (ID_Empleado, Nombre, Primer_Apellido, Segundo_Apellido, DNI, Dirección, Número_Teléfono, Fecha_Contratación, Salario, Foto_Empleado)
VALUES
(1,'Maria','Garcia','Lopez','12345678X','Calle Mayor 12','612345678','2025-01-15',1500.00,NULL),
(2,'Juan','Perez','Sanchez','87654321Y','Calle Secundaria 45','698765432','2025-02-10',1600.00,NULL),
(3,'Lucia','Martinez','Gomez','11223344Z','Avenida Central 78','677889900','2025-03-05',1550.00,NULL),
(4,'Carlos','Ramirez','Tui','99887766X','Plaza Mayor 3','633221144','2025-04-01',1700.00,NULL),
(5,'Sofia','Hernandez','Ruiz','33445566A','Calle Verde 12','600112233','2025-03-15',1600.00,NULL),
(6,'Miguel','Torres','Lopez','55667788B','Avenida Azul 7','600223344','2025-03-20',1650.00,NULL);
GO

--2 ADMINISTRATIVO
INSERT INTO ADMINISTRATIVO (ID_Empleado, Departamento)
VALUES
(1,'Recepcion'),
(2,'Facturacion');
GO

--3 ANALISTA
INSERT INTO ANALISTA (ID_Empleado, Especialidad)
VALUES
(5,'Bioquimica'),
(6,'Microbiologia');
GO

--4 MÉDICO
INSERT INTO MÉDICO (ID_Empleado, Número_Colegiado)
VALUES
(3,'MED12345'),
(4,'MED67890');
GO

--5 PACIENTE
INSERT INTO PACIENTE (ID_Paciente, DNI, Nombre, Primer_Apellido, Segundo_Apellido, Fecha_Nacimiento, Sexo, Grupo_Sanguíneo, Número_Teléfono, Dirección, Correo_Electrónico)
VALUES
(1,'44556677A','Ana','Santos','Moreno','1990-02-10','Femenino','A+','600111222','Calle Larga 5','ana@example.com'),
(2,'22334455B','Pedro','Gomez','Ruiz','1985-07-23','Masculino','B-','600333444','Avenida Norte 12','pedro@example.com');
GO

--6 PROVEEDOR
INSERT INTO PROVEEDOR (ID_Proveedor, Nombre, Dirección, Número_Teléfono, Correo_Electrónico)
VALUES
(1,'Proveedor A','Calle Azul 10','611223344','proveedorA@example.com'),
(2,'Proveedor B','Avenida Roja 5','622334455','proveedorB@example.com');
GO

--7 REACTIVO
INSERT INTO REACTIVO (ID_Reactivo, Nombre, Tipo, Marca, Fecha_Caducidad, Cantidad)
VALUES
(1,'Reactivo A','Quimico','Sigma','2026-01-01',50),
(2,'Reactivo B','Biologico','Merck','2025-12-31',30);
GO

--8 SUMINISTRA (Proveedor-Reactivo)
INSERT INTO SUMINISTRA (PROVEEDOR_ID_Proveedor, REACTIVO_ID_Reactivo)
VALUES
(1,1),
(2,2);
GO

--9 MÉDICO_EXTERNO
INSERT INTO MÉDICO_EXTERNO (ID_Médico_Externo, Número_Colegiado, Nombre, Primer_Apellido, Segundo_Apellido, Centro_Médico, Especialidad, Correo_Electrónico, Número_Teléfono)
VALUES
(1,'EXT001','Laura','Vega','Martin','Hospital Central','Cardiologia','laura@hospital.com','600555666'),
(2,'EXT002','Fernando','Lopez','Sanchez','Clinica Norte','Dermatologia','fernando@clinica.com','600777888');
GO

--10 FACTURA
INSERT INTO FACTURA (ID_Factura, Importe, Fecha_Emisión, Estado_Pago, PACIENTE_ID_Paciente)
VALUES
(1,200.50,'2025-04-01','Pagada',1),
(2,150.75,'2025-04-02','Pendiente',2);
GO

--11 SOLICITUD_ANÁLISIS
INSERT INTO SOLICITUD_ANÁLISIS (ID_Solicitud_Análisis, Fecha_Solicitud, Estado, Tipo, Observaciones, MÉDICO_EXTERNO_ID_Médico_Externo, PACIENTE_ID_Paciente, FACTURA_ID_Factura)
VALUES
(1,'2025-04-03','Pendiente','Sangre','Chequeo anual',1,1,1),
(2,'2025-04-04','Completada','Orina','Control medico',2,2,2);
GO

--12 SECCIÓN_LABORATORIO
INSERT INTO SECCIÓN_LABORATORIO (ID_Sección, Nombre_Sección)
VALUES
(1,'Hematologia'),
(2,'Bioquimica');
GO

--13 TEST_ANÁLISIS
INSERT INTO TEST_ANÁLISIS (ID_Test, Nombre, Descripción, Tipo, Precio, Duración_Estimada, SOLICITUD_ANÁLISIS_ID_Solicitud_Análisis, SECCIÓN_LABORATORIO_ID_Sección)
VALUES
(1,'Hemograma','Analisis completo de sangre','Sangre',50.00,'30 min',1,1),
(2,'Bioquimica general','Prueba de quimica sanguinea','Sangre',45.00,'25 min',2,2);
GO

--14 HERRAMIENTA_ANÁLISIS
INSERT INTO HERRAMIENTA_ANÁLISIS (ID_Herramienta, Nombre, Marca, Modelo)
VALUES
(1,'Microscopio','Olympus','X200'),
(2,'Centrifuga','Eppendorf','5804');
GO

--15 EMPLEA (TEST-HERRAMIENTA)
INSERT INTO EMPLEA (TEST_ANÁLISIS_ID_Test, HERRAMIENTA_ANÁLISIS_ID_Herramienta)
VALUES
(1,1),
(2,2);
GO

--16 UTILIZA (TEST-REACTIVO)
INSERT INTO UTILIZA (TEST_ANÁLISIS_ID_Test, REACTIVO_ID_Reactivo)
VALUES
(1,1),
(2,2);
GO

--17 MUESTRA
INSERT INTO MUESTRA (ID_Muestra, Tipo, Fecha_Extracción, Hora_Extracción, Estado, SOLICITUD_ANÁLISIS_ID_Solicitud_Análisis, ANALISTA_ID_Empleado)
VALUES
(1,'Sangre','2025-04-03','08:00','Procesada',1,5),
(2,'Orina','2025-04-04','09:00','Procesada',2,6);
GO

--18 ANALIZA
INSERT INTO ANALIZA (MUESTRA_ID_Muestra, TEST_ANÁLISIS_ID_Test)
VALUES
(1,1),
(2,2);
GO

--19 INFORME
INSERT INTO INFORME (ID_Informe, Fecha_Informe, Comentarios, Conclusión, MÉDICO_ID_Empleado)
VALUES
(1,'2025-04-05','Todo normal','Apto',3),
(2,'2025-04-06','Resultados correctos','Apto',4);
GO

--20 RESULTADO
INSERT INTO RESULTADO (ID_Resultado, Valor_Obtenido, Fecha_Resultado, Estado, Observaciones, ANALISTA_ID_Empleado, TEST_ANÁLISIS_ID_Test, MUESTRA_ID_Muestra, INFORME_ID_Informe)
VALUES
(1,'Normal','2025-04-05','Validado','Sin incidencias',5,1,1,1),
(2,'Normal','2025-04-06','Validado','Sin incidencias',6,2,2,2);
GO

--21 CITA
INSERT INTO CITA (ID_Cita, Fecha, Hora, Motivo, PACIENTE_ID_Paciente, ADMINISTRATIVO_ID_Empleado)
VALUES
(1,'2025-04-01','10:00','Consulta rutinaria',1,1),
(2,'2025-04-02','11:00','Entrega resultados',2,2);
GO

--En este ejemplo lo que vamos a considerar es que el valor la columna Conclusión de la tabla INFORME tiene que tener relación 
--con el valor de la columna Valor_Obtenido de la tabla RESULTADO. Es decir, en caso de que cambiásemos el valor obtenido en un RESULTADO,
--por ejemplo debido a un error en los análisis, la Conclusión del INFORME también tendría que cambiar

--Listamos los valores de las dos columnas que nos interesan (de la tabla INFORME la columna Conclusión y de la tabla RESULTADO la
--columna Valor_Obtenido) 
SELECT Conclusión AS [Valor asignado], 
       'Conclusión INFORME' AS [Tipo]
FROM INFORME
UNION ALL
SELECT Valor_obtenido AS [Valor asignado],
       'Valor_Obtenido RESULTADO' AS [Tipo]
FROM RESULTADO;
GO

-- Valor asignado    Tipo
-- Apto	             Conclusión INFORME
-- Apto              Conclusión INFORME
-- Normal	         Valor_Obtenido RESULTADO
-- Normal	         Valor_Obtenido RESULTADO

--Cambiamos el valor en "Valor_Obtenido" de "Normal" a "Anomalo"
UPDATE RESULTADO
SET Valor_Obtenido = 'Anomalo'
WHERE ID_Resultado = 1;

--Cambio el valor en "Conclusión" de "Apto" a "El paciente presenta positivo en infección bacteriana", y también el de "Fecha_Informe"

UPDATE INFORME
SET Conclusión = 'El paciente presenta positivo en infección bacteriana',
    Fecha_Informe = 'Fecha inválida'
WHERE ID_Informe = 1;
--Conversion failed when converting date and/or time from character string.
--Da error porque intenta cambiar el valor de Fecha_Informe a un tipo no válido

--Volvemos a listar los valores que nos interesan y vemos que sólo se ha cambiado el valor para "Valor_Obtenido", de la tabla RESULTADO, 
--mientras que el de "Conclusión", de la tabla INFORME, no se ha cambiado por el error
SELECT Conclusión AS [Valor asignado], 
       'Conclusión INFORME' AS [Tipo]
FROM INFORME
UNION ALL
SELECT Valor_obtenido AS [Valor asignado],
       'Valor_Obtenido RESULTADO' AS [Tipo]
FROM RESULTADO;
GO

-- Valor asignado    Tipo
-- Apto	             Conclusión INFORME
-- Apto              Conclusión INFORME
-- Anomalo	         Valor_Obtenido RESULTADO
-- Normal	         Valor_Obtenido RESULTADO
 
----------------------------------------------------

-- Ahora haremos lo mismo con transacciones explícitas, para que, en caso de que exista algún fallo, no se ejecute ninguna de las partes
--de la transacción. Es decir, o se ejecutan todas las operaciones de la transacción, o no se ejecuta ninguna

-- Primero volvemos a cambiar el valor de "Valor_Obtenido" en la tabla resultado a "Normal", que era como estaba originalmente
UPDATE RESULTADO
SET Valor_Obtenido = 'Normal'
WHERE ID_Resultado = 1;

SET XACT_ABORT ON; --Controlamos excepciones, ya que con esta sentencia provocamos que SQL Server haga ROLLBACK automáticamente

BEGIN TRANSACTION; --Empieza la transacción
UPDATE RESULTADO --Cambiamos de nuevo el valor de "Valor_Obtenido" (tabla RESULTADO)
SET Valor_Obtenido = 'Anomalo'
WHERE ID_Resultado = 1;

--Ahora hacemos lo mismo en la tabla INFORME; cambiamos tanto la "Conclusión" como la "Fecha_Informe". Esta última volverá a dar error
--por intentar cambiarlo a un tipo no válido
UPDATE INFORME
SET Conclusión = 'El paciente presenta positivo en infección bacteriana',
    Fecha_Informe = 'Fecha inválida'
WHERE ID_Informe = 1;

COMMIT TRANSACTION; --Ejecutamos la transacción
--Conversion failed when converting date and/or time from character string.
--Al ejecutar nos vuelve a dar el mismo error

--Ahora volvemos a listar los valores para ver si se ha cambiado alguno. Como esta vez como hemos utilizado la transacción
--(en concreto con SET XACT_ABORT ON) podemos ver que en este caso no se han modificado ni "Conclusión" ni "Valor_Obtenido"
--Esto se debe a que SET XACT_ABORT ON provoca un ROLLBACK, y por ello ninguna de las dos tablas cambia
SELECT Conclusión AS [Valor asignado], 
       'Conclusión INFORME' AS [Tipo]
FROM INFORME
UNION ALL
SELECT Valor_obtenido AS [Valor asignado],
       'Valor_Obtenido RESULTADO' AS [Tipo]
FROM RESULTADO;
GO
--Valor asignado  Tipo
--Apto	          Conclusión INFORME
--Apto	          Conclusión INFORME
--Normal	      Valor_Obtenido RESULTADO
--Normal	      Valor_Obtenido RESULTADO

----------------------------

--Ahora probaremos con TRY, CATCH y THROW. Como antes utilizamos la transacción y no hubo cambios en las tablas, podemos empezar la 
--nueva transacción sin modificar ningún valor
BEGIN TRY --BEGIN TRY ... END TRY contienen la transacción. Si no hay errores se ejecuta todo el contenido sin utilizar el CATCH, pero en
--caso de algún error la ejecución se detiene y se pasa al CATCH, que es lo que va a ocurrir en este caso
BEGIN TRANSACTION; --Empieza la transacción
UPDATE RESULTADO --Se actualiza el valor de "Valor_Obtenido" en la tabla RESULTADO por "Anomalo"
SET Valor_Obtenido = 'Anomalo'
WHERE ID_Resultado = 1;

UPDATE INFORME --Se actualiza el valor de "Conclusión" y de "Fecha_Informe" en la tabla INFORME. Este último cambio dará error
SET Conclusión = 'El paciente presenta positivo en infección bacteriana',
    Fecha_Informe = 'Fecha invalida'
WHERE ID_Informe = 1;

COMMIT TRANSACTION; --Ejecutamos la transacción
END TRY --Finaliza el TRY
BEGIN CATCH --Como en BEGIN TRY ... END TRY ha habido un error, se ejecuta BEGIN CATCH ... END CATCH
    PRINT 'Dato de tipo invalido en fecha'; --Ponemos un mensaje de error personalizado
    THROW; --Utilizamos THROW para relanzar el error original dentro del CATCH
END CATCH; --Finaliza el CATCH
 GO 
--Nos salta el mensaje de error del PRINT y del THROW
--Dato de tipo invalido en fecha
--Msg 241, Level 16, State 1, Line 8
--Conversion failed when converting date and/or time from character string.


--Para finalizar comprobaremos que los datos de las tablas no se hayan modificado
SELECT Conclusión AS [Valor asignado], 
       'Conclusión INFORME' AS [Tipo]
FROM INFORME
UNION ALL
SELECT Valor_obtenido AS [Valor asignado],
       'Valor_Obtenido RESULTADO' AS [Tipo]
FROM RESULTADO;
GO

--Gracias al principio de atomicidad no se han modificado los valores

--Valor asignado  Tipo
--Apto	          Conclusión INFORME
--Apto	          Conclusión INFORME
--Normal	      Valor_Obtenido RESULTADO
--Normal	      Valor_Obtenido RESULTADO