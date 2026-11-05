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

function [poblacion,individuo0,num_generaciones]=genetico(simul,id_word)

% Funcion fitness, elegir entre:
%     minimizar
%     maximizar

% Modificar la probabilidad de mutacion a partir de la mitad del num de
%     generaciones: probMutacion=0.1;probMutacion=0.2;

% Elimina replicas a partir de la quinta generacion
%     elimina la replica
%     sustituye la replica por un nuevo indiv aleatorio

% Formacion de parejas: agrupamiento_individuos:
%     sin repeticiones
%     con repeticiones de indiv permitidos

% Seleccion elitista: aplicar o no

% Selección por torneo con agrupamiento_individuos: con repeticiones entre grupos

global my_dictionary;

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

global coord_indiv_asig;
global coord_indiv_grupos;


global fobj_mejor;
global fobj_media;

global num_max_gen;

global path_resultados;

global alpha;



num_generaciones=0;
pobla_caract_g=cell(0,3);% registro de las mejores soluciones


% Generacion de la poblacion inicial
[poblacion]=generar_poblacion_inicial();


if (isempty(poblacion))
    disp('ERROR en genetico.m Poblacion inicial nula');
    return; 
end

% individuo0= Mejor individuo población inicial
%ordenar población de mejor a peor
fobj=cell2mat(poblacion(:,ind_fobj_indiv));

% minimizar
%[Ri,ni]=sort(fobj);%orden ascendente por defecto

% maximizar
[Ri,ni]=sort(fobj,'descend');

individuo0{1,ind_contenido}=poblacion{ni(1),ind_contenido};
individuo0{1,ind_long}=poblacion{ni(1),ind_long};
individuo0{1,ind_fobj_grupos}=poblacion{ni(1),ind_fobj_grupos};
individuo0{1,ind_fobj_indiv}=Ri(1);
individuo0{1,ind_fobj_media}=poblacion{ni(1),ind_fobj_media};
individuo0{1,ind_fobj_min}=poblacion{ni(1),ind_fobj_min};
individuo0{1,ind_fobj_descarte}=poblacion{ni(1),ind_fobj_descarte};
individuo0{1,ind_grupo_descarte}=poblacion{ni(1),ind_grupo_descarte};



