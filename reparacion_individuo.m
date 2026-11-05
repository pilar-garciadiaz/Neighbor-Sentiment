% Copyright 2026 Pilar García-Díaz
%
% Licensed under the Apache License, Version 2.0
% (the "License"); you may not use this file except
% in compliance with the License.
%
% You may obtain a copy of the License at:
%
%     https://www.apache.org/licenses/LICENSE-2.0
%
% SPDX-License-Identifier: Apache-2.0

function [indiv]=reparacion_individuo(indiv)

global ind_contenido;
global ind_long;

global coord_indiv_asig;
global coord_indiv_grupos;

global num_max_grupos;


if isempty(indiv)
    disp('ERROR en reparacion_individuo.m con INDIVIDUO NULO');
    return;
end

%Decodificación
individuo=indiv{:,ind_contenido};
long_individuo=indiv{:,ind_long};

ptos_asig=individuo(1:long_individuo(coord_indiv_asig));
ptos_grupos=individuo(long_individuo(coord_indiv_asig)+1:end);

if length(ptos_grupos) ~= long_individuo(coord_indiv_grupos)
    disp('ERROR en reparacion_individuo.m con INDIVIDUO incoherente');
    return;
end


% Revisar valores correctos en ptos_asig
for ii=1:long_individuo(coord_indiv_asig)    
    m=find(ptos_grupos==ptos_asig(ii), 1);
    if isempty(m)
        
        % add new group
        ptos_grupos=[ptos_grupos ptos_asig(ii)];
        long_individuo(coord_indiv_grupos)=long_individuo(coord_indiv_grupos)+1;

    end
end

% Eliminar grupos vacios
for ii=long_individuo(coord_indiv_grupos):-1:1
    m=find(ptos_asig==ptos_grupos(ii), 1);
    if isempty(m)
        ptos_grupos(ii)=[];
    end
end
long_individuo(coord_indiv_grupos)=length(ptos_grupos);

% No permitir mas de num_max_grupos
contador=long_individuo(coord_indiv_grupos);
if contador>num_max_grupos    
    texto=cat(2,'Maximo de num. de grupos superado: ',num2str(contador));
    display(texto);
end
while contador>num_max_grupos 
    valor=floor(rand(1,2)*long_individuo(coord_indiv_grupos)+1);
    while valor(1)==valor(2)
        valor=floor(rand(1,2)*long_individuo(coord_indiv_grupos)+1);
    end
    m=find(ptos_asig==ptos_grupos(valor(1)));
    ptos_asig(m)=ptos_grupos(valor(2));
    contador=contador-1;
end
% Eliminar grupos vacios
for ii=long_individuo(coord_indiv_grupos):-1:1
    m=find(ptos_asig==ptos_grupos(ii), 1);
    if isempty(m)
        ptos_grupos(ii)=[];
    end
end
long_individuo(coord_indiv_grupos)=length(ptos_grupos);


%ptos_grupos correctos, comienza en 1 y creciente
ptos_grupos_new=1:long_individuo(coord_indiv_grupos);%nuevos identificadores de grupos en orden creciente
ptos_asig_new=ptos_asig;
for ii=1:long_individuo(coord_indiv_grupos)
    m=find(ptos_asig==ptos_grupos(ii));
    ptos_asig_new(m)=ptos_grupos_new(ii);
end

%Codificacion del individuo (cromosoma)
individuo=[ptos_asig_new,ptos_grupos_new];
%long_individuo=[long_individuo(coord_indiv_asig),length(ptos_grupos)];

indiv{:,ind_contenido}=individuo;
indiv{:,ind_long}=long_individuo;
