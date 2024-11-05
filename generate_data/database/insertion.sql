

INSERT INTO empresa (ruc, sector, departamento, anio_antiguedad, sst)
VALUES 
('12345678901', 'Manufactura', 'Lima', 10, 1),
('10987654321', 'Servicios', 'Arequipa', 5, 0);


INSERT INTO trabajador (dni, nombre, apellido, fecha_nac, genero)
VALUES 
('12345678', 'Juan', 'Perez', '1985-02-15', 'Masculino'),
('87654321', 'Maria', 'Lopez', '1990-07-20', 'Femenino'),
('23456789', 'Carlos', 'Gomez', '1983-11-02', 'Masculino'),
('98765432', 'Ana', 'Martinez', '1995-05-14', 'Femenino'),
('34567890', 'Jose', 'Diaz', '1988-08-30', 'No precisa'),
('87654322', 'Rosa', 'Torres', '1992-03-17', 'Femenino'),
('45678901', 'Luis', 'Ramirez', '1999-12-12', 'Masculino'),
('76543210', 'Carmen', 'Castro', '2000-01-01', 'Femenino'),
('56789012', 'Miguel', 'Vega', '1987-04-05', 'No precisa'),
('65432109', 'Laura', 'Chavez', '1993-06-25', 'Femenino');




-- Declaraciones para la primera empresa en dos fechas
INSERT INTO declaracion (id_empresa, id_trabajador, fecha_declaracion, tipo_contrato, regimen_laboral, regimen_pensionario, regimen_salud, sindicalizado, sctr, remuneracion)
VALUES 
(1, 1, '2024-01-01', 'A plazo indeterminado', 'General', 'Sistema Privado de Pensiones', 'ESSALUD', 'Si', 'Con sctr', 1500.00),
(1, 2, '2024-01-01', 'De naturaleza temporal', 'Micro empresa', 'Sistema Nacional de Pensiones', 'ESSALUD', 'No', 'Sin sctr', 1200.00),
(1, 3, '2024-01-01', 'Tiempo parcial', 'Pequena empresa', 'Sistema Privado de Pensiones', 'SIS', 'No', 'Sin sctr', 800.00),
(1, 4, '2024-01-01', 'De obra o servicio', 'Agrario', 'Otro regimen pensionario', 'ESSALUD', 'No', 'Con sctr', 1100.00),
(1, 5, '2024-01-01', 'A plazo indeterminado', 'General', 'Sistema Privado de Pensiones', 'ESSALUD', 'Si', 'Con sctr', 1550.00),

(1, 1, '2024-02-01', 'De naturaleza accidental', 'Pequena empresa', 'Sistema Nacional de Pensiones', 'ESSALUD', 'No', 'Sin sctr', 1150.00),
(1, 2, '2024-02-01', 'Tiempo parcial', 'Micro empresa', 'Sistema Nacional de Pensiones', 'SIS', 'Si', 'Con sctr', 1300.00),
(1, 3, '2024-02-01', 'A plazo indeterminado', 'General', 'Sistema Privado de Pensiones', 'ESSALUD Agrario', 'Si', 'Con sctr', 1600.00),
(1, 4, '2024-02-01', 'De naturaleza temporal', 'Agrario', 'Sistema Nacional de Pensiones', 'ESSALUD', 'No', 'Sin sctr', 950.00),
(1, 5, '2024-02-01', 'De obra o servicio', 'Pequena empresa', 'Otro regimen pensionario', 'SIS', 'No', 'Con sctr', 1250.00);

-- Declaraciones para la segunda empresa en dos fechas
INSERT INTO declaracion (id_empresa, id_trabajador, fecha_declaracion, tipo_contrato, regimen_laboral, regimen_pensionario, regimen_salud, sindicalizado, sctr, remuneracion)
VALUES 
(2, 6, '2024-01-01', 'A plazo indeterminado', 'General', 'Sistema Privado de Pensiones', 'ESSALUD', 'Si', 'Con sctr', 1400.00),
(2, 7, '2024-01-01', 'De naturaleza temporal', 'Micro empresa', 'Sistema Nacional de Pensiones', 'ESSALUD', 'No', 'Sin sctr', 1050.00),
(2, 8, '2024-01-01', 'Tiempo parcial', 'Pequena empresa', 'Sistema Privado de Pensiones', 'SIS', 'No', 'Sin sctr', 950.00),
(2, 9, '2024-01-01', 'De obra o servicio', 'Agrario', 'Otro regimen pensionario', 'ESSALUD', 'No', 'Con sctr', 1150.00),
(2, 10, '2024-01-01', 'De naturaleza accidental', 'General', 'Sistema Nacional de Pensiones', 'ESSALUD Agrario', 'Si', 'Con sctr', 1250.00),

(2, 6, '2024-02-01', 'A plazo indeterminado', 'Pequena empresa', 'Sistema Nacional de Pensiones', 'ESSALUD', 'No', 'Sin sctr', 1450.00),
(2, 7, '2024-02-01', 'De naturaleza temporal', 'Agrario', 'Sistema Nacional de Pensiones', 'SIS', 'Si', 'Con sctr', 950.00),
(2, 8, '2024-02-01', 'De obra o servicio', 'Micro empresa', 'Sistema Privado de Pensiones', 'ESSALUD', 'No', 'Sin sctr', 1200.00),
(2, 9, '2024-02-01', 'Tiempo parcial', 'General', 'Sistema Nacional de Pensiones', 'SIS', 'Si', 'Con sctr', 1000.00),
(2, 10, '2024-02-01', 'A plazo indeterminado', 'General', 'Sistema Privado de Pensiones', 'ESSALUD Agrario', 'No', 'Con sctr', 1550.00);



select * from resumen

EXEC sp_obtener_resumen_por_empresa_y_fecha 
    @id_empresa = 1, 
    @fecha_declaracion = '2024-01-01';
