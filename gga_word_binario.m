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

function [comb_list,ELM_Words_Pred]=gga_word_binario(Trai_Set,Test_Set,binario_num)

%Input tables with this format(all with the same id_Dict):
%id_Dict | id_Revi | id_Sent | Next1 | Next2 | Next3 | Back1 | Back2 | Back3 | Frec1 | Frec2_Trai | Frec2_Test | Frec2_Eval

%goal: features extraction with better accuracy classification

global my_dictionary;

global id_Dict
global word_Revi;
global id_Sent;

global path_resultados;

global data_train;
global data_test;


global neuron_number;

global num_max_gen;
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

global num_charact;%la ultima columna NO SE CUENTA, es el campo a predecir

global num_min_grupos;
global num_max_grupos;

global probMutacion;

global alpha;

global num_groups;%num de soluciones de grupos de caracteristicas

global num_mean_ELM;

num_campos_poblacion=8;
ind_contenido=1;
ind_long=2;
ind_fobj_grupos=3;
ind_fobj_indiv=4;
ind_fobj_media=5;
ind_fobj_min=6;
ind_fobj_descarte=7;
ind_grupo_descarte=8;

coord_indiv_asig=1;
coord_indiv_grupos=2;

num_max_gen=50;%60;%120;
num_individuos=50;

num_min_grupos=3;
num_max_grupos=12;%floor(num_charact/10);

probMutacion=0.1;%PGD se modifica en genetico.m

alpha=0.001;%0.01; %Rango de convergencia


comb_list=[];
ELM_Words_Pred=[];

data_train=Trai_Set;
data_test=Test_Set;



[num_rows,num_columns]=size(data_test);
[num_rows,num_charact]=size(data_train);
if num_charact~=num_columns
    my_test=['Error en datos de entrada en gga para palabra' num2str(Test_Set(id_Dict,1),'%d')];
    disp(my_test)
    return
end

% OJO si cambian los campos
num_charact=num_charact-2;%  word_Revi id_Sent

ELM_Words_Pred=data_test(:,id_Dict:id_Sent);

%delete columns keeping:
%my_features=["id_Dict" "Next1" "Next2" "Next3" "Next4" "Next5" "Back1" "Back2" "Back3" "Back4" "Back5" "Frec1" "Frec2"];

data_train(:,word_Revi:id_Sent)=[];
data_train=[data_train Trai_Set(:,id_Sent)];%la ultima columna es el campo a predecir

data_test(:,word_Revi:id_Sent)=[];
data_test=[data_test Test_Set(:,id_Sent)];%la ultima columna es el campo a predecir


switch binario_num
    case 1
        nombre='comparacion_binario_1.txt';
    case 2
        nombre='comparacion_binario_2.txt';
    case 3
        nombre='comparacion_binario_3.txt';
    case 4
        nombre='comparacion_binario_4.txt';
end 
myfile=cat(2,path_resultados,nombre);
fid = fopen(myfile, 'a');%Open or create new file for writing. Append data to the end of the file

t = datetime('now');
DateString = datestr(t);
fprintf(fid, '\n%s\nPalabra: %s\t(%d)\n', DateString,my_dictionary{Test_Set(1,id_Dict)},id_Dict);

[rows,cols]=size(data_train);
fprintf(fid, 'Num. tipos: %d\n Filas training: %d\n',neuron_number,rows);
my_control=[];


valor=find(data_train(:,end)==binario_num);
my_control(1,1)=length(valor);
fprintf(fid, 'Tipo %d\t\t Num. elementos: %d\n',binario_num,length(valor));
valor=find(data_train(:,end)==2);
my_control(2,1)=length(valor);
fprintf(fid, 'Tipo 5\t\t Num. elementos: %d\n',length(valor));

[rows,cols]=size(data_test);
fprintf(fid, 'Filas testing: %d\n',rows);

valor=find(data_test(:,end)==binario_num);
my_control(1,2)=length(valor);
fprintf(fid, 'Tipo %d\t\t Num. elementos: %d\n',binario_num,length(valor));
valor=find(data_test(:,end)==2);
my_control(2,2)=length(valor);
fprintf(fid, 'Tipo 5\t\t Num. elementos: %d\n',length(valor));

salir=0;
for ii=1:neuron_number
    if ( (my_control(ii,1) + my_control(ii,2)) == my_control(ii,1) )|| ((my_control(ii,1) + my_control(ii,2)) == my_control(ii,2))
        salir=salir+1;
    end
end
if salir==neuron_number
    fprintf(fid, '\n\nNO se procesa por desajuste entre Training y Testing sets \n',ii,length(valor));
    fclose(fid);
    return
