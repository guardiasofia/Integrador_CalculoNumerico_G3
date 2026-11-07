function [CLQ, CSUTIL]=STAT(CLQ, LQ, TNOW, TLE, CSUTIL, BUSY)
%****************** FUNCION DE ESTADISTICAS BASE TIEMPO ******************
%
%
%   Calcula la longitud acumulada de la Cola y la Utilizacion del Servidor
%   actualizando los valores que tenian en el ultimo evento.
%

CLQ = CLQ+LQ*(TNOW - TLE);
CSUTIL=CSUTIL+BUSY*(TNOW-TLE);


