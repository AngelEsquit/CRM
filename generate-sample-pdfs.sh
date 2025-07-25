#!/bin/bash

echo "🔧 Creating sample-files directory..."
mkdir -p sample-files

echo "📄 Generating PDF files using pandoc..."

# Function to create PDF from markdown content
create_pdf() {
    local content="$1"
    local filename="$2"
    
    echo "$content" | pandoc -f markdown -t pdf -o "sample-files/$filename"
    echo "✅ Created: sample-files/$filename"
}

# Generate all PDF files (matching your database data)

create_pdf "# Tonometría de Aire

**Paciente:** Juan Pérez  
**Fecha:** 2023-01-15  

## Resultados
- **Ojo Derecho:** 16 mmHg
- **Ojo Izquierdo:** 14 mmHg

## Observaciones
Presiones intraoculares normales. No signos de glaucoma." "tonometria_1_20230115.pdf"

create_pdf "# Campo Visual 30-2

**Paciente:** Juan Pérez  
**Fecha:** 2024-02-10  

## Resultados
- **MD (Mean Deviation):** -1.2 dB
- **PSD (Pattern Standard Deviation):** 2.1 dB

## Observaciones
Campo visual dentro de límites normales para la edad." "campovisual_1_20240210.pdf"

create_pdf "# Topografía Corneal

**Paciente:** María González  
**Fecha:** 2023-03-08  

## Mediciones
- **K1:** 43.2 D @ 180°
- **K2:** 44.1 D @ 90°
- **Astigmatismo:** 0.9 D

## Observaciones
Morfología corneal normal. Astigmatismo leve." "topografia_2_20230308.pdf"

create_pdf "# Test de Schirmer

**Paciente:** María González  
**Fecha:** 2023-09-14  

## Resultados
- **Ojo Derecho:** 12 mm en 5 minutos
- **Ojo Izquierdo:** 10 mm en 5 minutos

## Observaciones
Producción lagrimal ligeramente disminuida.

## Recomendaciones
- Uso de lágrimas artificiales según necesidad
- Control en 6 meses" "schirmer_2_20230914.pdf"

create_pdf "# Retinografía

**Paciente:** Paciente #3  
**Fecha:** 2023-02-20  

## Hallazgos
- **Disco óptico:** Normal
- **Mácula:** Sin alteraciones
- **Vasos retinianos:** Calibre normal

## Observaciones
Retina sin alteraciones patológicas.

## Recomendaciones
Control anual de rutina." "retino_3_20230220.pdf"

create_pdf "# OCT Macular

**Paciente:** Paciente #3  
**Fecha:** 2023-11-30  

## Mediciones
- **Espesor foveal central:** 248 um
- **Volumen macular:** 8.2 mm³

## Hallazgos
- Arquitectura macular preservada
- Sin signos de edema macular
- Capas retinianas bien definidas

## Observaciones
OCT macular normal." "oct_3_20231130.pdf"

create_pdf "# Topografía Corneal Pentacam

**Paciente:** Paciente #4  
**Fecha:** 2023-04-12  

## Mediciones Centrales
- **K1:** 43.2 D @ 180°
- **K2:** 44.1 D @ 90°
- **Astigmatismo corneal:** 0.9 D

## Paquimetría
- **Espesor central:** 545 um
- **Punto más delgado:** 542 um

## Observaciones
Córnea de morfología y espesor normales." "pentacam_4_20230412.pdf"

create_pdf "# Biomicroscopía Anterior

**Paciente:** Paciente #5  
**Fecha:** 2024-03-18  

## Hallazgos por Estructura

### Párpados y Pestañas
- Sin alteraciones

### Conjuntiva
- Leve hiperemia conjuntival

### Córnea
- Transparente, sin infiltrados

### Cámara Anterior
- Profundidad normal, sin células

### Iris
- Patrón normal, pupilas reactivas

## Observaciones
Segmento anterior normal con leve irritación conjuntival." "biomicro_5_20240318.pdf"

create_pdf "# Retinoscopía

**Paciente:** Paciente #6  
**Fecha:** 2024-01-22  

## Resultados

### Ojo Derecho
- **Esfera:** -2.00 D
- **Cilindro:** -0.50 D × 180°

### Ojo Izquierdo  
- **Esfera:** -1.75 D
- **Cilindro:** -0.25 D × 15°

## Observaciones
Miopía leve bilateral con astigmatismo mínimo.

## Recomendaciones
- Corrección óptica permanente
- Control anual" "retinoscopia_6_20240122.pdf"

create_pdf "# Adaptometría

**Paciente:** Paciente #7  
**Fecha:** 2023-10-11  

## Parámetros Evaluados
- **Tiempo de adaptación:** 6.2 minutos
- **Sensibilidad final:** 4.8 log unidades
- **Pendiente de recuperación:** Normal

## Resultados
Función de adaptación a la oscuridad dentro de parámetros normales.

## Interpretación
- Función retiniana conservada
- Sin signos de degeneración retiniana
- Capacidad de visión nocturna normal" "adaptometria_7_20231011.pdf"

echo "🎉 All PDF files created successfully!"
echo "📁 Generated files:"
ls -la sample-files/*.pdf
echo ""
echo "📊 File count: $(ls sample-files/*.pdf | wc -l) PDFs"
