%=====================================================================
%  cola.m - Simulador de Eventos Discretos (Modelos 1 a 4)
%=====================================================================
function r = cola(p)

    if ~isfield(p, 'modelo'),   p.modelo = 1;   end
    if ~isfield(p, 'LS'),       p.LS = 1000;    end
    if ~isfield(p, 'MINIAT'),   p.MINIAT = 1;   end
    if ~isfield(p, 'MAXIAT'),   p.MAXIAT = 3;   end
    if ~isfield(p, 'MINST'),    p.MINST = 1;    end
    if ~isfield(p, 'MAXST'),    p.MAXST = 2;    end
    if ~isfield(p, 'QLIMIT'),   p.QLIMIT = 10;  end
    if ~isfield(p, 'TMAXWAIT'), p.TMAXWAIT = 3; end

    if isfield(p, 'semilla')
        rand('seed', p.semilla);
    end

    r = COLASI(p);
end

%=====================================================================
%  COLASI (motor principal de la simulacion)
%=====================================================================
function r = COLASI(p)
    MODELO = p.modelo;
    LS     = p.LS;
    MINIAT = p.MINIAT;
    MAXIAT = p.MAXIAT;
    MINST  = p.MINST;
    MAXST  = p.MAXST;
    TMAXQ  = p.TMAXWAIT;

    CAP_ARRAY = 5000;
    if (MODELO == 1)
        QLIMIT = p.QLIMIT;
    else
        QLIMIT = CAP_ARRAY;
    end

    if (MODELO == 2)
        NSERV  = 2;
        BUSY   = [0, 0];
        TND    = [99999, 99999];
        CSUTIL = [0, 0];
        LQ = 0; CLQ = 0; TQT = 0; NSQ = 0;
        ATTRIB = zeros(CAP_ARRAY, 1);
    elseif (MODELO == 3)
        NSERV  = 1;
        BUSY   = 0;
        TND    = 99999;
        CSUTIL = 0;
        LQ = [0, 0]; CLQ = [0, 0]; TQT = [0, 0]; NSQ = [0, 0];
        ATTRIB = zeros(CAP_ARRAY, 2);
    else
        NSERV  = 1;
        BUSY   = 0;
        TND    = 99999;
        CSUTIL = 0;
        LQ = 0; CLQ = 0; TQT = 0; NSQ = 0;
        ATTRIB = zeros(CAP_ARRAY, 1);
    end

    NEE = 0; NES = 0; TNOW = 0;
    NPERD = 0; NABAN = 0;

    TNA = MINIAT + (MAXIAT - MINIAT) * rand(1);
    corte = 0;

    while corte == 0
        TLE = TNOW;

        if (MODELO == 4 && LQ(1) > 0)
            TAB = ATTRIB(1, 1) + TMAXQ;
        else
            TAB = 99999;
        end

        % Desempate por orden: 1 Partida, 2 Abandono, 3 Arribo
        [TMIN, EV] = min([TND, TAB, TNA]);

        if (TMIN >= LS)
            TNOW = LS;
            [CLQ, CSUTIL] = STAT(CLQ, LQ, TNOW, TLE, CSUTIL, BUSY);
            corte = 1;
            r = OUTPT(TQT, NES, CSUTIL, TNOW, NEE, LQ, CLQ, BUSY, NSQ, NPERD, NABAN, MODELO);
        else
            TNOW = TMIN;
            [CLQ, CSUTIL] = STAT(CLQ, LQ, TNOW, TLE, CSUTIL, BUSY);

            if (EV <= NSERV)
                [NES, TQT, BUSY, LQ, ATTRIB, TND, NSQ] = DEPART(NES, LQ, TNOW, ATTRIB, TQT, MINST, MAXST, BUSY, TND, EV, NSQ, MODELO);
            elseif (EV == NSERV + 1)
                [LQ, ATTRIB, NABAN] = ABANDON(LQ, ATTRIB, NABAN);
            else
                [NEE, TNA, BUSY, LQ, ATTRIB, TND, NPERD] = ARRIBE(NEE, TNOW, MINIAT, MAXIAT, BUSY, LQ, QLIMIT, ATTRIB, MINST, MAXST, TND, NPERD, MODELO);
            end
        end
    end
end

