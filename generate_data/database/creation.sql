use dataton;

-- Empresa
if exists (select name from sys.tables where name='empresa')
drop table empresa;

create table empresa (
	id_empresa int primary key identity(1,1),
	ruc varchar(11) unique not null,  -- RUC en Perú tiene longitud de 11
	sector varchar(max) not null,
	departamento varchar(50) not null,
	anio_antiguedad int not null,
	sst int not null check (sst in (0, 1))  -- Indicador de comité de seguridad
);



-- Trabajador
if exists (select name from sys.tables where name='trabajador')
drop table trabajador;

create table trabajador (
	id_trabajador int primary key identity(1,1),
	dni varchar(8) not null unique,
	nombre varchar(100) not null,
	apellido varchar(100) not null,
	fecha_nac date,
	genero varchar(10) not null check (genero in ('Masculino', 'Femenino', 'No Precisa'))
);



-- Declaracion
if exists (select name from sys.tables where name='declaracion')
drop table declaracion;

create table declaracion (
	id_declaracion int primary key identity(1,1),
	id_empresa int foreign key references empresa(id_empresa) on delete cascade,
	id_trabajador int foreign key references trabajador(id_trabajador) on delete cascade,
	fecha_declaracion date not null,
	tipo_contrato varchar(50) not null check (tipo_contrato in ('A plazo indeterminado', 'De naturaleza temporal', 'De naturaleza accidental', 'De obra o servicio', 'Tiempo parcial', 'Otros', 'No precisa')),
	regimen_laboral varchar(50) check (regimen_laboral in ('General', 'Pequena empresa', 'Micro empresa', 'Agrario', 'Otros', 'No precisa')),
	regimen_pensionario varchar(50) not null check (regimen_pensionario in ('Sistema Privado de Pensiones', 'Sistema Nacional de Pensiones', 'Otro regimen pensionario', 'No precisa')),
	regimen_salud varchar(50) not null check (regimen_salud in ('ESSALUD', 'ESSALUD Agrario', 'SIS', 'No precisa')),
	sindicalizado varchar(2) not null check (sindicalizado in ('Si', 'No')),
	sctr varchar(100) not null check (sctr in ('Con sctr', 'Sin sctr', 'No precisa')),
	remuneracion decimal(10, 2) not null check (remuneracion >= 0)
);



-- Modificar la tabla resumen para incluir fecha_declaracion
if exists (select name from sys.tables where name='resumen')
drop table resumen;

create table resumen (
    id_empresa int not null,
    fecha_declaracion date not null,
    ruc varchar(11) not null,
    
    numtra int not null default 0,  -- Total de trabajadores
    num_mayor_rm decimal(10, 2) default 0,  -- Trabajadores con remuneración >= RMV
    num_menor_rm decimal(10, 2) default 0,  -- Trabajadores con remuneración < RMV

    -- Resumen por tipos de contrato
    ntrab_tc_indet int default 0,
    ntrab_tc_nattemp int default 0,
    ntrab_tc_natacc int default 0,
    ntrab_tc_obrserv int default 0,
    ntrab_tc_tiempar int default 0,
    ntrab_tc_otros int default 0,
    ntrab_tc_noprec int default 0,

    -- Resumen por régimen laboral
    ntrab_rl_privgen int default 0,
    ntrab_rl_micro int default 0,
    ntrab_rl_peq int default 0,
    ntrab_rl_agrar int default 0,
    ntrab_rl_otros int default 0,
    ntrab_rl_noprec int default 0,

    -- Resumen por régimen pensionario
    ntrab_rp_spp int default 0,
    ntrab_rp_snp int default 0,
    ntrab_rp_otros int default 0,
    ntrab_rp_noprecrp int default 0,

    -- Resumen por afiliación a salud
    ntrab_afil_essalud int default 0,
    ntrab_afil_essalud_agrar int default 0,
    ntrab_afil_sis int default 0,
    ntrab_afil_noprec int default 0,

    -- Resumen por edades
    ntrab_18mas int default 0,
    ntrab_menos18 int default 0,
    ntrab_edad_noprec int default 0,

    -- Resumen por género
    ntrab_mujeres int default 0,
    ntrab_hombres int default 0,
    ntrab_sexo_noprec int default 0,

    -- Resumen por afiliación sindical
    ntrab_nosind int default 0,
    ntrab_sind int default 0,

    -- Resumen por SCTR
    ntrab_consctr int default 0,
    ntrab_sinsctr int default 0,
    ntrab_sctr_noprec int default 0,

    -- Costo total salarial
    costosal decimal(15, 2) default 0,

    -- Clave primaria compuesta por id_empresa y fecha_declaracion
    primary key (id_empresa, fecha_declaracion)
);
go 



