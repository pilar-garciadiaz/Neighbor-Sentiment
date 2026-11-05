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

function grupos=agrupamiento_individuos(num_total,num_grupos, num_ind_grupo,repetir_ind)
% Formar grupos de individuos
% grupos es una matriz nxm siendo 
%                   n el num_grupos (núm. de grupos)
%                   m el num_ind_grupo (núm. indiv en cada grupo)
% repetir_ind = 1 CON REPETICIONES ENTRE GRUPOS Y DENTRO DE LOS GRUPOS,
%                 un individuo puede partircipar en varios grupos y 
%                 puede haber dobles en un mismo grupo
% repetir_ind = 2 REPETICIONES ENTRE GRUPOS,
%                 un individuo puede partircipar en varios grupos pero
%                 NO puede haber dobles en un mismo grupo
% repetir_ind = 3 SIN REPETICIONES, 
%                 un individuo participa UNA sola vez entre todos los grupos
%                 y sin dobles


if num_ind_grupo>num_total 
    num_ind_grupo=num_total;
end

n=num_grupos;

switch repetir_ind
case 1
    grupos=floor(rand(n,num_ind_grupo)*num_total+1);
case 2% En un grupo NO puede haber individuos repetidos
    grupos=floor(rand(n,num_ind_grupo)*num_total+1);
    for g=1:n
        while (length(unique(grupos(g,:))) < num_ind_grupo)
            for i=1:num_ind_grupo
                test=find(grupos(g,:)==grupos(g,i));
                valor=length(test);
                if valor>1
                    grupos(g,test(2:valor))=floor(rand(1,valor-1)*num_total+1);
                end
                if (length(unique(grupos(g,:))) >= num_ind_grupo)
                    break;%for
                end
            end 
        end
    end       
case 3
    if num_grupos*num_ind_grupo > num_total
        n=floor(num_total/num_ind_grupo);
    else
        n=num_grupos;
    end
    grupos=zeros(n,num_ind_grupo);
    participantes=1:num_total;
    for i=1:n
        for j=1:num_ind_grupo
            indice=floor(rand*length(participantes)+1);
            grupos(i,j)=participantes(indice);
            participantes(indice)=[];
        end
    end
end
