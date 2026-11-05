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

function poblacion=elimina_replicas_sustituye(poblacion)
% Sustituye la replica por un nuevo individuo aleatorio

global ind_contenido;
global ind_long;
global ind_fobj_grupos;
global ind_fobj_indiv;

global coord_indiv_asig;
global coord_indiv_grupos;


if isempty(poblacion)
    disp('poblacion inexistente en elimina_replicas.m');
    return
end

fobj=cell2mat(poblacion(:,ind_fobj_indiv));

n_indiv=size(poblacion);
n_indiv=n_indiv(1);

if length(fobj)~=n_indiv
    disp('Error en elimina_replicas.m (incoherencias en num. individuos)');
    return;
end


[Ri_fobj ni_fobj]=sort(fobj,'descend');%orden ascendente por defecto

diversidad=unique(Ri_fobj);
index_pob_borrar=[];
b_repl_elim=0;
for i=1:length(diversidad)
    replicas=find(Ri_fobj==diversidad(i));
    num_replicas=length(replicas);
    if num_replicas>3%deja minimo 1 replicas

        %Decodificacion
        individuo_ref=poblacion{ni_fobj(replicas(1)),ind_contenido};
        long_individuo_ref=poblacion{ni_fobj(replicas(1)),ind_long};
        fobj_grupos_ref=poblacion{ni_fobj(replicas(1)),ind_fobj_grupos};
        
        
        %  minimizar



        %  maximizar
        [Ri_fobj_ref ni_fobj_ref]=sort(fobj_grupos_ref,'descend');%orden ascendente por defecto

        ptos_asig_ref=individuo_ref(1:long_individuo_ref(coord_indiv_asig));
        ptos_grupos_ref=individuo_ref(long_individuo_ref(coord_indiv_asig)+1:end);
        num_ptos_grupos_ref=long_individuo_ref(coord_indiv_grupos);
        
        m_1_ref=find(ptos_asig_ref==ptos_grupos_ref(ni_fobj_ref(1)));

        for j=num_replicas:-1:ceil(num_replicas/2)
            %Decodificacion
            individuo_borrar=poblacion{ni_fobj(replicas(j)),ind_contenido};
            long_individuo_borrar=poblacion{ni_fobj(replicas(j)),ind_long};
            fobj_grupos_borrar=poblacion{ni_fobj(replicas(j)),ind_fobj_grupos};

            % PGD minimizar


            % PGD maximizar
            [Ri_fobj_borrar ni_fobj_borrar]=sort(fobj_grupos_borrar,'descend');%orden ascendente por defecto

            ptos_asig_borrar=individuo_borrar(1:long_individuo_borrar(coord_indiv_asig));
            ptos_grupos_borrar=individuo_borrar(long_individuo_borrar(coord_indiv_asig)+1:end);
            num_ptos_grupos_borrar=long_individuo_borrar(coord_indiv_grupos);
            
            
            m_1_borrar=find(ptos_asig_borrar==ptos_grupos_borrar(ni_fobj_borrar(1)));
            conj=ismember(m_1_ref,m_1_borrar);
            if sum(conj)==length(m_1_ref) & (length(m_1_ref)==length(m_1_borrar))
                index_pob_borrar=[index_pob_borrar ni_fobj(replicas(j))];
                
                b_repl_elim=1;
            
            end
           
        end
    end
end
if b_repl_elim
    disp('Replicas eliminadas');
end

if ~isempty(index_pob_borrar)
    
    for ii=1:length(index_pob_borrar)
        poblacion(index_pob_borrar(ii),:)=generar_individuo();
    end
end
