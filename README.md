# ib-summit2022-python
Ejemplos sesión Python - Iberia Summit 2022


## Dall-e2
### Install
```bash
pip install dalle2
````
Documentación adicional en el repositorio [dalle2-in-python](https://github.com/ezzcodeezzlife/dalle2-in-python)

### Pasos previos
Para poder hacer uso de la funcionalidad de obtener imágenes generadas automáticamente por Dall-e2, previamente tenemos que tener una cuenta en la plataforma, que nos permita generar imáganes desde su website y así poder capturar el bearer token que luego utilizaremos en nuestra herramienta.

1. Ve a https://openai.com/dall-e-2/
2. Crea una cuente en OpenAI
3. Ve a https://labs.openai.com/
4. Abre el inspector en tu navegador y ve a la pestaña de Red 
5. Escribe una petición de búsqueda de imagenes y pulsa "Generar"
6. Busca la petición a to https://labs.openai.com/api/labs/tasks
7. En la cabecera de la petición, busca por "authorization" y copia el "Bearer Token"
8. Pasa ese token al instanciar tu objeto Dalle2 para pedir imágenes desde Python

```python
from dalle2 import Dalle2
dalle = Dalle2("sess-xxxxxxxxxxxxxxxxxxxxxxxxxxxx") # your bearer key
```
