# Integrador de Cálculo Numérico - Grupo 3

Simulador de una cola simple desarrollado en MATLAB como punto de partida para el trabajo integrador de Cálculo Numérico.

**Integrantes:** Sofía Guardia y Jesús Casabillanos.

## Estado del proyecto

Los archivos actuales implementan el modelo base de **una cola, un servidor y tiempos entre arribos y de servicio uniformes**. La capacidad de cola está configurada en 200 entidades.

Los cuatro modelos mencionados en la consigna (capacidad finita con pérdidas, dos servidores, dos colas y abandono por espera) son ampliaciones del modelo base y **no están implementados en estos archivos todavía**.

## Archivos

| Archivo | Responsabilidad |
| --- | --- |
| `COLASI.m` | Inicializa el sistema, solicita los parámetros y ejecuta el motor de eventos. |
| `ARRIBE.m` | Procesa un arribo, agenda el siguiente y comienza el servicio si el servidor está libre. |
| `DEPART.m` | Procesa una partida y, si hay clientes esperando, inicia el servicio del siguiente. |
| `STAT.m` | Acumula la longitud de cola y el tiempo ocupado del servidor. |
| `OUTPT.m` | Calcula e imprime los resultados de la simulación. |

## Requisitos

- MATLAB.
- Los cinco archivos `.m` en la misma carpeta.

## Cómo ejecutar

1. Abrir MATLAB y establecer como carpeta actual la carpeta del proyecto.
2. Ejecutar en la ventana de comandos:

   ```matlab
   COLASI
   ```

3. Ingresar los parámetros que solicita el programa:
   - Longitud de la simulación (`LS`).
   - Tiempo mínimo y máximo entre arribos (`MINIAT`, `MAXIAT`).
   - Tiempo mínimo y máximo de servicio (`MINST`, `MAXST`).

Los intervalos entre arribos y los tiempos de servicio se generan con `rand`, por lo que las corridas pueden dar resultados distintos. Para reproducir una corrida se puede fijar la semilla antes de ejecutar, por ejemplo con `rng(1)`.

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

Esta versión es una base para desarrollar y verificar el modelo; antes de interpretar sus resultados como definitivos, deben revisarse estos aspectos:

- `ARRIBE.m` no guarda la hora de llegada de cada cliente que entra a la cola. Por eso el tiempo de espera que calcula `DEPART.m` con `ATTRIB` no es confiable.
- La actualización de `STAT.m` se ejecuta después de procesar el evento. Para acumular correctamente el intervalo transcurrido, las estadísticas deben usar el estado del sistema que existía antes de ese evento.
- El límite `QLIMIT = 200` no implementa un rechazo seguro: al excederlo, `ARRIBE.m` muestra un mensaje, pero no descarta correctamente al cliente y puede acceder fuera del tamaño de `ATTRIB`.
- El programa detiene la simulación cuando el siguiente evento está en o después de `LS`. En ese caso reporta ese instante de evento como `TNOW`, que puede ser posterior a `LS`.
- `OUTPT.m` calcula promedios dividiendo por `NES` y `TNOW`; si alguno vale cero, el resultado no está definido.
- Los parámetros ingresados no tienen validaciones de rango.

## Ampliaciones previstas según la consigna

Estas reglas describen el comportamiento esperado de los incisos, no funcionalidades disponibles en el simulador actual:

1. **Cola con capacidad finita:** limitar la cantidad de clientes esperando y contar los arribos bloqueados cuando la cola esté llena.
2. **Dos servidores en paralelo:** asignar primero al servidor 1 si ambos están libres y mantener la utilización de cada servidor por separado.
3. **Dos colas y un servidor:** enviar cada arribo a la cola más corta (desempate a favor de la cola 1) y atender la cola más larga (también con desempate a favor de la cola 1).
4. **Abandono por espera:** registrar el instante de arribo de cada cliente en cola y procesar un evento de abandono al superar el tiempo máximo de espera definido.

Una verificación útil para el modelo base es la conservación de entidades:

```text
NEE = NES + LQ + BUSY
```

La igualdad debe evaluarse en un instante consistente y con contadores que incluyan las entidades que efectivamente ingresaron al sistema. En los modelos con bloqueos o abandonos, la ecuación debe incluir además esos resultados.
