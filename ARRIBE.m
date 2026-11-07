function [NEE, TNA, BUSY, LQ, ATTRIB, TND] = ARRIBE(NEE, TNOW, MINIAT, MAXIAT, BUSY, LQ, QLIMIT, ATTRIB, MINST, MAXST, TND)
%********************* FUNCION EVENTOS DE LLEGADA*********************
%
%   Incrementa el numero total de Entidades que Entran en el sistema.
%
NEE = NEE+1;
%
%   Programa el proximo arribo
%
TNA = TNOW+MINIAT+(MAXIAT - MINIAT)*rand(1);
%
%
%   Si el servidor esta ocupado se incrementa la longitud de la Cola
%   Si el tamano de la Cola excede el limite, se
%   imprime un mensaje de error y se detiene la ejecucion.
%   Si no se excede QLIMIT se fija el atributo de la entidad que arriba
%   igual a su tiempo de arribo. Retorno a la rutina de eventos.
%

if (BUSY == 1) 
   LQ = LQ + 1;
   if (LQ > QLIMIT) 
       disp(' Error - Overflow en la Cola! (LQ>100)')
       ATTRIB(LQ) = TNOW;
         
   end
   
   TND=TND;
     
else
%
%   Si se encontro el servidor desocupado, se lo ocupa (BUSY=1)
%   Se asigna la Entidad recien arribada al servidor desocupado.
%   Se calcula el tiempo de Servicio (TS) para la entidad.
%   Se programa el tiempo de partida para la Entidad.
%
    BUSY = 1;
    TS = MINST + (MAXST - MINST) * rand(1);
    TS = fix(TS * 100)/100;
    TND = TNOW + TS;
   
end

