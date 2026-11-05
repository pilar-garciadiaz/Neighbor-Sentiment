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

function [indiv]=evaluacion_individuo(indiv)

global data_train;
global data_test;

global neuron_number;

global ind_contenido;
global ind_long;
global ind_fobj_grupos;
global ind_fobj_indiv;
global ind_fobj_media;
global ind_fobj_min;


global num_charact;%la ultima columna NO SE CUENTA, es el campo a predecir

global coord_indiv_asig;
global coord_indiv_grupos;

global num_mean_ELM;

if isempty(indiv)
    disp('ERROR en evaluacion_individuo.m con INDIVIDUO NULO');
    return;
end

% Decodificacion
individuo=indiv{:,ind_contenido};
long_individuo=indiv{:,ind_long};

ptos_asig=individuo(1:long_individuo(coord_indiv_asig));
ptos_grupos=individuo(long_individuo(coord_indiv_asig)+1:end);

if length(ptos_grupos) ~= long_individuo(coord_indiv_grupos)
    disp('ERROR en evaluacion_individuo.m con INDIVIDUO incoherente');
    return;
end

fobj_grupos=zeros(1,length(ptos_grupos));
for ii=1:long_individuo(coord_indiv_grupos)
     
    m=find(ptos_asig==ptos_grupos(ii));
    m=[(num_charact+1) m];%columna 1=resultados
    
    for kk=1:num_mean_ELM
        [TY_label,TestingAccuracy]=ELM(data_train(:,m), data_test(:,m),1, neuron_number, 'sig');
        accu(kk)=TestingAccuracy;
    end
    
    fobj_grupos(ii)=mean(accu);
    

    
end

% Codificacion
indiv{:,ind_fobj_grupos}=fobj_grupos;

indiv{:,ind_fobj_min}=min(fobj_grupos);


indiv{:,ind_fobj_media}=mean(fobj_grupos);


%PGD minimizar
%indiv{:,ind_fobj_indiv}=min(fobj_grupos);


%PGD maximizar
indiv{:,ind_fobj_indiv}=max(fobj_grupos);
 

