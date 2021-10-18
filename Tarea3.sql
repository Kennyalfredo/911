/*1. Crear un disparador “insertar_empleado” para controlar la no 
inserción de una fila en la tabla empleado cuando no sea horario laboral. 
Para este ejercicio vamos a considerar que el horario 
laboral del negocio es de viernes a miércoles de 2 pm a 10 pm*/
DROP TRIGGER IF EXISTS BEFORE_INSERT_EMPLEADO;
DELIMITER $$
CREATE TRIGGER BEFORE_INSERT_EMPLEADO BEFORE INSERT ON EMPLEADO FOR EACH ROW
BEGIN

IF NOT ((DAYOFWEEK(NOW()) BETWEEN 4 AND 6) AND (current_time() between '14:00:00' AND '22:00:00')) THEN

SET NEW.ID_EMP = NULL; -- Impider la operación.

END IF;
END $$ DELIMITER ;

INSERT INTO empleado VALUES (11, 'Pepe', 30); 

/* 2. Crear el mismo disparador pero utilizando un procedimiento
 en el cuerpo del disparador que controle si la hora y el día son correctos. */

DROP PROCEDURE IF EXISTS VERIFICAR_HORARIO;

DELIMITER //
CREATE PROCEDURE VERIFICAR_HORARIO (OUT VERF BOOLEAN)
BEGIN
IF NOT ((DAYOFWEEK(NOW()) between 4 AND 6) AND (current_time() between '14:00:00' AND '22:00:00')) THEN
SET VERF = 0;
ELSE
SET VERF = 1;
END IF;
END // DELIMITER ;

DROP TRIGGER IF EXISTS BEFORE_INSERT_EMPLEADO;

DROP PROCEDURE IF EXISTS VERIFICAR_HORARIO;

DELIMITER //
CREATE PROCEDURE VERIFICAR_HORARIO (OUT VERF BOOLEAN)
BEGIN
IF NOT ((DAYOFWEEK(NOW()) between 4 AND 6) AND (current_time() between '14:00:00' AND '22:00:00')) THEN
SET VERF = 0;
ELSE
SET VERF = 1;
END IF;
END // DELIMITER ;

DROP TRIGGER IF EXISTS BEFORE_INSERT_EMPLEADO;

DELIMITER $$ 
CREATE TRIGGER BEFORE_INSERT_EMPLEADO BEFORE INSERT ON EMPLEADO FOR EACH ROW
BEGIN

CALL VERIFICAR_HORARIO(@flag);

IF @flag = 0 THEN
SET NEW.ID_EMP = NULL;
END IF;

END $$ DELIMITER ;

INSERT INTO empleado VALUES (20, 'Andres', 30); 
/*3. Crear un disparador que impida cualquier operación (insert, select, update, delete) en la tabla empleado fuera del horario laboral dando una indicación específica de la operación que no es
 realizable y porqué no es realizable (por ejemplo, que se encuentra fuera del horario laboral).*/

-- Para insert
DROP TRIGGER IF EXISTS BEFORE_INSERT_EMPLEADO;
DELIMITER $$
CREATE TRIGGER BEFORE_INSERT_EMPLEADO BEFORE INSERT ON EMPLEADO FOR EACH ROW

BEGIN
IF NOT ((DAYOFWEEK(NOW()) BETWEEN 4 AND 6) AND (current_time() between '14:00:00' AND '22:00:00')) THEN

SIGNAL SQLSTATE '45000' -- Impide la operación.
SET MESSAGE_TEXT = 'Fuera del horario laboral'; -- Pones el mensaje que quieras.

END IF;
END $$ DELIMITER ;


-- Para update
DROP TRIGGER IF EXISTS BEFORE_UPDATE_EMPLEADO;
DELIMITER $$
CREATE TRIGGER BEFORE_UPDATE_EMPLEADO BEFORE UPDATE ON EMPLEADO FOR EACH ROW

BEGIN
IF NOT ((DAYOFWEEK(NOW()) BETWEEN 4 AND 6) AND (current_time() between '14:00:00' AND '22:00:00')) THEN

SIGNAL SQLSTATE '45000' -- Impide la operación.
SET MESSAGE_TEXT = 'Fuera del horario laboral'; -- Pones el mensaje que quieras.

END IF;
END $$ DELIMITER ;

USE PRACTICA;
-- Para delete
DROP TRIGGER IF EXISTS BEFORE_DELETE_EMPLEADO;
DELIMITER $$
CREATE TRIGGER BEFORE_DELETE_EMPLEADO BEFORE DELETE ON EMPLEADO FOR EACH ROW

BEGIN
IF NOT ((DAYOFWEEK(NOW()) BETWEEN 4 AND 6) AND (current_time() between '14:00:00' AND '22:00:00')) THEN

SIGNAL SQLSTATE '45000'; -- Impide la operación
SET MESSAGE_TEXT = 'Fuera del horario laboral'; -- Pones el mensaje que quieras.

END IF;
END $$ DELIMITER ;



 
 /*4. Añadir a la tabla empleado una nueva columna salario. El valor por defecto debe 
 ser el salario básico. Copie el código que utilizó para crear el nuevo campo*/
 select * from empleado;

ALTER TABLE EMPLEADO ADD SALARIO FLOAT DEFAULT 400;

