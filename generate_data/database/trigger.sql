CREATE OR ALTER TRIGGER trg_actualizar_resumen
ON declaracion
AFTER INSERT
AS
BEGIN
    DECLARE @v_rm DECIMAL(10, 2) = 1025.00;  -- Cambia esto a la lógica para obtener la RMV actual

    DECLARE @ruc varchar(11);
    DECLARE @fecha_declaracion DATE;
    DECLARE cur CURSOR FOR 
        SELECT DISTINCT ruc, fecha_declaracion 
        FROM INSERTED;
    
    OPEN cur;
    FETCH NEXT FROM cur INTO @ruc, @fecha_declaracion;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Insertar en la tabla resumen si no existe un registro para la combinación de empresa y fecha
        IF NOT EXISTS (SELECT 1 FROM resumen WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion)
        BEGIN
            INSERT INTO resumen (ruc, fecha_declaracion)
            SELECT ruc, @fecha_declaracion FROM empresa WHERE ruc = @ruc;
        END

        -- Actualizar los campos en la tabla resumen
        UPDATE resumen
        SET 
            numtra = numtra + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion),

            num_mayor_rm = num_mayor_rm + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND remuneracion >= @v_rm),
            num_menor_rm = num_menor_rm + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND remuneracion < @v_rm),

            -- Resumen por tipos de contrato
            ntrab_tc_indet = ntrab_tc_indet + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND tipo_contrato = 'A plazo indeterminado'),
            ntrab_tc_nattemp = ntrab_tc_nattemp + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND tipo_contrato = 'De naturaleza temporal'),
            ntrab_tc_natacc = ntrab_tc_natacc + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND tipo_contrato = 'De naturaleza accidental'),
            ntrab_tc_obrserv = ntrab_tc_obrserv + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND tipo_contrato = 'De obra o servicio'),
            ntrab_tc_tiempar = ntrab_tc_tiempar + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND tipo_contrato = 'Tiempo parcial'),
            ntrab_tc_otros = ntrab_tc_otros + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND tipo_contrato NOT IN ('A plazo indeterminado', 'De naturaleza temporal', 'De naturaleza accidental', 'De obra o servicio', 'Tiempo parcial')),

            -- Resumen por régimen laboral
            ntrab_rl_privgen = ntrab_rl_privgen + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_laboral = 'General'),
            ntrab_rl_micro = ntrab_rl_micro + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_laboral = 'Micro empresa'),
            ntrab_rl_peq = ntrab_rl_peq + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_laboral = 'Pequena empresa'),
            ntrab_rl_agrar = ntrab_rl_agrar + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_laboral = 'Agrario'),
            ntrab_rl_otros = ntrab_rl_otros + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_laboral = 'Otros'),
            ntrab_rl_noprec = ntrab_rl_noprec + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_laboral = 'No precisa'),

            -- Resumen por régimen pensionario
            ntrab_rp_spp = ntrab_rp_spp + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_pensionario = 'Sistema Privado de Pensiones'),
            ntrab_rp_snp = ntrab_rp_snp + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_pensionario = 'Sistema Nacional de Pensiones'),
            ntrab_rp_otros = ntrab_rp_otros + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_pensionario = 'Otro regimen pensionario'),
            ntrab_rp_noprecrp = ntrab_rp_noprecrp + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_pensionario = 'No precisa'),

            -- Resumen por afiliación a salud
            ntrab_afil_essalud = ntrab_afil_essalud + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_salud = 'ESSALUD'),
            ntrab_afil_essalud_agrar = ntrab_afil_essalud_agrar + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_salud = 'ESSALUD Agrario'),
            ntrab_afil_sis = ntrab_afil_sis + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_salud = 'SIS'),
            ntrab_afil_noprec = ntrab_afil_noprec + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND regimen_salud = 'No precisa'),

			ntrab_sind = ntrab_sind + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND sindicalizado = 'Si'),
			ntrab_nosind = ntrab_nosind + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND sindicalizado = 'No'),

			ntrab_consctr = ntrab_consctr + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND sctr = 'Con sctr'),
			ntrab_sinsctr = ntrab_sinsctr + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND sctr = 'Sin sctr'),
			ntrab_sctr_noprec = ntrab_sctr_noprec + (SELECT COUNT(*) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion AND sctr = 'No precisa'),


            -- Resumen por edades usando JOIN con trabajador para obtener fecha_nac
            ntrab_18mas = ntrab_18mas + (SELECT COUNT(*) 
                                        FROM INSERTED i
                                        JOIN trabajador t ON i.dni = t.dni
                                        WHERE i.ruc = @ruc 
                                        AND i.fecha_declaracion = @fecha_declaracion 
                                        AND DATEDIFF(year, t.fecha_nac, GETDATE()) >= 18),

            ntrab_menos18 = ntrab_menos18 + (SELECT COUNT(*)
                                            FROM INSERTED i
                                            JOIN trabajador t ON i.dni = t.dni
                                            WHERE i.ruc = @ruc 
                                            AND i.fecha_declaracion = @fecha_declaracion 
                                            AND DATEDIFF(year, t.fecha_nac, GETDATE()) < 18),

            -- Resumen por género usando JOIN con trabajador para obtener genero
            ntrab_mujeres = ntrab_mujeres + (SELECT COUNT(*)
                                            FROM INSERTED i
                                            JOIN trabajador t ON i.dni = t.dni
                                            WHERE i.ruc = @ruc AND i.fecha_declaracion = @fecha_declaracion AND t.genero = 'Femenino'),

            ntrab_hombres = ntrab_hombres + (SELECT COUNT(*)
                                            FROM INSERTED i
                                            JOIN trabajador t ON i.dni = t.dni
                                            WHERE i.ruc = @ruc AND i.fecha_declaracion = @fecha_declaracion AND t.genero = 'Masculino'),

            ntrab_sexo_noprec = ntrab_sexo_noprec + (SELECT COUNT(*)
                                                    FROM INSERTED i
                                                    JOIN trabajador t ON i.dni = t.dni
                                                    WHERE i.ruc = @ruc AND i.fecha_declaracion = @fecha_declaracion AND t.genero = 'No Precisa'),

            -- Cálculo del costo salarial total
            costosal = costosal + (SELECT SUM(remuneracion) FROM INSERTED WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion)
            
        WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion;

        FETCH NEXT FROM cur INTO @ruc, @fecha_declaracion;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO