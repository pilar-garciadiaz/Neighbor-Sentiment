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


function [descen]=cruce_individuos(indiv1,indiv2)

global num_campos_poblacion;
global ind_contenido;
global ind_long;

global ind_grupo_descarte;

global coord_indiv_asig;
global coord_indiv_grupos;

descen=cell(1,num_campos_poblacion);

%Decodificacion
individuo1=indiv1{:,ind_contenido};
long_individuo1=indiv1{:,ind_long};
individuo1_gr_descarte=indiv1{:,ind_grupo_descarte};

ptos_asig_indiv1  =individuo1(1:long_individuo1(coord_indiv_asig));
ptos_grupos_indiv1=individuo1(long_individuo1(coord_indiv_asig)+1:end);


%Decodificacion
individuo2=indiv2{:,ind_contenido};
long_individuo2=indiv2{:,ind_long};
individuo2_gr_descarte=indiv2{:,ind_grupo_descarte};

ptos_asig_indiv2  =individuo2(1:long_individuo2(coord_indiv_asig));
ptos_grupos_indiv2=individuo2(long_individuo2(coord_indiv_asig)+1:end);



    
%dos puntos de corte
p=floor(rand(1,2)*long_individuo2(coord_indiv_grupos)+1);
ps=sort(p);%intervalo a tomar del progenitor

%un solo punto de corte
if rand()<=0.5
    ps(2)=long_individuo2(coord_indiv_grupos);%Parte derecha del progenitor
else
    ps(1)=1;%Parte izquierda del progenitor
end


intervalo=ps(1):ps(2);

long_descendiente=long_individuo1;
long_descendiente(coord_indiv_grupos)=length(ptos_grupos_indiv1)+length(intervalo);
ptos_grupos_descendiente=1:long_descendiente(coord_indiv_grupos);%orden creciente
ptos_asig_descendiente=zeros(1,long_descendiente(coord_indiv_asig));
%Copia del individuo1 al descendiente
for ii=1:length(ptos_grupos_indiv1)%long_individuo1(coord_indiv_grupos)
    m=find(ptos_asig_indiv1==ptos_grupos_indiv1(ii));
    ptos_asig_descendiente(m)=ptos_grupos_descendiente(ii);
end
%Traspaso del individuo2 al descendiente
for ii=1:length(intervalo)
    m=find(ptos_asig_indiv2==ptos_grupos_indiv2(intervalo(ii)));
    ptos_asig_descendiente(m)=ptos_grupos_descendiente(length(ptos_grupos_indiv1)+ii);
end

%save  tempo -mat individuo1 progenitor intervalo a b pto_BTS_descendiente pto_BTS_progenitor


%Codificacion del descendiente
descendiente=[ptos_asig_descendiente,ptos_grupos_descendiente];
%long_descendiente=[long_descendiente(coord_indiv_asig),length(ptos_grupos_descendiente)];

descen{:,ind_contenido}=descendiente;
descen{:,ind_long}=long_descendiente;
%no importa el resto, se actualiza en evaluacion
