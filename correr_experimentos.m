%=====================================================================
%  correr_experimentos.m
%  Ejecuta la verificacion de reproducibilidad y N = 30 replicas
%  independientes por modelo con los parametros base de la consigna.
%=====================================================================

% Evita acumular salidas viejas si resultados.txt ya existe
if exist('resultados.txt', 'file')
    delete('resultados.txt');
end
diary('resultados.txt'); diary on;

% --- 1. VERIFICACION DE REPRODUCIBILIDAD ---
% Dos corridas identicas con la misma semilla deben dar diferencia 0
rand('seed', 42); a = cola(struct('modelo', 1, 'LS', 1000));
rand('seed', 42); b = cola(struct('modelo', 1, 'LS', 1000));
fprintf('Reproducibilidad (dif ALQ, misma semilla 42): %g\n', a.ALQ - b.ALQ);

% --- 2. EXPERIMENTOS MULTI-REPLICA (MODELOS 1 A 4) ---
N = 30;
semillas = 100 + (1:N); % Semillas 101 a 130
p_base = struct('LS', 10000, 'MINIAT', 1, 'MAXIAT', 3, 'MINST', 1, 'MAXST', 2);

for m = 1:4
    p = p_base;
    p.modelo = m;

    % Vectores para almacenar metricas de cada replica
    ALQ     = zeros(1, N); AWTQ    = zeros(1, N); ASUTIL  = zeros(1, N);
    ASUTIL1 = zeros(1, N); ASUTIL2 = zeros(1, N);
    ALQ1    = zeros(1, N); ALQ2    = zeros(1, N);
    AWTQ1   = zeros(1, N); AWTQ2   = zeros(1, N);
    Nbloq   = zeros(1, N); TMB     = zeros(1, N);
    Naband  = zeros(1, N); Paband  = zeros(1, N);
    cons_ok = true;

    for i = 1:N
        rand('seed', semillas(i));
        r = cola(p);

        % Chequeo de balance de entidades (entradas == salidas + en sistema)
        if r.conservacion ~= 0
            cons_ok = false;
        end

        ALQ(i)     = r.ALQ;     AWTQ(i)    = r.AWTQ;    ASUTIL(i) = r.ASUTIL;
        ASUTIL1(i) = r.ASUTIL1; ASUTIL2(i) = r.ASUTIL2;
        ALQ1(i)    = r.ALQ1;    ALQ2(i)    = r.ALQ2;
        AWTQ1(i)   = r.AWTQ1;   AWTQ2(i)   = r.AWTQ2;
        Nbloq(i)   = r.Nbloq;   TMB(i)     = r.TMB;
        Naband(i)  = r.Naband;  Paband(i)  = r.Paband;
    end

    % --- 3. REPORTE DE MEDIA Y DESVIO POR MODELO ---
    fprintf('\n================ MODELO %d (N=%d, LS=%d) ================\n', m, N, p.LS);
    fprintf('Conservacion OK en todas las replicas: %d\n', cons_ok);
    fprintf('ALQ     : %.4f +- %.4f\n', mean(ALQ), std(ALQ));
    fprintf('AWTQ    : %.4f +- %.4f\n', mean(AWTQ), std(AWTQ));
    fprintf('ASUTIL  : %.4f +- %.4f\n', mean(ASUTIL), std(ASUTIL));

    if m == 1
        fprintf('Bloqueos: %.2f +- %.2f\n', mean(Nbloq), std(Nbloq));
        tmb_validos = TMB(~isnan(TMB));
        if isempty(tmb_validos)
            fprintf('T.Medio Bloq: NaN (0/%d corridas con bloqueos)\n', N);
        else
            fprintf('T.Medio Bloq (corridas con bloq=%d/%d): %.2f +- %.2f\n', ...
                length(tmb_validos), N, mean(tmb_validos), std(tmb_validos));
        end
    elseif m == 2
        fprintf('ASUTIL1 : %.4f +- %.4f\n', mean(ASUTIL1), std(ASUTIL1));
        fprintf('ASUTIL2 : %.4f +- %.4f\n', mean(ASUTIL2), std(ASUTIL2));
        fprintf('Suma ASUTIL1+ASUTIL2: %.4f\n', mean(ASUTIL1 + ASUTIL2));
    elseif m == 3
        fprintf('ALQ1    : %.4f +- %.4f | ALQ2 : %.4f +- %.4f\n', mean(ALQ1), std(ALQ1), mean(ALQ2), std(ALQ2));
        fprintf('AWTQ1   : %.4f +- %.4f | AWTQ2: %.4f +- %.4f\n', mean(AWTQ1), std(AWTQ1), mean(AWTQ2), std(AWTQ2));
    elseif m == 4
        fprintf('Abandonos: %.2f +- %.2f\n', mean(Naband), std(Naband));
        fprintf('Prob Aband: %.4f +- %.4f\n', mean(Paband), std(Paband));
    end
end

diary off;