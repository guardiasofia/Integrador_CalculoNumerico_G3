function [NES, TQT, BUSY, LQ, ATTRIB, TND]=DEPART(NES, LQ, TNOW, ATTRIB, TQT, MINST, MAXST, BUSY)
%******************** FUNCION EVENTOS DE PARTIDA *******************
%
%   Se Incrementa el Numero total de Entidades Servidas
%
NES = NES + 1;
%
%   Si la cola esta vacia se pone el Servidor
%   en disponibilidad (BUSY=0).
%   La proxima partida puede no estar programada por lo que se hace
%   TND igual a un numero grande.
%
if (LQ == 0) 
    BUSY = 0; TND = 99999; 
    
else
%
%   Si la cola no esta vacia, se calcula el tiempo de espera en la cola
%   para la entidad que comienza su servicio.
%   Se calcula el tiempo total en la Cola y se decrementa la longitud de
%   la misma.
%
    BUSY=BUSY;
    QT = TNOW - ATTRIB(1);
    TQT = TQT + QT;
    LQ = LQ - 1;
%
%   Se desplaza los valores de los atributos una posicion, a medida que la
%   cola 1 se desplaza hacia adelante.
%
    for i=1:LQ
        ATTRIB(i)=ATTRIB(i+1);
        i=i+1;
    end
%
%   Se programa el tiempo de partida para la entidad que comenzo a ser
%   atendida y se vuelve a la rutina de eventos.
%
    TS = MINST + (MAXST - MINST) * rand(1);
    TS = floor(TS * 100)/100;
    TND = TNOW+TS;
end