while (fobj_media(num_generaciones+1) > fobj_mejor(num_generaciones+1)*(1+alpha))||(num_generaciones<num_max_gen)
    
    if num_generaciones>5
        fobj_lim=num_generaciones-4;
    else
        fobj_lim=1;
    end
    fobj_ultimos=unique(fobj_mejor(fobj_lim:end));

    if (length(fobj_ultimos)<2) && (num_generaciones>10)%>4
        
        %poblacion=elimina_replicas(poblacion); % Elimina la replica
        poblacion=elimina_replicas_sustituye(poblacion); %Sustituye la replica por un nuevo individuo aleatorio
    end
   
    
    % Formación de parejas
	n_indiv_ini=size(poblacion);
    n_indiv_ini=n_indiv_ini(1);
    parejas=agrupamiento_individuos(n_indiv_ini,floor(n_indiv_ini/2),2,3);%sin repeticiones
	
    

	% Cruzar parejas
	descendencia=cruzar_parejas(parejas,poblacion);
	
        
	% Generación de la poblacion temporal
    if isempty(descendencia)
        poblacion_temporal=poblacion;	    
    else
        poblacion_temporal=[poblacion; descendencia];
    end
    [tam_poblacion_temporal,num_col]=size(poblacion_temporal);

    fobj=cell2mat(poblacion_temporal(:,ind_fobj_indiv));
    
    % minimizar
    %[Ri,ni]=sort(fobj);%orden ascendente por defecto

    % maximizar
    [Ri,ni]=sort(fobj,'descend');
    
      
    
    %Selección por torneo
    grupos=agrupamiento_individuos(tam_poblacion_temporal,num_individuos,2,2);%con repeticiones entre grupos
    
    num_grupos=length(grupos(:,1));

    if num_individuos>tam_poblacion_temporal
        seleccion=1:tam_poblacion_temporal;
        indice_elitista=tam_poblacion_temporal+1;
    else
        seleccion=zeros(num_individuos,1);
        for n=1:num_grupos
            
            % minimizar
            %if fobj(grupos(n,1))<=fobj(grupos(n,2))

            % maximizar
            if fobj(grupos(n,1))>=fobj(grupos(n,2))
                seleccion(n)=grupos(n,1);
            else
                seleccion(n)=grupos(n,2);
            end
        end
      
    
        %Completar (agrupamiento sin repeticiones)
        diferencia=num_individuos-num_grupos;
        if diferencia>0
            intervalo1=(num_grupos+1):num_individuos;
            intervalo2=1:diferencia;
            seleccion(intervalo1)=ni(intervalo2);%ni=(poblacion+descendencia)
        else
            diferencia=0;
        end

        %Cambiar individuos repetidos    
        indice_elitista=diferencia+1;

        while (length(unique(seleccion))<num_individuos)
            for i=1:num_individuos
                test=find(seleccion==seleccion(i));
                valor=length(test);
                if valor>1%cambiar individuos repetidos
                    intervalo=indice_elitista:(indice_elitista+valor-2);
                    seleccion(test(2:valor))=ni(intervalo);
                    indice_elitista=indice_elitista+valor-1;
                end
                if (length(unique(seleccion)) >= num_individuos)
                    break;%for
                end
            end 
        end
    end
    
    
    for n=1:min(num_individuos,tam_poblacion_temporal)
        poblacion{n,ind_contenido}=poblacion_temporal{seleccion(n),ind_contenido};
        poblacion{n,ind_long}=poblacion_temporal{seleccion(n),ind_long};
        poblacion{n,ind_fobj_grupos}=poblacion_temporal{seleccion(n),ind_fobj_grupos};
        poblacion{n,ind_fobj_indiv}=fobj(seleccion(n));
        poblacion{n,ind_fobj_media}=poblacion_temporal{seleccion(n),ind_fobj_media};
        poblacion{n,ind_fobj_min}=poblacion_temporal{seleccion(n),ind_fobj_min};
        poblacion{n,ind_fobj_descarte}=poblacion_temporal{seleccion(n),ind_fobj_descarte};
        poblacion{n,ind_grupo_descarte}=poblacion_temporal{seleccion(n),ind_grupo_descarte};
    end
    

    
    fobj=cell2mat(poblacion(:,ind_fobj_indiv));
    
    % minimizar
    %[Ri_poblacion,ni_poblacion]=sort(fobj);%orden ascendente por defecto

    % maximizar
    [Ri_poblacion,ni_poblacion]=sort(fobj,'descend');        
    
    fobj_mejor=[fobj_mejor Ri_poblacion(1)];
    fobj_media=[fobj_media mean(Ri_poblacion)];

    
        %Decodificación
        indivF=poblacion{ni_poblacion(1),ind_contenido};
        long_indivF=poblacion{ni_poblacion(1),ind_long};

        ptos_asig=indivF(1:long_indivF(coord_indiv_asig));
        ptos_grupos=indivF(long_indivF(coord_indiv_asig)+1:end);

        fobj_grupos=poblacion{ni_poblacion(1),ind_fobj_grupos};

        % minimizar
        %[grupo,val]=min(fobj_grupos);

        % maximizar
        [grupo,val]=max(fobj_grupos);
        
        
        m=find(ptos_asig==ptos_grupos(val));
        
        
  %Registro de las mejores soluciones de cada generacion
        if isempty(pobla_caract_g) %Incluir solucion nueva
            pobla_caract_g{1,1}=Ri_poblacion(1);
            pobla_caract_g{1,2}=length(m);
            pobla_caract_g{1,3}=m;
        else
            longitudes=cell2mat(pobla_caract_g(:,2));
            temporal=find(longitudes==length(m));
            if isempty(temporal) %Incluir solucion nueva
                [a,b]=size(pobla_caract_g);
                pobla_caract_g{a+1,1}=Ri_poblacion(1);
                pobla_caract_g{a+1,2}=length(m);
                pobla_caract_g{a+1,3}=m;
            else  %comparar
                b_found=0;
                for ii=1:length(temporal)
                    m_done=pobla_caract_g{temporal(ii),3};
                    conj=ismember(m,m_done);
                    if (sum(conj)==length(m))
                        b_found=1;
                        break;
                    end
                end
                if b_found<1
                    [a,b]=size(pobla_caract_g);
                    pobla_caract_g{a+1,1}=Ri_poblacion(1);
                    pobla_caract_g{a+1,2}=length(m);
                    pobla_caract_g{a+1,3}=m;
                end
            end
        end               
    %end
    
    num_generaciones=num_generaciones+1; %#ok<NOPRT>
    if num_generaciones==num_max_gen
        break;
    end
end
    
nombre='Resul_inter_componentes.txt';
myfile=cat(2,path_resultados,nombre);
fid = fopen(myfile, 'a');%Open or create new file for writing. Append data to the end of the file
if fid < 3
    disp('ERROR al abrir Resul_inter_componentes.txt');
end

t = datetime('now');
DateString = datestr(t);
fprintf(fid, '\n\n\n\n%s\tsimulacion: %d\n%s\n', DateString, simul, my_dictionary{id_word});


[a,b]=size(pobla_caract_g);
for ii=1:a
    fprintf(fid, '\n%1.4f\t%3d\n',pobla_caract_g{ii,1},pobla_caract_g{ii,2});
    m=pobla_caract_g{ii,3};
    fprintf(fid, '%3d\t',m);
    fprintf(fid,'\n');
end

fclose(fid)

