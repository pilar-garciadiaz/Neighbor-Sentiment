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

% Genera individuo aleatorio
function [indiv]=generar_individuo()

global num_campos_poblacion;
global ind_contenido;
global ind_long;

global num_charact;%la ultima columna NO SE CUENTA, es el campo a predecir

global num_min_grupos;
global num_max_grupos;

indiv=cell(1,num_campos_poblacion);

num_grupos=ceil(rand()*(num_max_grupos-num_min_grupos+1));
num_grupos=num_grupos+num_min_grupos-1;

ptos_grupos=1:num_grupos;%identificadores de grupos en orden creciente
ptos_asig=floor(rand(1,num_charact)*num_grupos+1);

%Codificacion del individuo (cromosoma)
individuo=[ptos_asig,ptos_grupos];
long_individuo=[length(ptos_asig),length(ptos_grupos)];

indiv{1,ind_contenido}=individuo;
indiv{1,ind_long}=long_individuo;

indiv(1,:)=reparacion_individuo(indiv(1,:));

indiv(1,:)=evaluacion_individuo(indiv(1,:));
    
