# Visualización Interactiva de Salud Mental y Bienestar Laboral (2014)

Este proyecto explora la relación entre la salud mental en el entorno laboral y las condiciones estructurales de cada país (felicidad, PIB, tasas de suicidio) a través de una visualización interactiva construida con **Plotly Dash**.

Combina datos del *Mental Health in Tech Survey (2014)*, el *World Happiness Report* y estadísticas de suicidio de la OMS.

---

## Estructura del repositorio
```
├── data/
│   ├── mental_health_clean_viz.csv        # Dataset enriquecido y tratado para uso con el script
│   ├── survey.csv                         # Dataset original
│   ├── who_suicide_statistics.csv         # Dataset de suicidio por país (OMS)
│   ├── World Happiness Report.csv         # Dataset de felicidad mundial (2014)
├── scripts/
│   ├── enrich_dataset.R                   # Script en R para limpieza y enriquecimiento
│   └── app.py                             # Aplicación Dash en Python
├── README.md
```
---

## Objetivo del proyecto

Explorar visualmente preguntas clave como:

- ¿Influyen las condiciones del país en la percepción de apoyo a la salud mental?
- ¿Existen diferencias de género en el acceso o el estigma?
- ¿Qué perfiles son más vulnerables a la falta de apoyo psicológico?
- ¿Hay relación entre felicidad nacional y disposición a hablar de salud mental?

---

## Limpieza y enriquecimiento de datos (R)

El archivo `scripts/enrich_dataset.R` realiza:

1. Limpieza de valores nulos y outliers
2. Recodificación de género para unificar grupos ya que el numero de indivuos incluido en algunos no era estadisticamente significativa
3. Unificación de nombres de países
4. Enriquecimiento con:
   - Tasa de suicidios (OMS)
   - Felicidad y PIB per cápita (World Happiness Report)

---
     
## Código en Python

Requiere los paquetes:
- pandas
- dash
- plotly

Para ejecutar:
1. Lanzar la aplicación con el comando python app.py en la carpeta donde esté el script
2. Abre el navegador en: http://127.0.0.1:8050

---

## Licencia

MIT License

Copyright (c) 2025 [Raul González]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
