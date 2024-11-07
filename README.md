# LaboraTech2024: RegulaPRO

---

## Descripción del Problema

En Perú, la formalización de empresas y el cumplimiento de la normativa laboral y de seguridad y salud en el trabajo (SST) son desafíos críticos, especialmente para empresas que desean expandirse al mercado internacional, como el de la Unión Europea. La informalidad laboral sigue siendo un obstáculo importante, limitando el acceso a nuevos mercados y disminuyendo la competitividad. Además, las regulaciones internacionales exigen altos estándares de cumplimiento, lo que impone barreras adicionales para las empresas peruanas.

Para exportar a mercados como la UE, las empresas deben cumplir con normativas estrictas, como el Reglamento (UE) 2023/1115, que exige una declaración de debida diligencia en materia de SST y normativa laboral. La necesidad de un sistema que facilite la generación de documentos oficiales de cumplimiento y declaraciones juradas es vital para apoyar la competitividad y reducir la informalidad laboral en el país.

---

## Solución Propuesta: LaboraTech RegulaPRO

**LaboraTech RegulaPRO** es una plataforma innovadora diseñada para simplificar el cumplimiento de la normativa laboral y de SST, ayudando a las empresas a cumplir con los requisitos locales e internacionales mediante la automatización y el acceso a datos oficiales. La plataforma permite generar documentación formal de manera eficiente, reduciendo el esfuerzo manual y el riesgo de errores humanos.

---

### Características Principales

1. **Extracción de Datos Automatizada**  
   Integración con las APIs de SUNAT y RENIEC para obtener datos precisos de empresas y trabajadores, eliminando el ingreso manual de información y asegurando la actualización en tiempo real.

2. **Validación Automática de Cumplimiento Normativo**  
   LaboraTech RegulaPRO realiza consultas automáticas para validar el cumplimiento de cada empresa y trabajador con la normativa laboral y de SST en tiempo real.

3. **Generación de Documentos PDF con IA**  
   La plataforma genera documentos formales en PDF, como informes y declaraciones juradas, utilizando una plantilla predefinida. Además, se integran observaciones personalizadas generadas mediante inteligencia artificial para orientar a las empresas hacia prácticas más formales y transparentes.

4. **Cumplimiento Normativo Internacional**  
   La solución se adapta a los estándares europeos, permitiendo a las empresas acceder a mercados internacionales y cumplir con los requisitos de debida diligencia en las exportaciones.

5. **Reducción de la Informalidad**  
   Al facilitar el proceso de formalización, LaboraTech RegulaPRO promueve la incorporación de pequeñas y medianas empresas en la economía formal, contribuyendo al crecimiento del sector formal en Perú.

---

### Arquitectura del Sistema

El sistema se basa en una arquitectura de extracción y modelado de datos que centraliza la información de empresas y trabajadores en una base de datos SQL. Las principales funcionalidades están soportadas por `Triggers` y `Stored Procedures` que aseguran la actualización automática de datos y el acceso a información en tiempo real.

#### Flujo de Datos

1. **Extracción de Información**  
   Los datos se obtienen directamente desde SUNAT y RENIEC mediante los identificadores únicos RUC y DNI, y se almacenan en tablas organizadas para su posterior análisis.

2. **Generación de Documentos PDF**  
   Los datos extraídos se utilizan para llenar una plantilla de documento, generando informes y declaraciones juradas en PDF, asegurando precisión y consistencia en el formato.

3. **Observaciones Automáticas con IA**  
   Se emplea la API de OpenAI para generar observaciones inteligentes que se añaden al documento final, proporcionando análisis personalizados para cada empresa.

---

### Impacto y Proyección

1. **Mejora en el Acceso al Mercado Internacional**  
   LaboraTech RegulaPRO permite a las empresas cumplir con las normativas laborales exigidas en el mercado europeo, facilitando la exportación de productos peruanos.

2. **Reducción de la Informalidad**  
   Al simplificar la obtención de documentación de cumplimiento, la plataforma contribuye a reducir la informalidad laboral en sectores clave.

3. **Escalabilidad y Expansión**  
   La plataforma está diseñada para integrar información tributaria y permisos sectoriales, así como para implementarse en centros de formalización regionales en todo el país.