/*5.Cree un disparador que cada vez que se ingrese un empleado, su salario se modifique de la siguiente manera: 

•	Si el empleado pertenece al departamento de ‘Informática’, su salario será el triple del salario básico.

•	Si el empleado pertenece al departamento de ‘Ventas’, su salario será el doble del salario básico.

•	Si el empleado pertenece al departamento de ‘Recursos Humanos’, su salario será el 1.5 del salario básico.
*/

DROP TRIGGER IF EXISTS BEFORE_INSERT_EMPLEADO;
DELIMITER $$
CREATE TRIGGER BEFORE_INSERT_EMPLEADO BEFORE INSERT ON EMPLEADO FOR EACH ROW
BEGIN
SET @nom_depar = (SELECT NOMBRE FROM DEPARTAMENTO WHERE NRO_DEP = NEW.DEP);

IF (@nom_depar LIKE 'INFORMÁTICA') THEN
SET NEW.SALARIO = (NEW.SALARIO * 3);
END IF;

IF (@nom_depar LIKE 'VENTAS') THEN
SET NEW.SALARIO = NEW.SALARIO * 2;
END IF;

IF (@nom_depar LIKE 'RECURSOS HUMANOS') THEN
SET NEW.SALARIO = NEW.SALARIO * 1.5;
END IF;

END $$ DELIMITER ;
INSERT INTO empleado VALUES (13, 'Antonella', 10); 
INSERT INTO empleado VALUES (14, 'Jose', 20); 
INSERT INTO empleado VALUES (15, 'Anthony', 30); 
INSERT INTO empleado VALUES (16, 'Maria', 50); 
INSERT INTO empleado VALUES (17,"Erick",20);
DROP TABLE EMPLEADO;
Select * from empleado;

/*
6. Crear una tabla llamada Cambios dónde se almacenarán, mediante la utilización de un disparador, 
los cambios que se han llevado a cabo en la tabla empleado de forma que ante cada cambio de departamento 
o de salario de un empleado, la nueva tabla almacenará el identificador del empleado, el antiguo y el nuevo 
salario (a_salario, n_salario), o el antiguo y el nuevo departamento (a_dep, n_dep) junto con la fecha y hora en 
que el cambio tuvo lugar.
Tabla: Cambios
- id_empleado (NOT null)
- v_salario (null)
- n_salario (null)
- v_dep (null)
- n_dep (null)
- Fecha (datetime) NOT NULL

*/

DROP TABLE IF EXISTS CAMBIOS;

CREATE TABLE CAMBIOS (
	ID_CAMBIOS INT PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	ID_EMPLEADO INT NOT NULL,
    V_SALARIO FLOAT NULL,
    N_SALARIO FLOAT NULL,
    V_DEP INT NULL,
    N_DEP INT NULL,
    FECHA DATETIME NOT NULL
);

DROP TRIGGER IF EXISTS AFTER_UPDATE_EMPLEADO;

DELIMITER $$
CREATE TRIGGER AFTER_UPDATE_EMPLEADO AFTER UPDATE ON EMPLEADO FOR EACH ROW
BEGIN
INSERT INTO CAMBIOS (ID_EMPLEADO,V_SALARIO,N_SALARIO,V_DEP,N_DEP,FECHA) VALUES 
(OLD.ID_EMP,OLD.SALARIO,NEW.SALARIO,OLD.DEP,NEW.DEP,NOW()); 
END $$ DELIMITER ;

UPDATE empleado SET salario= salario*2 WHERE dep=10;
UPDATE empleado SET dep = salario/200 where salario>2000;
UPDATE empleado SET salario=salario*0.12 where nombre like "Kenny";
/*
7. Añadir a la tabla empleado una nueva columna denominada media (tipo de dato decimal, valor por defecto 0)
que contendrá́ la media del salario que el trabajador ha tenido en la empresa. Esta columna tendrá́ por defecto
el salario actual del trabajador hasta que este salario se modifique. 
*/


ALTER TABLE EMPLEADO ADD MEDIA DECIMAL DEFAULT 0; 
UPDATE EMPLEADO SET MEDIA = SALARIO; 


DROP TRIGGER IF EXISTS MEDIA_SALARIO;

DELIMITER $$
CREATE TRIGGER MEDIA_SALARIO BEFORE UPDATE ON EMPLEADO FOR EACH ROW
BEGIN
SET NEW.MEDIA = (OLD.SALARIO + NEW.SALARIO)/2;
END $$ DELIMITER ;
 
UPDATE EMPLEADO SET SALARIO = 7000 WHERE ID_EMP = 8; -- Modifica el salario a 7000 del empleado con id 8.


select * from empleado;

/*8. Crear una vista llamada PromedioSalarioporDepartamento en dónde se muestre el identificador del 
departamento y el promedio del salario de los empleados por departamento. Nota: La tabla empleado
tiene el id del departamento.
*/

DROP VIEW IF EXISTS PromedioSalarioporDepartamento;

CREATE VIEW PromedioSalarioporDepartamento AS SELECT DEP, AVG(SALARIO) AS PROMEDIO_SALARIOS FROM EMPLEADO GROUP BY DEP;

SELECT * FROM PromedioSalarioporDepartamento;
 
SELECT * FROM EMPLEADO; 