end

[rows,cols]=size(data_train);
if rows<2
    fprintf(fid, '\n\nNO se procesa por escasas muestras en Training set \n',ii,length(valor));
    fclose(fid);
    return
end
    
fprintf(fid, '\n  id_Dict \t Simul \t NumGen\t T(min) \t Ind0Fit \t Ind0NGrup Fitness\t NGrupos \t RHO^2  \t Convg \n');


pobla_caract=cell(0,2);

for simul=1:30
    

start_time=cputime;


%Grouping-ELM
[poblacion,individuo0,num_generaciones]=genetico(simul,Test_Set(1,id_Dict));

%tiempo=etime(clock,tiempo);
end_time=cputime;
tiempo=end_time-start_time;%Calculate CPU time (seconds) spent by ELM predicting the whole testing data

% Comprobar respuesta No vacia
if isempty(poblacion)
    disp('programa.m No se ha ejecutado el algoritmo genetico. Respuesta nula');
    fclose('all');%fclose(fid)
    return;
end


% Resultados de la simulación

%Resultados del individuo0
indiv0=individuo0{1,ind_contenido};
long_indiv0=individuo0{1,ind_long};

% Resultados del individuo final
%ordenar poblacion de mejor a peor
fobj=cell2mat(poblacion(:,ind_fobj_indiv));

% minimizar
%[Ri,ni]=sort(fobj);%orden ascendente por defecto

% maximizar
[Ri,ni]=sort(fobj,'descend');

%Decodificación
indivF=poblacion{ni(1),ind_contenido};
long_indivF=poblacion{ni(1),ind_long};

ptos_asig=indivF(1:long_indivF(coord_indiv_asig));
ptos_grupos=indivF(long_indivF(coord_indiv_asig)+1:end);



fobj_grupos=poblacion{ni(1),ind_fobj_grupos};

% minimizar
%[grupo,val]=min(fobj_grupos);

% maximizar
[grupo,val]=max(fobj_grupos);

m=find(ptos_asig==ptos_grupos(val));


%Registrar mejor solucion
if isempty(pobla_caract) %Incluir solucion nueva
    pobla_caract{1,1}=length(m);
    pobla_caract{1,2}=m;
else
    longitudes=cell2mat(pobla_caract(:,1));
    temporal=find(longitudes==length(m));
    if isempty(temporal) %Incluir solucion nueva
        [a,b]=size(pobla_caract);
        pobla_caract{a+1,1}=length(m);
        pobla_caract{a+1,2}=m;
    else  %comparar
        b_found=0;
        for ii=1:length(temporal)
            m_done=pobla_caract{temporal(ii),2};
            conj=ismember(m,m_done);
            if (sum(conj)==length(m))
                b_found=1;
                break;
            end
        end
        if b_found<1
            [a,b]=size(pobla_caract);
            pobla_caract{a+1,1}=length(m);
            pobla_caract{a+1,2}=m;
        end
    end
end



m=[(num_charact+1) m];%columna 1=resultados
for kk=1:num_mean_ELM
    [TY,TestingAccuracy]=ELM(data_train(:,m), data_test(:,m),1, neuron_number, 'sig');
    accu(kk)=TestingAccuracy;
end
TestingAccuracy=mean(accu);

