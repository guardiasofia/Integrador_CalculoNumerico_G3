# Integrador de Cálculo Numérico - Grupo 3

Simulador de una cola simple desarrollado para **GNU Octave** como punto de partida para el trabajo integrador de Cálculo Numérico.

**Integrantes:** Sofía Guardia y Jesús Casabillanos.

## Estado del proyecto

Los archivos originales implementan el modelo base de **una cola, un servidor y tiempos entre arribos y de servicio uniformes**. La función `cola(p)` implementa además las cuatro variantes de la consigna.

## Archivos

| Archivo | Responsabilidad |
| --- | --- |
| `cola.m` | Ejecuta cualquiera de los cuatro modelos y devuelve sus estadísticas en un struct. |
| `COLASI.m` | Inicializa el sistema, solicita los parámetros y ejecuta el motor de eventos. |
| `ARRIBE.m` | Procesa un arribo, agenda el siguiente y comienza el servicio si el servidor está libre. |
| `DEPART.m` | Procesa una partida y, si hay clientes esperando, inicia el servicio del siguiente. |
| `STAT.m` | Acumula la longitud de cola y el tiempo ocupado del servidor. |
| `OUTPT.m` | Calcula e imprime los resultados de la simulación. |

## Requisitos

- GNU Octave instalado en el equipo.
- Extensión de GNU Octave para Visual Studio Code (opcional, facilita la edición y ejecución desde el editor).
- Los archivos `.m` del proyecto en la misma carpeta.

