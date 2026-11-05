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

function [indiv]=mutacion_individuo(indiv)
% Mutación = cruce con otro nuevo de igual longitud

global num_campos_poblacion;

global ind_contenido;
global ind_long;

global num_charact;%la ultima columna NO SE CUENTA, es el campo a predecir

global num_min_grupos;
global num_max_grupos;

indiv=reparacion_individuo(indiv);        
indiv=evaluacion_individuo(indiv);

%Genera un nuevo individuo
nuevo_indv=cell(1,num_campos_poblacion);

num_grupos=ceil(rand()*(num_max_grupos-num_min_grupos+1));
num_grupos=num_grupos+num_min_grupos-1;

ptos_grupos=1:num_grupos;%identificadores de grupos en orden creciente
ptos_asig=floor(rand(1,num_charact)*num_grupos+1);

individuo=[ptos_asig,ptos_grupos];
long_individuo=[length(ptos_asig),length(ptos_grupos)];

nuevo_indv{:,ind_contenido}=individuo;
nuevo_indv{:,ind_long}=long_individuo;

nuevo_indv=reparacion_individuo(nuevo_indv);
nuevo_indv=evaluacion_individuo(nuevo_indv);


indiv=cruce_individuos(indiv,nuevo_indv);
