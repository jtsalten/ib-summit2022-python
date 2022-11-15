# Demo Python Embebido (Iberia Summit 2022). App de Generación de Tickets o Folletos para Eventos

En esta demo pretendemos construir la lógica de servidor para una pequeña aplicación que generaría tickets o folletos  para eventos, con un formato básico determinado:




Nos limitaremos a la lógica de backend, implementando las clases y métodos necesarios, así como los servicios REST para hacer uso de las distintas funcionalidades. El front-end podría basarse en Angular, React, Django,... o cualquier otro framework de desarrollo de UI. Desde este framework simplemente se llamaría a los servicios REST expuestos.

## Install

### Paquetes de Pypi.org para QR, PDF y Dall-E2

Desde el ``<irisdir>/bin`` ejecutamos:

```bash
irispip install --target <irisdir>/mgr/python "qrcode[pil]"
irispip install --target <irisdir>/mgr/python reportlab
irispip install --target <irisdir>/mgr/python openai
```

De este modo tendremos listos, en el Python que se ejecuta sobre el kernel de IRIS, los módulos de Python que necesitaremos para la demo.

### Aplicación Web

A través del Portal de Administración de IRIS, crearemos una nueva Aplicación Web para servicios REST, llamada ``/summit`` y asociada al namespace en que vayamos a importar nuestras clases e implementar nuestra lógica de negocio.

En esta aplicación web, la clase dispatcher de servicios REST deberá ser: ``OPNex.Py2022.RestDispatch``. Para facilitarnos las pruebas, en la definición de la aplicación web indicaremos que se permiten llamadas sin autenticar.

### Clases de IRIS

En el namespace de IRIS que hayamos elegido, cargar y compilar las clases incluidas en ``src/OPNex/Py2022``

## Demo

### Creación de un método en Python

En nuestra clase ``OPNex.Py2022.Evento`` añadimos el método Info(), escrito en Python, que devolverá un documento JSON con las propiedades del objeto.

```objectscript
Method Info() as %String [Language = python]
{
    import json

    doc = {}

    doc["Site"] = self.Site
    doc["Empresa"] = self.Empresa
    doc["Lema"] = self.Lema
    doc["ImgLema"] = self.ImgLema
    doc["ImgLogo"] = self.ImgLogo
    doc["Ciudad"] = self.Ubicacion.Ciudad

    return json.dumps(doc)
}
```

### Acceso a Clase y Objectos de IRIS desde la shell de Python

Desde el directorio ``<irisdir>/bin``, podemos entrar a la shell de Python que se ejecuta directamente sobre IRIS haciendo:

```bash
irispython 
```

> Importante: Previamente debes tener definidas las variables de entorno IRISUSERNAME / IRISPASSWORD / IRISNAMESPACE

Una vez dentro de la shell, podemos crear un nuevo evento y ejecutar el método Info() creado previamente.

```python
import iris
evento = iris.cls('OPNex.Py2022.Evento')._New()
evento.Site = "www.intersystems.com"
evento.Empresa = "InterSystems"
evento.Lema = "Python is the milk"
evento.ImgLema = "/_DEMOS/ib-summit2022/imagenes/img-default.jpg"
evento.Ubicacion.Ciudad = "Valencia"
evento._Save()
evento.Info()
```

### Clase de servicios REST

Puedes abrir la clase ``OPNex.Py2022.RestDispatch`` para ver los servicios que vamos a tener. Los iremos completando poco a poco.

### Implementación de las funcionalidades básicas

Implementaremos la lógica necesaria para cubrir lo que necesitamos en nuestra aplicación en la clae ``OPNex.Py2022.Tools``.

#### Método pyQR() - Creación de códigos QR

Descomentar el código del método para que sea funcional. Importa el paquete ``qrcode``, genera un nombre de fichero donde almacenar el QR, crea el objeto QRcode y lo carga como datos lo indicado en el parámetro ``pData``. Por último llama a ``make_image`` indicándole que genere el fichero con el código QR y una imagen embebida en él (en principio se trataría del logo).

