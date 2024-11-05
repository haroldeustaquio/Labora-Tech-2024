CREATE OR ALTER PROCEDURE sp_obtener_resumen_por_empresa_y_fecha
    @ruc INT,
    @fecha_declaracion DATE
AS
BEGIN
    -- Seleccionar los datos de la tabla resumen según los parámetros de entrada
    SELECT *
    FROM resumen
    WHERE ruc = @ruc AND fecha_declaracion = @fecha_declaracion;
END;
GO