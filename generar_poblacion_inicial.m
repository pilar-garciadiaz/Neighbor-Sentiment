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

% Genera poblacion inicial del genetico
function [poblacion]=generar_poblacion_inicial()

global num_individuos;

global num_campos_poblacion;
global ind_contenido;
global ind_long;
global ind_fobj_grupos;
global ind_fobj_indiv;
global ind_fobj_media;
global ind_fobj_min;
global ind_fobj_descarte;
global ind_grupo_descarte;

global fobj_mejor;
global fobj_media;

global num_charact;%la ultima columna NO SE CUENTA, es el campo a predecir

global num_min_grupos;
global num_max_grupos;




poblacion=cell(num_individuos,num_campos_poblacion);

num_grupos=ceil(rand(1,num_individuos)*(num_max_grupos-num_min_grupos+1));
num_grupos=num_grupos+num_min_grupos-1;

for n=1:num_individuos
    
    ptos_grupos=1:num_grupos(n);%identificadores de grupos en orden creciente
    ptos_asig=floor(rand(1,num_charact)*num_grupos(n)+1);

    %Codificacion del individuo (cromosoma)
    individuo=[ptos_asig,ptos_grupos];
    long_individuo=[length(ptos_asig),length(ptos_grupos)];
       
    poblacion{n,ind_contenido}=individuo;
    poblacion{n,ind_long}=long_individuo;
    
    poblacion(n,:)=reparacion_individuo(poblacion(n,:));
    
    poblacion(n,:)=evaluacion_individuo(poblacion(n,:));
    
end

fobj=cell2mat(poblacion(:,ind_fobj_indiv));
fobj_mejor=min(fobj);
fobj_media=mean(fobj);
