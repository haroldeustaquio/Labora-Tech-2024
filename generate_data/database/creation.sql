create database dataton
go

use dataton;

if exists (select name from sys.tables where name='declaracion')
drop table declaracion;

if exists (select name from sys.tables where name='trabajador')
drop table trabajador;

-- Tabla de Empresa
if exists (select name from sys.tables where name='empresa')
drop table empresa;

create table empresa (
	ruc varchar(11) primary key,  -- RUC en Perú tiene longitud de 11
	sector varchar(max) not null,
	departamento varchar(50) not null,
	anio_antiguedad int not null,
);



-- Nueva tabla de Trabajadores
if exists (select name from sys.tables where name='trabajador')
drop table trabajador;

create table trabajador (
	dni varchar(8) primary key,
	nombre varchar(100) not null,
	apellido varchar(100) not null,
	fecha_nac date,
	genero varchar(10) not null check (genero in ('Masculino', 'Femenino', 'No Precisa'))
);



-- Tabla de Declaracion con referencia a trabajador
if exists (select name from sys.tables where name='declaracion')
drop table declaracion;

create table declaracion (
	id_declaracion int primary key identity(1,1),
	ruc varchar(11) foreign key references empresa(ruc) on delete cascade,
	dni varchar(8) foreign key references trabajador(dni) on delete cascade,
	fecha_declaracion date not null,
	tipo_contrato varchar(50) not null check (tipo_contrato in ('A plazo indeterminado', 'De naturaleza temporal', 'De naturaleza accidental', 'De obra o servicio', 'Tiempo parcial', 'Otros', 'No precisa')),
	regimen_laboral varchar(50) check (regimen_laboral in ('General', 'Pequena empresa', 'Micro empresa', 'Agrario', 'Otros', 'No precisa')),
	regimen_pensionario varchar(50) not null check (regimen_pensionario in ('Sistema Privado de Pensiones', 'Sistema Nacional de Pensiones', 'Otro regimen pensionario', 'No precisa')),
	regimen_salud varchar(50) not null check (regimen_salud in ('ESSALUD', 'ESSALUD Agrario', 'SIS', 'No precisa')),
	sindicalizado varchar(2) not null check (sindicalizado in ('Si', 'No')),
	sctr varchar(100) not null check (sctr in ('Con sctr', 'Sin sctr', 'No precisa')),
	remuneracion decimal(10, 2) not null check (remuneracion >= 0),
	sst int not null check (sst in (0, 1))  -- Indicador de comité de seguridad
);



-- Modificar la tabla resumen para incluir fecha_declaracion
if exists (select name from sys.tables where name='resumen')
drop table resumen;

create table resumen (
    ruc varchar(11),
    fecha_declaracion date not null,
    
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

    -- Definimos una clave primaria compuesta por ruc y fecha_declaracion
    primary key (ruc, fecha_declaracion)
);
go 