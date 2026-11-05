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

function descendencia=cruzar_parejas(parejas,poblacion)
% Se genera un solo individuo por cada pareja cruzada: INCLUYE MUTACIÓN Y REPARACIÓN

% Cruce de individuos
%   + Cruce_individuos: normal con probabilidad del 0.5
%   + Cruce_individuos_suma: heredando los dos mejores grupos de ambos padres con prob 0.5

% Tipos de mutacion:
%   + mutacion_individuo: cruce con un individuo aleatorio
%   - mutacion_individuo_grupo_menos:
%   - mutacion_individuo_grupo_mas:
%   - mutacion_indiv_reduce_grupos_intermedios:
%   + mutacion_indiv_reduce_peores_grupos:
%   - mutacion_individuo_adyacentes: añadiendo caracter. anterior y posterior
%     de cada caract. del grupo mejor
%   - mutacion_individuo_banda_elim



global num_campos_poblacion;
global probMutacion;


n_indiv=size(poblacion);
n_indiv=n_indiv(1);
if ~isempty(find(parejas>n_indiv,1))
    disp('ERROR en cruzar_parejas.m padre no encontrado en la población de núm. de individuos: ');n_indiv %#ok<NOPRT>
end

num_parejas=length(parejas(:,1));
descendencia=cell(num_parejas,num_campos_poblacion);

prob_mutar=rand(num_parejas,1);

for n=1:num_parejas
    
    indiv1=poblacion(parejas(n,1),:);
    indiv2=poblacion(parejas(n,2),:);
   

    if rand()>0.5
        descen=cruce_individuos(indiv1,indiv2);
    else
        descen=cruce_individuos_suma(indiv1,indiv2);
    end
        

    if (prob_mutar(n)<=probMutacion)
        descen=reparacion_individuo(descen);        
        descen=evaluacion_individuo(descen);
            
        valor=rand();
        if valor<0.7
            descen=mutacion_individuo(descen);
        else
            descen=mutacion_indiv_reduce_peores_grupos(descen);
        end
    end
    descen=reparacion_individuo(descen);        
    descen=evaluacion_individuo(descen);  
    
    
    descendencia(n,:)=descen;
end