> **Importante:** la extensión de VS Code no reemplaza a GNU Octave. La extensión integra el editor con el intérprete; también hay que instalar GNU Octave por separado. Se puede obtener desde [octave.org/download](https://www.octave.org/download).

### Comprobar la instalación

Abrir la terminal integrada de VS Code y ejecutar:

```powershell
octave --version
```

Si aparece un mensaje indicando que `octave` no se reconoce, GNU Octave puede no estar instalado o su carpeta de instalación no está agregada a `PATH`. En ese caso, completar la instalación y agregar Octave al `PATH` de Windows; después, cerrar y volver a abrir VS Code para que la terminal actualice el `PATH`.

### Ejecutar el simulador

1. Abrir en VS Code la carpeta del proyecto y abrir una terminal integrada en esa carpeta.
2. Iniciar Octave desde la terminal:

   ```powershell
   octave --no-gui
   ```

3. En el indicador de Octave, ejecutar:

   ```octave
   COLASI
   ```

4. Ingresar los parámetros que solicita el programa:
   - Longitud de la simulación (`LS`).
   - Tiempo mínimo y máximo entre arribos (`MINIAT`, `MAXIAT`).
   - Tiempo mínimo y máximo de servicio (`MINST`, `MAXST`).

Para salir del indicador de Octave, ejecutar `exit`. Los intervalos entre arribos y los tiempos de servicio se generan con `rand`, por lo que las corridas pueden dar resultados distintos. Para reproducir una corrida se puede fijar la semilla antes de ejecutar, por ejemplo con `rng(1)`.

## Funcionamiento del modelo base

El simulador es de **eventos discretos**: el reloj salta al próximo arribo o partida, en lugar de avanzar de a una unidad de tiempo.

- `TNOW`: tiempo actual de la simulación.
- `TNA`: instante del próximo arribo.
- `TND`: instante de la próxima partida.
- `BUSY`: indica si el servidor está ocupado (`1`) o libre (`0`).
- `LQ`: cantidad de entidades esperando en la cola.
- `NEE`: cantidad de arribos procesados.
- `NES`: cantidad de entidades cuyo servicio terminó.
- `CLQ`: área acumulada de la longitud de cola.
- `CSUTIL`: tiempo acumulado de ocupación del servidor.
- `TQT`: tiempo acumulado de espera en cola.

En cada iteración, `COLASI` compara `TNA` y `TND`, avanza `TNOW` hasta el evento más próximo y llama a `ARRIBE` o `DEPART`. `STAT` acumula las estadísticas y `OUTPT` presenta los resultados al finalizar.

El primer arribo está programado en el tiempo cero. Si el servidor está libre, el cliente comienza el servicio; si está ocupado, el cliente se agrega a la cola. Cuando termina un servicio, se atiende al siguiente cliente si lo hay.

## Resultados reportados

La salida muestra, entre otros valores:

- Entidades que arribaron y entidades servidas.
- Longitud de cola al finalizar.
- Tiempo de simulación y tiempo acumulado del servidor ocupado.
- Tiempo total y promedio de espera en cola.
- Longitud promedio de la cola y porcentaje de uso del servidor.

Las estadísticas de base tiempo se obtienen dividiendo las áreas acumuladas por el tiempo observado. Por ejemplo, la longitud promedio se calcula como `CLQ/TNOW` y la utilización como `CSUTIL/TNOW`.

## Observaciones sobre la implementación actual

Los siguientes aspectos corresponden a la implementación original del modelo base (`COLASI.m` y sus rutinas), no a `cola.m`:

- `ARRIBE.m` no guarda la hora de llegada de cada cliente que entra a la cola. Por eso el tiempo de espera que calcula `DEPART.m` con `ATTRIB` no es confiable.
- La actualización de `STAT.m` se ejecuta después de procesar el evento. Para acumular correctamente el intervalo transcurrido, las estadísticas deben usar el estado del sistema que existía antes de ese evento.
- El límite `QLIMIT = 200` no implementa un rechazo seguro: al excederlo, `ARRIBE.m` muestra un mensaje, pero no descarta correctamente al cliente y puede acceder fuera del tamaño de `ATTRIB`.
- El programa detiene la simulación cuando el siguiente evento está en o después de `LS`. En ese caso reporta ese instante de evento como `TNOW`, que puede ser posterior a `LS`.
- `OUTPT.m` calcula promedios dividiendo por `NES` y `TNOW`; si alguno vale cero, el resultado no está definido.
- Los parámetros ingresados no tienen validaciones de rango.

## Modelos de la consigna en `cola(p)`

Los cuatro modelos se pueden ejecutar con la función `cola(p)`, que comparte un único motor de eventos discretos. Los archivos originales (`COLASI.m`, `ARRIBE.m`, `DEPART.m`, `STAT.m` y `OUTPT.m`) se mantienen como implementación interactiva del modelo base.

| `p.modelo` | Variante |
| --- | --- |
| `1` | Un servidor y cola de capacidad finita. `p.QLIMIT` vale 10 si se omite. |
| `2` | Dos servidores en paralelo y una cola compartida; se elige primero el servidor 1. |
| `3` | Un servidor y dos colas; los arribos eligen la más corta y el servidor la más larga. |
| `4` | Un servidor y abandono cuando se alcanza el tiempo máximo de espera. `p.TMAXWAIT` vale 3 si se omite. |

Ejemplo desde GNU Octave, en la carpeta del proyecto:

```octave
p = struct('modelo', 1, 'LS', 1000, ...
           'MINIAT', 1, 'MAXIAT', 3, ...
           'MINST', 1, 'MAXST', 2);
res = cola(p)
```

La función devuelve las estadísticas en `res`, entre ellas `NEE`, `NES`, `LQ`, `Nbloq`, `Naband`, `AWTQ`, `ALQ` y la utilización promedio `ASUTIL`. En el modelo 2, `ASUTIL1` y `ASUTIL2` informan la utilización de cada servidor por separado. En el modelo 3, `ALQ1` y `ALQ2` son los promedios separados por cola.

La simulación observa el intervalo `[0, LS)`: no procesa eventos que ocurran exactamente en `LS`, pero acumula las estadísticas hasta ese instante. En el modelo 4, una entidad abandona al alcanzar `TMAXWAIT`; si ese instante coincide con una partida, se procesa primero la partida. `res.conservacion` debe ser cero y permite comprobar que los arribos procesados coinciden con las entidades servidas, en cola, en servicio, bloqueadas o abandonadas.

### Probar `cola.m`

Desde la terminal integrada de VS Code, ubicada en la carpeta del proyecto, se puede hacer una corrida reproducible del modelo 1 y comprobar la conservación de entidades:

```powershell
octave --quiet --eval "p=struct('modelo',1,'LS',1000,'MINIAT',1,'MAXIAT',3,'MINST',1,'MAXST',2); rand('twister',42); r=cola(p); disp(r); assert(r.conservacion==0)"
```

Para probar individualmente los otros modelos, cambiar `'modelo',1` por `'modelo',2`, `'modelo',3` o `'modelo',4`. La semilla fija (`42`) hace que la corrida sea repetible.

Para ejecutar 30 réplicas de cada uno de los cuatro modelos y revisar que se conserve el número de entidades en todas ellas:

```powershell
octave --quiet --eval "correr_experimentos"
```

El resumen muestra `Conservacion OK en todas las replicas: 1` cuando la comprobación pasa. Los comandos adicionales de reproducibilidad y pruebas de estrés están en [`reproduccion.txt`](./reproduccion.txt).

Una verificación útil para el modelo base es la conservación de entidades:

```text
NEE = NES + LQ + BUSY
```

La igualdad debe evaluarse en un instante consistente y con contadores que incluyan las entidades que efectivamente ingresaron al sistema. En los modelos con bloqueos o abandonos, la ecuación debe incluir además esos resultados.