RHO = corr(data_test(:,end),TY');
R2=RHO^2;

poblacion_winners(simul,:)=poblacion(ni(1),:);


close all;
%Representacion grafica resumen
x=[1:length(data_test(:,end))];
figure;
num_graficas=4;
k=floor(sqrt(num_graficas));
m=ceil(num_graficas/k);
for n=1:num_graficas
    subplot(k,m,n);
    if n==1 
        z1=plot([0:num_generaciones],fobj_mejor,'b');
        title('Min. fitness evol.');
        title(cat(2,'Min. fitness evol.; f=',num2str(fobj_mejor(end))));
        xlabel('Generations');
        grid;
    elseif n==2
        z2=plot([0:num_generaciones],fobj_media,'r');
        title('Average fitness evol.');
        title(cat(2,'Average fitness evol.; f=',num2str(fobj_media(end))));
        xlabel('Generations');
        grid;
    elseif n==3
        plot(x',data_test(:,end),'*r');
        hold on;
        plot(x',TY','+b');
        hold off
        title(cat(2,'RMSE= ',num2str(TestingAccuracy)));
    elseif n==4
        plot(linspace(min([data_test(:,end);TY']),max([data_test(:,end);TY']),100),linspace(min([data_test(:,end);TY']),max([data_test(:,end);TY']),100),'r','linewidth',2);
        hold on;
        plot(data_test(:,end),TY','.','MarkerSize',15);
        title(cat(2,'R2= ',num2str(R2)));
        hold off
    end
end
nombre=strcat('Resultado_',num2str(Test_Set(1,id_Dict),4),'_');%OJO hasta num_words=9999 
myfile=cat(2,path_resultados,nombre);
Name5=strcat(myfile,num2str(simul,2),'.jpg');%OJO hasta simul=99   
saveas(gcf,Name5);
close(gcf)

fprintf(fid, '%4d\t%5.0f\t%5.0f\t%8.6f\t%3.4f\t%3.0f\t%3.4f\t%3.0f\t%2.7f\t%3.8f\n', Test_Set(1,id_Dict), simul,...
    num_generaciones, tiempo/60, fobj_mejor(1), ...
    long_indiv0(coord_indiv_grupos), fobj_mejor(length(fobj_mejor)), ...
    long_indivF(coord_indiv_grupos),R2, fobj_mejor(end)/fobj_media(end));


end 


% Ronda de ganadores
disp('Ronda ganadores ----------------------------------------------'); 

probMutacion=0.2;

% tiempo=clock;
start_time=cputime;

% FALTA COMPROBAR
disp('Impone un individo suma de los mejores diferentes: seleccion elitista para CLASIFICACION');
nuevos_ptos_grupos=[1 2];
nuevos_ptos_asig=ones(1,num_charact);

nuevos_m=[];
[a,b]=size(pobla_caract);
for ii=1:a
   m_done=cell2mat(pobla_caract(ii,2));   
   nuevos_m=[nuevos_m m_done];%columna 1=resultados
end
m=unique(nuevos_m);
nuevos_ptos_asig(m)=2;

%Codificacion del individuo (cromosoma)
individuo=[nuevos_ptos_asig,nuevos_ptos_grupos];
long_individuo=[length(nuevos_ptos_asig),length(nuevos_ptos_grupos)];
poblacion_winners{simul+1,ind_contenido}=individuo;
poblacion_winners{simul+1,ind_long}=long_individuo;

poblacion_winners(simul+1,:)=reparacion_individuo(poblacion_winners(simul+1,:));    
poblacion_winners(simul+1,:)=evaluacion_individuo(poblacion_winners(simul+1,:));


[poblacion,individuo0,num_generaciones]=genetico_winners(poblacion_winners,Test_Set(1,id_Dict));

%tiempo=etime(clock,tiempo);
end_time=cputime;
tiempo=end_time-start_time;           %   Calculate CPU time (seconds) spent by ELM predicting the whole testing data

% Comprobar respuesta No vacia
if isempty(poblacion)
    disp('programa.m No se ha ejecutado el algoritmo genetico. Respuesta nula');
    fclose('all');%fclose(fid);
    return;
end

poblacion=elimina_replicas_sustituye(poblacion); %Sustituye la replica por un nuevo individuo aleatorio

%Resultados del individuo0
indiv0=individuo0{1,ind_contenido};
long_indiv0=individuo0{1,ind_long};

% Resultados del individuo final
%ordenar población de mejor a peor
fobj=cell2mat(poblacion(:,ind_fobj_indiv));

% minimizar
%[Ri,ni]=sort(fobj);%orden ascendente por defecto

% maximizar
[Ri,ni]=sort(fobj,'descend');

indivF=poblacion{ni(1),ind_contenido};
long_indivF=poblacion{ni(1),ind_long};

ptos_asig=indivF(1:long_indivF(coord_indiv_asig));
ptos_grupos=indivF(long_indivF(coord_indiv_asig)+1:end);

fobj_grupos=poblacion{ni(1),ind_fobj_grupos};

% minimizar
%[grupo,val]=min(fobj_grupos);

% maximizar
[grupo,val]=max(fobj_grupos);

m=find(ptos_asig==ptos_grupos(val));

%Registrar mejor solucion
if isempty(pobla_caract) %Incluir solucion nueva
    pobla_caract{1,1}=length(m);
    pobla_caract{1,2}=m;
else
    longitudes=cell2mat(pobla_caract(:,1));
    temporal=find(longitudes==length(m));
    if isempty(temporal) %Incluir solucion nueva
        [a,b]=size(pobla_caract);
        pobla_caract{a+1,1}=length(m);
        pobla_caract{a+1,2}=m;
    else  %comparar
        b_found=0;
        for ii=1:length(temporal)
            m_done=pobla_caract{temporal(ii),2};
            conj=ismember(m,m_done);
            if (sum(conj)==length(m))
                b_found=1;
                break;
            end
        end
        if b_found<1
            [a,b]=size(pobla_caract);
            pobla_caract{a+1,1}=length(m);
            pobla_caract{a+1,2}=m;
        end
    end
end



m=[(num_charact+1) m];%columna 1=resultados
for kk=1:num_mean_ELM
    [TY,TestingAccuracy]=ELM(data_train(:,m), data_test(:,m),1, neuron_number, 'sig');
    accu(kk)=TestingAccuracy;
end
TestingAccuracy=mean(accu);

RHO = corr(data_test(:,end),TY');
R2=RHO^2;


%Representacion grafica resumen
x=[1:length(data_test(:,end))];
figure;
num_graficas=4;
k=floor(sqrt(num_graficas));
mm=ceil(num_graficas/k);
for n=1:num_graficas
    subplot(k,mm,n);
    if n==1 
        z1=plot([0:num_generaciones],fobj_mejor,'b');
        %title('Min. fitness evol.');
        title(cat(2,'Min. fitness evol.; f=',num2str(fobj_mejor(end))));
        xlabel('Generations');
        grid;
    elseif n==2
        z2=plot([0:num_generaciones],fobj_media,'r');
        %title('Average fitness evol.');
        title(cat(2,'Average fitness evol.; f=',num2str(fobj_media(end))));
        xlabel('Generations');
        grid;
    elseif n==3
        plot(x',data_test(:,end),'*r');%plot(x',final_data_validate(:,end),'*r');
        hold on;
        plot(x',TY','+b');
        hold off
        title(cat(2,'RMSE= ',num2str(TestingAccuracy)));
    elseif n==4
        plot(linspace(min([data_test(:,end);TY']),max([data_test(:,end);TY']),100),linspace(min([data_test(:,end);TY']),max([data_test(:,end);TY']),100),'r','linewidth',2);
        hold on;        
        plot(data_test(:,end),TY','.','MarkerSize',15);
        title(cat(2,'R2= ',num2str(R2)));
        hold off
    end
end
nombre=strcat('Resultado_winners_',num2str(Test_Set(1,id_Dict),4),'_');%OJO hasta num_words=9999 
myfile=cat(2,path_resultados,nombre);
Name5=strcat(myfile,'.jpg');
saveas(gcf,Name5);
close(gcf)

fprintf(fid, '\n\t NumGen\t T(min)\t Ind0Fit\t Ind0NGrup Fitness NGrupos\t RHO^2 \t Convg \t IdGrup \n \n');

% minimizar

% maximizar
fprintf(fid, '\n\n WINNER\t%5.0f\t%8.6f\t%3.4f\t%3.4f\t%3.4f\t%3.4f\n\n',...
    num_generaciones, tiempo/60, fobj_mejor(1), fobj_mejor(end),R2, fobj_mejor(end)/fobj_media(end));


%tomar datos de los 3 mejores grupos de la poblacion

constante=2;
comb_list=cell( 0, 2+(2*num_groups) );

comb_list{1,id_Dict}=Test_Set(1,id_Dict);
comb_list{1,2}=num_groups;


% Resultados del individuo final
%ordenar población de mejor a peor
fobj=cell2mat(poblacion(:,ind_fobj_indiv));

% minimizar
%[Ri,ni]=sort(fobj);%orden ascendente por defecto

% maximizar
[Ri,ni]=sort(fobj,'descend');

for ii=1:num_groups

    indivF=poblacion{ni(ii),ind_contenido};
    long_indivF=poblacion{ni(ii),ind_long};

    ptos_asig=indivF(1:long_indivF(coord_indiv_asig));
    ptos_grupos=indivF(long_indivF(coord_indiv_asig)+1:end);

   
    
    fobj_grupos=poblacion{ni(ii),ind_fobj_grupos};

    % minimizar
    %[grupo,val]=min(fobj_grupos);

    % maximizar
    [grupo,val]=max(fobj_grupos);
    
    m=find(ptos_asig==ptos_grupos(val));
    
    m=[(num_charact+1) m];%columna 1=resultados
    
    for kk=1:num_mean_ELM
        [TY,TestingAccuracy]=ELM(data_train(:,m), data_test(:,m),1, neuron_number, 'sig');
        accu(kk)=TestingAccuracy;
    end
    TestingAccuracy=mean(accu);

    RHO = corr(data_test(:,end),TY');
    R2=RHO^2;

    
    comb_list{1,constante+ii}=m(:,2:end);
    comb_list{1,constante+num_groups+ii}=TestingAccuracy;
    
    ELM_Words_Pred=[ELM_Words_Pred TY'];
end


fclose('all');%fclose(fid);