%=====================================================================
%  ARRIBE
%=====================================================================
function [NEE, TNA, BUSY, LQ, ATTRIB, TND, NPERD] = ARRIBE(NEE, TNOW, MINIAT, MAXIAT, BUSY, LQ, QLIMIT, ATTRIB, MINST, MAXST, TND, NPERD, MODELO)
    NEE = NEE + 1;
    TNA = TNOW + MINIAT + (MAXIAT - MINIAT) * rand(1);

    if (all(BUSY == 1))
        J = 1;
        if (MODELO == 3 && LQ(2) < LQ(1))
            J = 2;
        end

        if (MODELO == 1 && LQ(J) >= QLIMIT)
            NPERD = NPERD + 1;
        else
            LQ(J) = LQ(J) + 1;
            ATTRIB(LQ(J), J) = TNOW;
        end
    else
        if (BUSY(1) == 0)
            S = 1;
        else
            S = 2;
        end
        BUSY(S) = 1;
        TND(S) = TNOW + MINST + (MAXST - MINST) * rand(1);
    end
end

%=====================================================================
%  DEPART
%=====================================================================
function [NES, TQT, BUSY, LQ, ATTRIB, TND, NSQ] = DEPART(NES, LQ, TNOW, ATTRIB, TQT, MINST, MAXST, BUSY, TND, K, NSQ, MODELO)
    NES = NES + 1;

    if (sum(LQ) == 0)
        BUSY(K) = 0;
        TND(K) = 99999;
    else
        J = 1;
        if (MODELO == 3 && LQ(2) > LQ(1))
            J = 2;
        end

        TQT(J) = TQT(J) + (TNOW - ATTRIB(1, J));
        if (MODELO == 3)
            NSQ(J) = NSQ(J) + 1;
        end
        LQ(J) = LQ(J) - 1;

        for i = 1:LQ(J)
            ATTRIB(i, J) = ATTRIB(i + 1, J);
        end

        TND(K) = TNOW + MINST + (MAXST - MINST) * rand(1);
    end
end

%=====================================================================
%  ABANDON
%=====================================================================
function [LQ, ATTRIB, NABAN] = ABANDON(LQ, ATTRIB, NABAN)
    NABAN = NABAN + 1;
    LQ = LQ - 1;

    for i = 1:LQ
        ATTRIB(i) = ATTRIB(i + 1);
    end
end

%=====================================================================
%  STAT
%=====================================================================
function [CLQ, CSUTIL] = STAT(CLQ, LQ, TNOW, TLE, CSUTIL, BUSY)
    CLQ = CLQ + LQ * (TNOW - TLE);
    CSUTIL = CSUTIL + BUSY * (TNOW - TLE);
end

%=====================================================================
%  OUTPT
%=====================================================================
function r = OUTPT(TQT, NES, CSUTIL, TNOW, NEE, LQ, CLQ, BUSY, NSQ, NPERD, NABAN, MODELO)
    AWTQ   = sum(TQT) / max(1, NES);
    ALQ    = CLQ / TNOW;
    ASUTIL = CSUTIL / TNOW;

    r.modelo       = MODELO;
    r.NEE          = NEE;
    r.NES          = NES;
    r.LQ           = sum(LQ);
    r.ALQ          = sum(ALQ);
    r.AWTQ         = AWTQ;
    r.ASUTIL       = mean(ASUTIL);
    r.ASUTIL1      = ASUTIL(1);
    r.ASUTIL2      = 0;
    if length(ASUTIL) > 1, r.ASUTIL2 = ASUTIL(2); end

    r.Nbloq        = NPERD;
    if (NPERD > 0)
        r.TMB = TNOW / NPERD;
    else
        r.TMB = NaN;
    end

    r.Naband       = NABAN;
    r.Paband       = NABAN / max(1, NEE);

    if (MODELO == 3)
        r.LQ1   = LQ(1);
        r.LQ2   = LQ(2);
        r.ALQ1  = ALQ(1);
        r.ALQ2  = ALQ(2);
        r.NES1  = NSQ(1);
        r.NES2  = NSQ(2);
        r.AWTQ1 = TQT(1) / max(1, NSQ(1));
        r.AWTQ2 = TQT(2) / max(1, NSQ(2));
    else
        r.LQ1 = sum(LQ); r.LQ2 = 0;
        r.ALQ1 = sum(ALQ); r.ALQ2 = 0;
        r.NES1 = NES; r.NES2 = 0;
        r.AWTQ1 = AWTQ; r.AWTQ2 = 0;
    end

    r.conservacion = NEE - (NES + sum(LQ) + sum(BUSY) + NPERD + NABAN);
end