Podemos ahora probar la funcionalidad desde REST. Para ello abrimos la clase ``OPNex.Py2022.RestDispatch`` y vamos al método ``GeneratesQR``, comentamos descomentamos las líneas que indico abajo:

```objectscript
 //Comentar esta línea
 //do tFile.LinkToFile(..#BASEIMGDIR_"/QR-test.jpg")
 
 //Descomentar estas líneas
 do tFile.LinkToFile(##class(OPNex.Py2022.Tools).pyQR(tJSON.link, tLogo, tTempDir))
 set tFile.RemoveOnClose = 1
```

Una vez hecho, compilamos la clase y desde un cliente REST, como por ejemplo PostMan, podemos lanzar la llamada:

```html
POST <hostname-ip:puerto>/summit/qr
```

>Importante: El servicio espera un documento JSON en el body, con el formato:
> ```json
 >{"link":"www....", "logo":true}
> ```
>        

#### Método pySimplePDF() - Creación de un fichero PDF

Descomentar el código del método para que sea funcional. Importa la clase ``canvas`` del paquete ``reportlab``. Sobre los objetos de tipo ``canvas`` "dibujaremos" nuestro PDF. Decidimos el tamaño de página de nuestro archivo PDF y la ruta física para almacenarlo. Hecho esto, simplemente "pintamos" una imagen, un texto, ... lo que queramos. Tenemos que tener en cuenta que el eje de coordenadas del documento PDF, se situa en la esquina inferior izquierda.

Podemos ahora probar la funcionalidad desde REST. Para ello abrimos la clase ``OPNex.Py2022.RestDispatch`` y vamos al método ``GetSimplePDF``, comentamos descomentamos las líneas que indico abajo:

```objectscript
 //Comentamos esta línea
 //do tFile.LinkToFile(..#BASEIMGDIR_"/SimplePDF-test.pdf")
 
 //Descomentamos estas líneas
 do tFile.LinkToFile(##class(OPNex.Py2022.Tools).pySimplePDF(pImg,pText))
 set tFile.RemoveOnClose = 1
```

Una vez hecho, compilamos la clase y desde nuestro cliente REST podemos lanzar la llamada:

```html
GET <hostname-ip:puerto>/summit/simplePDF
```

#### Método pyDallE2() - Obtención de imágenes a partir de texto de Dall-E2 (beta.openai.com)

En este caso el método hace uso del paquete ``openai`` que nos permite acceder a la funcionalidad del proyecto Dall-E2. La funcionalidad basicamente consiste en generar imágenes que representen una cadena de texto.

Por no ser repetitivo, el método es ya completamente funcional. No hace falta comentar/descomentar nada.

Podemos usarlo vía REST, con la llamada:

```html
GET <hostname-ip:puerto>/summit/dalle2/A cow in outer space
```

#### Método OPNex.Py2022.Evento:AsociaImgLema() - Generando una imagen acorde al lema

Si al crear un evento todavía no tenemos una imagen asociada al lema del evento, podemos obtenerla simplemente llamando al método ``AsociaLema()`` implementado en la clase (el método está implementado en Python).

```objectscript
 set tEvento = ##class(OPNex.Py2022.Evento).%OpenId(1)
 do tEvento.AsociaImgLema()
 do tEvento.%Save()
```

El método hace uso de la funcionalidad del proyecto Dall-E2 que hemos incorporado en nuestra aplicación importando el paquete ``openai`` y con el pequeño desarrollo del método ``pyDallE2()`` que hemos visto más arriba.

Podemos usarlo vía REST, con la llamada:

```html
GET <hostname-ip:puerto>/summit/evento/generaimg/<:eventoID>
```

Indicando en la llamada el ID (:eventoID) del objeto evento para el que queremos generar una nueva imagen de lema. 

### Resultado Final

Hasta aquí ya hemos visto todos los bloques que necesitamos para construir nuestra pequeña aplicación de generación de tickets o folletos para eventos.

El resultado final lo tenemos ya implementado. Para verlo como servicio REST, podemos hacer la llamada:

```html
GET <hostname-ip:puerto>/summit/evento/ticket/<:eventoID>
```

Indicando en la llamada el ID (:eventoID) del objeto evento para el que queremos generar el ticket o folleto.
