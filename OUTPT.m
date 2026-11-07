function OUTPT(TQT, NES, CSUTIL, TNOW, NEE, LQ, CLQ)
%************************* FUNCION DE SALIDA  **************************
%
%
%   Calcula el tiempo medio de espera en la Cola (AWTQ) como
%   Estadistico de base observacion.
%
AWTQ = TQT/NES;
%
%   Calcula los promedios ponderados de los estadisticos de base tiempo
%   e imprime los resultados
%
ALQ = CLQ/TNOW;
%
ASUTIL = CSUTIL/TNOW;
%
fprintf('\n');
fprintf('Salida de la SIMULACION: ');
fprintf('\n');
fprintf('Numero de Entidades Entradas= %2.0d', NEE);
fprintf('\n');
fprintf('Numero de Entidades Servidas= %2.0d', NES);
fprintf('\n');
fprintf('LQ= %2.0d', LQ);
fprintf('\n');
fprintf('TNOW= %2.3f', TNOW);
fprintf('\n');
fprintf('CSUTIL= %2.3f', CSUTIL);
fprintf('\n');
fprintf('Tiempo Total Perdido en la Cola= %2.3f', TQT);
fprintf('\n');
fprintf('Promedio de tiempo de espera en la Cola= %2.3f', AWTQ);
fprintf('\n');
fprintf('Longitud Promedio (esperada) de la Cola= %2.3f', ALQ);
fprintf('\n');
PRO=ASUTIL*100;
fprintf('Promedio de Uso del Servidor= %2.3f', PRO);

