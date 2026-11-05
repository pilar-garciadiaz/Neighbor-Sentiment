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

function [indiv] = mutacion_indiv_reduce_peores_grupos(indiv)
%Reduce el 10% de los grupos

% Funcion fitness, elegir entre:
%     minimizar
%     maximizar

%necesita reparacion+evaluacion posterior

% global num_campos_poblacion;
global ind_contenido;
global ind_long;
global ind_fobj_grupos;
% global ind_grupo_descarte;

global coord_indiv_asig;
global coord_indiv_grupos;


%Decodificacion
individuo=indiv{:,ind_contenido};
long_individuo=indiv{:,ind_long};
fobj_grupos=indiv{1,ind_fobj_grupos};

ptos_asig=individuo(1:long_individuo(coord_indiv_asig));
ptos_grupos=individuo(long_individuo(coord_indiv_asig)+1:end);
    
% maximizar
[Ri,ni]=sort(fobj_grupos,'descend');%orden ascendente por defecto

n_grupos_reducir=floor(length(ptos_grupos)/10);
grupos_reducir=ni((length(ni)-n_grupos_reducir):(length(ni)-1));
[R,n]=sort(grupos_reducir,'descend');%orden ascendente por defecto
for ii=n_grupos_reducir:-1:1
    
    %unifica los dos peores
    m=find(ptos_asig==ptos_grupos(ni(end-ii)));
    ptos_asig(m)=ptos_grupos(ni(end));
    
%     fobj_grupos(ni(end-ii))=[];
%     ptos_grupos(ni(end-ii))=[];
%     ni(end-ii)=[];
%     Ri(end)=[];
%     long_individuo(coord_indiv_grupos)=length(ptos_grupos);
end
for ii=1:length(n)
    ptos_grupos(grupos_reducir(n(ii)))=[];
    fobj_grupos(grupos_reducir(n(ii)))=[];
end
long_individuo(coord_indiv_grupos)=length(ptos_grupos);
    
%Codificacion
individuo=[ptos_asig,ptos_grupos];
indiv{:,ind_contenido}=individuo;
indiv{:,ind_long}=long_individuo;
indiv{1,ind_fobj_grupos}=fobj_grupos;

%necesita reparacion+evaluacion posterior

end