CREATE OR ALTER TRIGGER trg_actualizar_resumen
ON declaracion
AFTER INSERT
AS
BEGIN
    DECLARE @v_rm DECIMAL(10, 2) = 1025.00;

    DECLARE @id_empresa INT;
    DECLARE @fecha_declaracion DATE;
    DECLARE cur CURSOR FOR 
        SELECT DISTINCT id_empresa, fecha_declaracion 
        FROM INSERTED;
    
    OPEN cur;
    FETCH NEXT FROM cur INTO @id_empresa, @fecha_declaracion;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM resumen WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion)
        BEGIN
            INSERT INTO resumen (id_empresa, fecha_declaracion, ruc)
            SELECT id_empresa, @fecha_declaracion, ruc FROM empresa WHERE id_empresa = @id_empresa;
        END

        -- Actualizar los campos en la tabla resumen
        UPDATE resumen
        SET 
            numtra = numtra + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion),

            num_mayor_rm = num_mayor_rm + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND remuneracion >= @v_rm),
            num_menor_rm = num_menor_rm + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND remuneracion < @v_rm),

            -- Resumen por tipos de contrato
            ntrab_tc_indet = ntrab_tc_indet + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND tipo_contrato = 'A plazo indeterminado'),
            ntrab_tc_nattemp = ntrab_tc_nattemp + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND tipo_contrato = 'De naturaleza temporal'),
            ntrab_tc_natacc = ntrab_tc_natacc + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND tipo_contrato = 'De naturaleza accidental'),
            ntrab_tc_obrserv = ntrab_tc_obrserv + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND tipo_contrato = 'De obra o servicio'),
            ntrab_tc_tiempar = ntrab_tc_tiempar + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND tipo_contrato = 'Tiempo parcial'),
            ntrab_tc_otros = ntrab_tc_otros + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND tipo_contrato NOT IN ('A plazo indeterminado', 'De naturaleza temporal', 'De naturaleza accidental', 'De obra o servicio', 'Tiempo parcial')),

            -- Resumen por régimen laboral
            ntrab_rl_privgen = ntrab_rl_privgen + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_laboral = 'General'),
            ntrab_rl_micro = ntrab_rl_micro + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_laboral = 'Micro empresa'),
            ntrab_rl_peq = ntrab_rl_peq + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_laboral = 'Pequena empresa'),
            ntrab_rl_agrar = ntrab_rl_agrar + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_laboral = 'Agrario'),
            ntrab_rl_otros = ntrab_rl_otros + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_laboral = 'Otros'),
            ntrab_rl_noprec = ntrab_rl_noprec + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_laboral = 'No precisa'),

            -- Resumen por régimen pensionario
            ntrab_rp_spp = ntrab_rp_spp + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_pensionario = 'Sistema Privado de Pensiones'),
            ntrab_rp_snp = ntrab_rp_snp + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_pensionario = 'Sistema Nacional de Pensiones'),
            ntrab_rp_otros = ntrab_rp_otros + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_pensionario = 'Otro regimen pensionario'),
            ntrab_rp_noprecrp = ntrab_rp_noprecrp + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_pensionario = 'No precisa'),

            -- Resumen por afiliación a salud
            ntrab_afil_essalud = ntrab_afil_essalud + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_salud = 'ESSALUD'),
            ntrab_afil_essalud_agrar = ntrab_afil_essalud_agrar + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_salud = 'ESSALUD Agrario'),
            ntrab_afil_sis = ntrab_afil_sis + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_salud = 'SIS'),
            ntrab_afil_noprec = ntrab_afil_noprec + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND regimen_salud = 'No precisa'),

			ntrab_sind = ntrab_sind + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND sindicalizado = 'Si'),
			ntrab_nosind = ntrab_nosind + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND sindicalizado = 'No'),

			ntrab_consctr = ntrab_consctr + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND sctr = 'Con sctr'),
			ntrab_sinsctr = ntrab_sinsctr + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND sctr = 'Sin sctr'),
			ntrab_sctr_noprec = ntrab_sctr_noprec + (SELECT COUNT(*) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion AND sctr = 'No precisa'),


            -- Resumen por edades usando JOIN con trabajador para obtener fecha_nac
            ntrab_18mas = ntrab_18mas + (SELECT COUNT(*) 
                                        FROM INSERTED i
                                        JOIN trabajador t ON i.id_trabajador = t.id_trabajador
                                        WHERE i.id_empresa = @id_empresa 
                                        AND i.fecha_declaracion = @fecha_declaracion 
                                        AND DATEDIFF(year, t.fecha_nac, GETDATE()) >= 18),

            ntrab_menos18 = ntrab_menos18 + (SELECT COUNT(*)
                                            FROM INSERTED i
                                            JOIN trabajador t ON i.id_trabajador = t.id_trabajador
                                            WHERE i.id_empresa = @id_empresa 
                                            AND i.fecha_declaracion = @fecha_declaracion 
                                            AND DATEDIFF(year, t.fecha_nac, GETDATE()) < 18),

            -- Resumen por género usando JOIN con trabajador para obtener genero
            ntrab_mujeres = ntrab_mujeres + (SELECT COUNT(*)
                                            FROM INSERTED i
                                            JOIN trabajador t ON i.id_trabajador = t.id_trabajador
                                            WHERE i.id_empresa = @id_empresa AND i.fecha_declaracion = @fecha_declaracion AND t.genero = 'Femenino'),

            ntrab_hombres = ntrab_hombres + (SELECT COUNT(*)
                                            FROM INSERTED i
                                            JOIN trabajador t ON i.id_trabajador = t.id_trabajador
                                            WHERE i.id_empresa = @id_empresa AND i.fecha_declaracion = @fecha_declaracion AND t.genero = 'Masculino'),

            ntrab_sexo_noprec = ntrab_sexo_noprec + (SELECT COUNT(*)
                                                    FROM INSERTED i
                                                    JOIN trabajador t ON i.id_trabajador = t.id_trabajador
                                                    WHERE i.id_empresa = @id_empresa AND i.fecha_declaracion = @fecha_declaracion AND t.genero = 'No Precisa'),

            -- Cálculo del costo salarial total
            costosal = costosal + (SELECT SUM(remuneracion) FROM INSERTED WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion)
            
        WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion;

        FETCH NEXT FROM cur INTO @id_empresa, @fecha_declaracion;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO


-- Store Procedure
CREATE OR ALTER PROCEDURE sp_obtener_resumen_por_empresa_y_fecha
    @id_empresa INT,
    @fecha_declaracion DATE
AS
BEGINa
    SELECT *
    FROM resumen
    WHERE id_empresa = @id_empresa AND fecha_declaracion = @fecha_declaracion;
END;
GO
