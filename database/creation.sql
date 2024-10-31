create database datatonç
go

use dataton

CREATE TABLE trabajador (
    id_trabajador INT PRIMARY KEY IDENTITY(1,1),
    ruc VARCHAR(11) NOT NULL,
    regimen_laboral VARCHAR(50) check (regimen_laboral in ('General','Pequena empresa','Micro empresa','Agrario','Otros','No precisa')),
    dni VARCHAR(8) NOT NULL UNIQUE,  -- Aseguramos que el DNI sea único
    tipo_contrato VARCHAR(50) NOT NULL check (tipo_contrato in ('A plazo indeterminado', 'De naturaleza temporal', 'De naturaleza ocasional', 'De naturaleza accidental', 'Tiempo parcial', 'Otros')),
    remuneracion DECIMAL(10, 2) NOT NULL CHECK (remuneracion >= 0),  -- Asegura que la remuneración no sea negativa
    regimen_pensionario VARCHAR(50) NOT NULL check (regimen_pensionario in ('Sistema Privado de Pensiones','Sistema Nacional de Pensiones','Otro regimen pensionario','Sin regimen pensionario')),
    regimen_salud VARCHAR(50) NOT NULL  check (regimen_salud in ('ESSALUD', 'ESSALUD Agrario', 'SIS')),
    fecha_inicio DATE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,  -- Se especifica un tamaño fijo
    genero VARCHAR(10) NOT NULL CHECK (genero IN ('Masculino', 'Femenino')),  -- Asegura valores válidos
    fecha_nac DATE NOT NULL,
    departamento VARCHAR(50) NOT NULL,
);

create TABLE empresa (
    id_empresa INT PRIMARY KEY IDENTITY(1,1),
    ruc VARCHAR(11) NOT NULL UNIQUE,
    regimen_laboral VARCHAR(50),
    num_trabajadores INT NOT NULL DEFAULT 0,  -- Total de trabajadores

    num_mayor_rm DECIMAL(10, 2) DEFAULT 0,  -- Trabajadores con remuneración >= RMV
    num_menor_rm DECIMAL(10, 2) DEFAULT 0,  -- Trabajadores con remuneración < RMV

    num_plazo_indefinido INT DEFAULT 0,  -- A plazo indeterminado
    num_temporal INT DEFAULT 0,  -- De naturaleza temporal
    num_ocasional INT DEFAULT 0,  -- De naturaleza ocasional
    num_accidental INT DEFAULT 0,  -- De naturaleza accidental
    num_tiempo_parcial INT DEFAULT 0,  -- Tiempo parcial
    num_otros INT DEFAULT 0,  -- Otros tipos de contrato

    num_privado_pensiones INT DEFAULT 0,  -- Sistema Privado de Pensiones
    num_nacional_pensiones INT DEFAULT 0,  -- Sistema Nacional de Pensiones
    num_otro_regimen_pensionario INT DEFAULT 0,  -- Otro régimen
    num_sin_regimen_pensionario INT DEFAULT 0,  -- Sin régimen pensionario

	num_essalud int default 0,
	num_essalud_agrario int default 0,
	num_sis int default 0,

    num_18_o_mas INT DEFAULT 0,  -- 18 años o más
    num_menor_18 INT DEFAULT 0,  -- Menores de 18 años

    num_femenino INT DEFAULT 0,  -- Trabajadores femeninos
    num_masculino INT DEFAULT 0   -- Trabajadores masculinos
);
go




CREATE or alter TRIGGER trg_actualizar_empresa
ON trabajador
AFTER INSERT
AS
BEGIN
    DECLARE @v_rm DECIMAL(10, 2);
    
    -- Obtener la remuneración mínima vital (RMV)
    SET @v_rm = 1025.00;  -- Cambia esto por la lógica para obtener la RMV actual

    -- Inicializar variables para el RUC
    DECLARE @ruc VARCHAR(11);
    
    -- Cursor para recorrer los ruc de las inserciones
    DECLARE cur CURSOR FOR SELECT DISTINCT ruc FROM INSERTED;
    OPEN cur;
    
    FETCH NEXT FROM cur INTO @ruc;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Intentar insertar un nuevo registro en empresa si no existe
        IF NOT EXISTS (SELECT 1 FROM empresa WHERE ruc = @ruc)
        BEGIN
            INSERT INTO empresa (ruc, regimen_laboral)
            SELECT @ruc, regimen_laboral FROM INSERTED WHERE ruc = @ruc;
        END

        FETCH NEXT FROM cur INTO @ruc;
    END

    CLOSE cur;
    DEALLOCATE cur;

    -- Actualizar el empresa con los nuevos datos
    UPDATE empresa
    SET 
        num_trabajadores = num_trabajadores + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc),

        num_mayor_rm = num_mayor_rm + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND remuneracion >= @v_rm),
        num_menor_rm = num_menor_rm + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND remuneracion < @v_rm),

        num_plazo_indefinido = num_plazo_indefinido + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND tipo_contrato = 'A plazo indeterminado'),
        num_temporal = num_temporal + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND tipo_contrato = 'De naturaleza temporal'),
        num_ocasional = num_ocasional + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND tipo_contrato = 'De naturaleza ocasional'),
        num_accidental = num_accidental + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND tipo_contrato = 'De naturaleza accidental'),
        num_tiempo_parcial = num_tiempo_parcial + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND tipo_contrato = 'Tiempo parcial'),
        num_otros = num_otros + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND tipo_contrato NOT IN ('A plazo indeterminado', 'De naturaleza temporal', 'De naturaleza ocasional', 'De naturaleza accidental', 'Tiempo parcial')),
        
		num_privado_pensiones = num_privado_pensiones + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND regimen_pensionario = 'Sistema Privado de Pensiones'),
        num_nacional_pensiones = num_nacional_pensiones + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND regimen_pensionario = 'Sistema Nacional de Pensiones'),
        num_otro_regimen_pensionario = num_otro_regimen_pensionario + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND regimen_pensionario = 'Otro regimen pensionario'),
        num_sin_regimen_pensionario = num_sin_regimen_pensionario + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND regimen_pensionario = 'Sin regimen pensionario'),

		num_essalud = num_essalud + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND regimen_salud = 'ESSALUD'),
		num_essalud_agrario = num_essalud_agrario + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND regimen_salud = 'ESSALUD Agrario'),
		num_sis = num_sis + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND regimen_salud = 'SIS'),

		num_18_o_mas = num_18_o_mas + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND DATEDIFF(year, fecha_inicio, GETDATE()) >= 18),
        num_menor_18 = num_menor_18 + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND DATEDIFF(year, fecha_inicio, GETDATE()) < 18),

        num_femenino = num_femenino + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND genero = 'Femenino'),
        num_masculino = num_masculino + (SELECT COUNT(*) FROM INSERTED WHERE ruc = empresa.ruc AND genero = 'Masculino');
END;

