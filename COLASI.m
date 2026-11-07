function COLASI()

% cola simple - 1 servidor - (VERSION MATLAB)
% (Tiempo Uniforme Entre Arribos y de Servicio)
% CAPACIDAD MAXIMA DE LA COLA = 200 ENTIDADES 
%
%  DEFINICION DE VARIABLES:
%
% ALQ          Longitud media de la cola
% ASULTIL      Utilizacion media del Servidor
% ATTRIB(I)    Atributo (tiempo de arribo) de la entidad I a la cola
% BUSY         variable binaria (0,1) que representa el estado del servidor
% CLQ          Longitud acumulada de la cola
% CSUTIL       Utilizacion acumulada del servidor
% LQ           Longitud actual de la cola
% LS           Longitud de simulacion en unidades de tiempo
% MINIAT       Tiempo minimo entre arribos
% MAXIAT       Tiempo Maximo entre arribos
% MINST        Tiempo Minimo de Servicio
% MAXST        Tiempo Maximo de Sevicio
% NEE          Numero Total de Entidades que entran en el Sistema
% NES          Numero Total de Entidades Servidas
% QLIMIT       Capacidad Maxima de la Cola
% TLE          Tiempo del último evento
% TNA          Tiempo del proximo arribo
% TND          Tiempo de la proxima partida
% TNOW         Tiempo actual de la Simulacion (Master Clock)
% TQT          Tiempo Total en la Cola

%corte         Bandera de corte de la simulacion para cuando se cumpla
%              el tiempo solicitado

%********************     INICIALIZACION      *********************
QLIMIT = 200;
ATTRIB = zeros(QLIMIT,1);
BUSY = 0; LQ = 0; NEE = 0; NES = 0; CLQ = 0; CSUTIL = 0; TQT = 0; TNOW = 0;
%
%  Programa el primer arribo en el tiempo 0. Fija el tiempo de la proxima
%  partida en un numero grande
%
TNA = 0;
TND = 99999;
%
%*********************** ENTRADA DE DATOS ************************
disp('"-PARAMETROS DE ENTRADA-"');
fprintf('\n');
LS = input('Longitud de la simulacion en unidades de tiempo: ');
MINIAT = input('Tiempo Minimo Entre-arribos: '); 
MAXIAT = input('Tiempo Maximo Entre-arribos: '); 
MINST = input('Tiempo Minimo de Servicio: '); 
MAXST = input('Tiempo Maximo de Servicio: ');
%
%*********************** (MOTOR DE LA SIMULACION)   ****
%
%
%   Fija el Tiempo del Ultimo Evento (TLE) igual a TNOW antes de avanzar TNOW
%   hasta el Tiempo del Proximo evento (TNE)
%
%
%   Busca cual es el minimo tiempo para la proxima partida del servidor
%   Compara los tiempos de los dos eventos posibles siguientes
%   y fija TNOW igual al tiempo menor. Llama a la rutina de eventos asociada
%   Si TNOW excede la longitud de simulacion retorna a PRINCIPAL
%
%
    
  corte=0;
  
  while corte==0
    
    TLE = TNOW; 
      
    if (TNA < TND)
       
        TNOW = TNA;
        if (TNOW >= LS)
            %**************** ACTIVA LA BANDERA DE CORTE Y LLAMA A LA
            %FUNCION DE SALIDA PARA MOSTRAR LOS RESULTADOS *************
            corte=1;
            OUTPT(TQT, NES, CSUTIL, TNOW, NEE, LQ, CLQ); 
        else
            %********************* EVENTOS DE LLEGADA*********************
            %
            [NEE, TNA, BUSY, LQ, ATTRIB, TND]=ARRIBE(NEE, TNOW, MINIAT, MAXIAT, BUSY, LQ, QLIMIT, ATTRIB, MINST, MAXST, TND);
                     
        end
  
    else
        
        TNOW = TND;
        
        if (TNOW >= LS)
            %**************** ACTIVA LA BANDERA DE CORTE Y LLAMA A LA
            %FUNCION DE SALIDA PARA MOSTRAR LOS RESULTADOS *************
            corte=1;
            OUTPT(TQT, NES, CSUTIL, TNOW, NEE, LQ, CLQ); 
        else
            %******************** EVENTOS DE PARTIDA *******************
            %
            [NES, TQT, BUSY, LQ, ATTRIB, TND]=DEPART(NES, LQ, TNOW, ATTRIB, TQT, MINST, MAXST, BUSY);
            
            
        end
    end
        %****************** Llama la funcion STAT para actualizar las estadisticas de base tiempo ******************
        %
        
        [CLQ, CSUTIL]=STAT(CLQ, LQ, TNOW,TLE, CSUTIL, BUSY);
                   
  end