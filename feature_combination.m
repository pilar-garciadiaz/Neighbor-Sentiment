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

function feature_combination()

% Reviews_Table
%id_Revi | id_Set | id_Sent | revi_num_words=#words | revi_content = Review_#_Table transpuesta

clear all;
close all;


global path_datos;
global path_resultados;

global my_dictionary;
global my_features;

global id_Dict;
global id_Revi;

global id_Sent;

% Sentiments values
global neuron_number;
global sent_na;
%global sent_very_good;
global sent_good;
global sent_regular;
global sent_bad;
%global sent_very_bad;
global max_abs_sent;
global added_sent;%generico para clasificadores binarios y conjunto evaluacion de TASS
global max_Dict;

% Set values
global set_trai;
global set_test;
global set_eval;

% Reviews_Table
global Reviews;
global width_revi;
global length_revi;

%global id_Revi;
global id_Set;
%global id_Sent;
global revi_num_words;
global revi_content;

% Cell of words in Training and Test sets with their features

global Features_Training_Testing_Words;
global Features_Evaluation_Words;

global word_Revi;

global word_next1;
global word_next2;
global word_next3;
global word_next4;
global word_next5;
global word_back1;
global word_back2;
global word_back3;
global word_back4;
global word_back5;
global word_frec1;
global word_frec2;

global num_groups;

global threshold_accu; 

global num_mean_ELM;

%  values assingnation
id_Dict=1; %using in several variables

id_Revi=1; %using in several variables
id_Word_Pred_Revi=2;

id_Sent=3; %using in several variables

% Reviews_Table
width_revi=5;

id_Set=2;

revi_num_words=4;
revi_content=5;

% id_Dict
word_Revi=2;
% id_Sent;
word_next1=4;
word_next2=5;
word_next3=6;
word_next4=7;
word_next5=8;
word_back1=9;
word_back2=10;
word_back3=11;
word_back4=12;
word_back5=13;
word_frec1=14;
word_frec2=15;

% Sentiments values
neuron_number=4;

sent_na=4;
%sent_very_good=4;
sent_good=3;
sent_regular=2;
sent_bad=1;
%sent_very_bad=1;

%PGD ojo
max_abs_sent=4;
added_sent=5;%generico para clasificadores binarios y conjunto evaluacion de TASS

% Set values
set_trai=1;
set_test=2;
set_eval=3;
% set_descartado=4;%apanno para retirar de Train_Test las que no contengan palabras de Evaluation Set
% for Features_Combination_List_Word table

%id_Dict=1;
num_groups=3;


my_features=["id_Dict" "Next1" "Next2" "Next3" "Next4" "Next5" "Back1" "Back2" "Back3" "Back4" "Back5" "Frec1" "Frec2"];

threshold_accu=0.67;

num_mean_ELM=20;%100



path_datos='.\Datos\Datos_all\';
path_datos='.\Datos\Corpus_gral\';

path_resultados='.\Resultados\';


%Recogida de datos


sufijo='reviews_tw.txt';% ojo se comienza a numerar en 0, se suma 1 en read_reviews1
nombre_datos=cat(2,path_datos,sufijo);
read_reviews1(nombre_datos);

sufijo='reviews_cod.txt';
nombre_datos=cat(2,path_datos,sufijo);
read_reviews2(nombre_datos);


sufijo='words_cod.txt';% 
nombre_datos=cat(2,path_datos,sufijo);
read_dictionary(nombre_datos);

[length_revi, col]=size(Reviews);



%Clasificador binario: actualizar Reviews
parche_modificar_evaluation_data();


nombre='comparacion.txt';
myfile=cat(2,path_resultados,nombre);
fid = fopen(myfile, 'a');%Open or create new file for writing. Append data to the end of the file.
t = datetime('now');
DateString = datestr(t);

fprintf(fid, '\n\n\t%s\n\nReviews in Evaluation Set:\n', DateString);

set=cell2mat(Reviews(:,id_Set));
index=find(set==set_eval);
for ii=1:length(index)
    % register all words of the Review
    words_table=Reviews{index(ii),revi_content};
    my_id_Revi=Reviews{index(ii),id_Revi};%id_Revi=1
    my_id_Sent=Reviews{index(ii),id_Sent};
    
    new_table=ones(Reviews{index(ii),revi_num_words},2);
    new_table(:,1)=my_id_Revi*new_table(:,1);
    new_table(:,2)=my_id_Sent*new_table(:,2);
    new_table = [words_table(:,id_Dict) new_table];%id_Dict=1
    words_table(:,id_Dict)=[];%id_Dict=1
    words_table = [new_table words_table];
    
    Features_Evaluation_Words=[Features_Evaluation_Words; words_table];
    fprintf(fid, 'Review\t%3d\n',Reviews{index(ii),id_Revi});
end


max_Dict=max(Features_Evaluation_Words(:,id_Dict));

fprintf(fid, '\n\n\t%s\n\nReviews in Training_Testing Set:\n', DateString);
set=cell2mat(Reviews(:,id_Set));
index=find(set==set_trai);%indices a reseñas de training
index2=find(set==set_test);
index=[index; index2];
for ii=1:length(index)
    % register all words of the Review
    words_table=Reviews{index(ii),revi_content};
    my_id_Revi=Reviews{index(ii),id_Revi};%id_Revi=1
    my_id_Sent=Reviews{index(ii),id_Sent};
    
    new_table=ones(Reviews{index(ii),revi_num_words},2);
    new_table(:,1)=my_id_Revi*new_table(:,1);
    new_table(:,2)=my_id_Sent*new_table(:,2);
    new_table= [words_table(:,id_Dict) new_table];%id_Dict=1
    words_table(:,id_Dict)=[];%id_Dict=1
    words_table=[new_table words_table];
    
    Features_Training_Testing_Words=[Features_Training_Testing_Words; words_table];
    fprintf(fid, 'Review\t%3d\n',Reviews{index(ii),id_Revi});
end 

valor=max(Features_Training_Testing_Words(:,id_Dict));
if valor>max_Dict
    max_Dict=valor;
end

fclose(fid);% comparacion.txt




%dejar el 85% con valor set_trai
training_percent=85;
test_percent=15;
if (training_percent + test_percent ) > 100
    display('Porcentajes de entrenamiento y prueba erroneos');
    training_percent=80;
    test_percent=10;
end



% create feat_comb_list with format:
% Id_Dict | # groups | Group_1 | Group_2 | Group_3 | Group_1 % accuracy | Group_2 % acc. | Group_3 % accuracy 
num_cols=2+(2*num_groups);
feat_comb_list=cell(0,num_cols); % (una sola fila)
                  % Id_Dict | # groups | Group_1 | Group_2 | Group_3 | Group_1 % accuracy | Group_2 % acc. | Group_3 % accuracy 
ELM_Words_Pred=[];% (tantas filas como filas del Training)
                  % id_Dict | Id_Revi | id_Sent | Predict_1  | ... | Predict_num_groups
leader_test_words=[];
deleted_test_words=[];


%test_words_index = unique(Features_Testing_Words(:,id_Dict));%array de indices de palabras en Testing
test_words_index = unique(Features_Evaluation_Words(:,id_Dict));%array de indices de palabras en EVALUATION
%Training es ahora training+test. Solo interesan palabras del conj de evaluacion de TASS

nombre='Resul_palabras_analizar.txt';
myfile=cat(2,path_resultados,nombre);
fid = fopen(myfile, 'w');%Abra o cree un nuevo archivo para escribir. Deseche los contenidos existentes, si los hubiere
if fid < 3
    disp('ERROR al abrir Resul_palabras_analizar.txt');
    return;
else
    t = datetime('now');
    DateString = datestr(t);
    
    %fprintf(fid, '%s\nLista de palabras presentes en EVALUATION set: \n', DateString);
    %Training es ahora training+test. Se evalua con el conj de evaluacion de TASS
    fprintf(fid, '%s\nLista de palabras presentes en EVALUATION set: \n', DateString);
    
    for ii=1:length(test_words_index) 
        fprintf(fid,'%s\n',my_dictionary{test_words_index(ii)});
    end
end

fprintf(fid, '\n\nLista de palabras DESCARTADAS por no presentes o escasas en el conj de entrenamiento train+test: \n' );
fclose(fid);% Resul_palabras_analizar.txt

%PGD comentar desde aqui multiclass    
for ii=1:length(test_words_index)

    %display palabra que se estudia
    my_dictionary(test_words_index(ii))
    
    

    %Generacion de Trai_Set y Test_Set adecuados a cada palabra a considerar
    Trai_Set=[]; Test_Set=[];
    % OJO: Indices alterados en Trai_Set y Test_Set
    
    %Extract all rows of Features_Training_Testing_Words with this word
    Trai_Test_Set=find(Features_Training_Testing_Words(:,id_Dict)==test_words_index(ii));
    if ~isempty(Trai_Test_Set)
        %Componer Test_Set y Trai_Set
        num_bad=0; num_regular=0; num_good=0; num_na=0;
        
        sent_options = find(Features_Training_Testing_Words(Trai_Test_Set,id_Sent)==sent_bad);
        reviews_ident = unique(Features_Training_Testing_Words(Trai_Test_Set(sent_options),word_Revi));%array de indices de reviews
        length_reviews=length(reviews_ident);
        if length_reviews>1
            num_bad=ceil(length_reviews*test_percent/100);
        end
        
        sent_options = find(Features_Training_Testing_Words(Trai_Test_Set,id_Sent)==sent_regular);
        reviews_ident = unique(Features_Training_Testing_Words(Trai_Test_Set(sent_options),word_Revi));%array de indices de reviews
        length_reviews=length(reviews_ident);
        if length_reviews>1
            num_regular=ceil(length_reviews*test_percent/100);
        end
        
        sent_options = find(Features_Training_Testing_Words(Trai_Test_Set,id_Sent)==sent_good);
        reviews_ident = unique(Features_Training_Testing_Words(Trai_Test_Set(sent_options),word_Revi));%array de indices de reviews
        length_reviews=length(reviews_ident);
        if length_reviews>1
            num_good=ceil(length_reviews*test_percent/100);
        end
        
        sent_options = find(Features_Training_Testing_Words(Trai_Test_Set,id_Sent)==sent_na);
        reviews_ident = unique(Features_Training_Testing_Words(Trai_Test_Set(sent_options),word_Revi));%array de indices de reviews
        length_reviews=length(reviews_ident);
        if length_reviews>1
            num_na=ceil(length_reviews*test_percent/100);
        end
        
        rand_index=randperm(length(Trai_Test_Set));
        for jj=1:length(Trai_Test_Set)
           sent= Features_Training_Testing_Words(Trai_Test_Set(rand_index(jj)),id_Sent);
           switch sent
               case sent_bad
                   if num_bad>0
                       Test_Set=[Test_Set;Trai_Test_Set(rand_index(jj))];
                       num_bad=num_bad-1;
                   else
                       Trai_Set=[Trai_Set;Trai_Test_Set(rand_index(jj))];
                   end
               case sent_regular
                   if num_regular>0
                       Test_Set=[Test_Set;Trai_Test_Set(rand_index(jj))];
                       num_regular=num_regular-1;
                   else
                       Trai_Set=[Trai_Set;Trai_Test_Set(rand_index(jj))];
                   end
               case sent_good
                   if num_good>0
                       Test_Set=[Test_Set;Trai_Test_Set(rand_index(jj))];
                       num_good=num_good-1;
                   else
                       Trai_Set=[Trai_Set;Trai_Test_Set(rand_index(jj))];
                   end
               case sent_na
                   if num_na>0
                       Test_Set=[Test_Set;Trai_Test_Set(rand_index(jj))];
                       num_na=num_na-1;
                   else
                       Trai_Set=[Trai_Set;Trai_Test_Set(rand_index(jj))];
                   end
           end%switch
           
        end%for jj=1:length(Trai_Test_Set)
    end%if ~isempty(Trai_Test_Set)
        
    if (~isempty(Test_Set)) && (~isempty(Trai_Set))

        %comb_list y feat_comb_list: tipo cell (una sola fila): 
        % Id_Dict | # groups | Group_1 | Group_2 | Group_3 | Group_1 % accuracy | Group_2 % acc. | Group_3 % accuracy 

        %pred_table y ELM_Words_Pred (tantas filas como filas del Training):
        %id_Dict | Id_Revi | id_Sent | Predict_1  | ... | Predict_num_groups 


        [comb_list,pred_table]=gga_word(Features_Training_Testing_Words(Trai_Set,:),Features_Training_Testing_Words(Test_Set,:));
        % para aplicar a evaluacion set solo interesa comb_list, no las predicciones
        
        %if (~isempty(comb_list)) && (~isempty(pred_table)) %con training y testing sets
        if (~isempty(comb_list)) %con evaluation set OJO puede generar ELM_Words_Pred sin todas las filas
            
            %Not consider the word if low accuracy in one group of 3
            dele_vote=0;
            for jj=1:num_groups
                if comb_list{1,2+num_groups+jj} < threshold_accu
                    dele_vote=dele_vote+1;
                end
            end

            if dele_vote<1%num_groups
                feat_comb_list=[feat_comb_list; comb_list];% estruc. datos grupos y accur. todas palabras Test
                ELM_Words_Pred=[ELM_Words_Pred; pred_table];% tabla de votos todas las palabras Test
                leader_test_words=[leader_test_words test_words_index(ii)];
            else
                deleted_test_words=[deleted_test_words test_words_index(ii)];
            end

        else
            nombre='Resul_palabras_analizar.txt';
            myfile=cat(2,path_resultados,nombre);
            fid = fopen(myfile, 'a');%Open or create new file for writing. Append data to the end of the file
            if fid < 3
                disp('ERROR al abrir Resul_palabras_analizar.txt');
            else
                fprintf(fid,'%s\n',my_dictionary{test_words_index(ii)});
                disp('Escasas muestras con la palabra en training o ¿testing? set')
                fclose(fid);% Resul_palabras_analizar.txt
            end
        end
    else
        nombre='Resul_palabras_analizar.txt';
        myfile=cat(2,path_resultados,nombre);
        fid = fopen(myfile, 'a');%Open or create new file for writing. Append data to the end of the file
        if fid < 3
            disp('ERROR al abrir Resul_palabras_analizar.txt');
        else
            fprintf(fid,'%s\n',my_dictionary{test_words_index(ii)});
            disp('No existe palabra en conj de entrenamiento o prueba train+test set')
            fclose(fid);% Resul_palabras_analizar.txt
        end
    end
end


nombre='result_feature.mat';
myfile=cat(2,path_resultados,nombre);
save(myfile);

load('result_feature.mat')
path_resultados='.\Resultados\';



% feat_comb_list (una sola fila): 
% Id_Dict | # groups | Group_1 | Group_2 | Group_3 | Group_1 % accuracy | Group_2 % acc. | Group_3 % accuracy 

% ELM_Words_Pred (tantas filas como filas del Training):
%id_Dict | Id_Revi | id_Sent | Predict_1  | ... | Predict_num_groups

nombre='comparacion.txt';
myfile=cat(2,path_resultados,nombre);
fid = fopen(myfile, 'a');%Open or create new file for writing. Append data to the end of the file.
if fid < 3
    disp('ERROR al abrir Resul_palabras_analizar.txt');
end
t = datetime('now');
DateString = datestr(t);
fprintf(fid, '\n\n\t%s\n', DateString);
fprintf(fid, '\n \n  Not relevant words in Testing Set: \n');
fprintf(fid, '%3d\t',deleted_test_words);
fprintf(fid, '\n');
for ii=1:length(deleted_test_words)
    fprintf(fid, '\t%s\n',my_dictionary{deleted_test_words(ii)}); 
    fprintf(fid,'\n');
end

constante=2;
words_feat_comb_list=cell2mat(feat_comb_list(:,id_Dict));
fprintf(fid, '\n \n  Leader words in Testing Set: \n');
fprintf(fid, '%3d\t',leader_test_words);
fprintf(fid, '\n');
for ii=1:length(leader_test_words)
    fprintf(fid, '\t%s\n',my_dictionary{leader_test_words(ii)});
    ind_word=find(words_feat_comb_list==leader_test_words(ii));
    if (~isempty(ind_word))
    	for jj=1:num_groups
            m=cell2mat(feat_comb_list(ind_word(1),constante+jj));
            valor=feat_comb_list{ind_word(1),constante+num_groups+jj};
            fprintf(fid, '\t%2.2f\t',valor);
            for kk=1:length(m)
                fprintf(fid, '\t%s\t',my_features(m(kk)));
            end
            fprintf(fid,'\n');
        end
    end
    fprintf(fid,'\n');
    
end
fclose(fid);




test_words_index = unique(Features_Evaluation_Words(:,id_Dict));%array de indices de palabras en EVALUATION
%Training es ahora training+test. Solo interesan palabras del conj de evaluacion de TASS

ELM_Words_Pred=[];
ELM_Words_Pred_eval=[];
for ii=1:length(test_words_index)
    % info: display palabra que se estudia
    my_dictionary(test_words_index(ii))


    %Extract all rows of Features_Training_Testing_Words with this word
    Trai_Set=find(Features_Training_Testing_Words(:,id_Dict)==test_words_index(ii));
    
    %Extract all rows of Features_Training_Words with this word
    Eval_Set=find(Features_Evaluation_Words(:,id_Dict)==test_words_index(ii));
    
    id_Dict_feat_comb_list=cell2mat(feat_comb_list(:,id_Dict));
    index_feat_comb_list=find(id_Dict_feat_comb_list==test_words_index(ii));%una sola fila
    if ~isempty(index_feat_comb_list)
        
        ELM_Words_Pred_eval_row_definitiva=[];
        for xx=1:num_groups
            m=feat_comb_list{index_feat_comb_list(1),2+xx};
            ELM_Words_Pred_eval_row=[];
            [ELM_Words_Pred_eval_row]=evaluacion_word(Features_Training_Testing_Words(Trai_Set,:),Features_Evaluation_Words(Eval_Set,:),m); 
            %Update ELM_Words_Pred_eval
            if xx==1
                ELM_Words_Pred_eval_row_definitiva=ELM_Words_Pred_eval_row;
            else
              
                ELM_Words_Pred_eval_row_definitiva(:,end+1)=ELM_Words_Pred_eval_row(:,id_Sent+1);
            end
        end
        ELM_Words_Pred_eval=[ELM_Words_Pred_eval;ELM_Words_Pred_eval_row_definitiva];
    end
end

% OJO: falta comprobar que no queda ningún valor nulo de ELM_Words_Pred_eval(:,end)
ELM_Words_Pred=ELM_Words_Pred_eval;



nombre='comparacion.txt';
myfile=cat(2,path_resultados,nombre);
fid = fopen(myfile, 'a');%Open or create new file for writing. Append data to the end of the file.
if fid < 3
    disp('ERROR al abrir Resul_palabras_analizar.txt');
end
t = datetime('now');
DateString = datestr(t);
fprintf(fid, '\n\n\t%s\n', DateString);


%Reviews Analysis
predict_table=[];
set=cell2mat(Reviews(:,id_Set));
my_set=cell2mat(feat_comb_list(:,id_Dict));

%index=find(set==set_test);
index=find(set==set_eval);

for ii=1:length(index) % each review has different number of key words
    predicciones_test=[];
    accuracies_test=[];
    
    predict_table(ii,1)=Reviews{index(ii),id_Sent};%primera column =resultados

    %extract rows of ELM_Words_Pred with the id_Revi. They are groups of 3
    indexes=find(ELM_Words_Pred(:,id_Word_Pred_Revi)==Reviews{index(ii),id_Revi});%several rows
    if ~isempty(indexes)
        for jj=1:length(indexes) % unique row
            predicciones_test=[predicciones_test ELM_Words_Pred(indexes(jj),(id_Sent+1):end)];
            my_word_ID=ELM_Words_Pred(indexes(jj),id_Dict);
            %my_set=cell2mat(feat_comb_list(:,id_Dict));
            my_row_comb_list=find(my_set==my_word_ID);
            accuracies_test  =[ accuracies_test  feat_comb_list{my_row_comb_list,(end-num_groups+1:end)} ];
        end

       

        % el mas votado en columna 2 de predict_table
        sent_pred=unique(predicciones_test);%valores de las clases predichas y diferentes
        valores=[];
        for jj=1:length(sent_pred)
            valores(jj)=length( find(predicciones_test == sent_pred(jj) ));
        end
        [val,index_val]=max(valores);
        index_val=find(valores==val);%indices de sent_pred
        
        my_length=length(index_val);
        if my_length>1 %empate
            accu_val=zeros(1,my_length);%segun index_val 
            for jj=1:my_length
                my_accu_index=find(predicciones_test(1,:)==sent_pred(index_val(jj)));
                accu_val(1,jj)=max(accuracies_test(1,my_accu_index));
            end
            [val,new_index]=max(accu_val);
            predict_table(ii,2)=sent_pred(index_val(new_index));% el de mayor precisión con empate
        else
            predict_table(ii,2)=sent_pred(index_val(1));% el mas votado  
        end

        fprintf(fid, '\n Review %3d\t(Sentimiento:\t%d):\t%d\n',Reviews{index(ii),id_Revi},Reviews{index(ii),id_Sent},predict_table(ii,2));
        my_rev=Reviews{index(ii),revi_content};
        my_limit=Reviews{index(ii),revi_num_words};
        for kk=1:my_limit
            fprintf(fid, '\t%s', my_dictionary{my_rev(kk,1),id_Dict});
        end
        fprintf(fid, '\nPalabras con voto:\t%3d\t',ELM_Words_Pred(indexes,id_Dict));%indices de palabras
        fprintf(fid, '\n\n');
        for jj=1:length(predicciones_test)/num_groups
            fprintf(fid, '\t%s\t',my_dictionary{ELM_Words_Pred(indexes(jj),id_Dict)});
            fprintf(fid, '\t%3d\t',predicciones_test(( ((jj-1)*num_groups)+1 ):(jj*num_groups) ));
            fprintf(fid, '\n');
        end
    else
        fprintf(fid, '\n Review %3d\t(NO HAY palabras con voto en TRAINING set:)\n\n',Reviews{index(ii),id_Revi});
        %predict_table(ii,1)=0;
        predict_table(ii,2)=0;
    end
    
    
    % falta probar un voto por palabra, el mayoritario de cada palabra
    
end %for ii=1:length(index) % each review has different number of key words

% escribir predict_table
fprintf(fid, '\n\n Prediction table of Reviews\n Real sentiment \t Prediction sentiment');
for ii=1:length(index)% each review
    fprintf(fid, '\n%d\t%d',predict_table(ii,1),predict_table(ii,2));
end


fclose(fid); %comparacion.txt

 
nombre='result_feature_fin_multiclass.mat';
myfile=cat(2,path_resultados,nombre);
save(myfile);



% DEBUG desde aqui binary-class 
%Clasificadores binarios
max_abs_sent=2;
predict_table=[];
%  for clasificador=1:4  %Clasificadores binarios 
clasificador=1;    


    load -mat result_paso1_binario;
 
    path_resultados='.\Resultados\';
    
    
    switch clasificador
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
    fid = fopen(myfile, 'a');%Open or create new file for writing. Append data to the end of the file.
    t = datetime('now');
    DateString = datestr(t);
    fprintf(fid, '\n\n\t%s\n', DateString);
    
    fprintf(fid, '\n \n  Clasificador binario: \n\t%2d\n\n',clasificador);
    fprintf(fid, '\n \n  Not relevant words in Testing Set: \n');
    fprintf(fid, '%3d\t',deleted_test_words);
    fprintf(fid, '\n');
    for ii=1:length(deleted_test_words)
        fprintf(fid, '\t%s\n',my_dictionary{deleted_test_words(ii)});
        fprintf(fid,'\n');
    end

    constante=2;
    words_feat_comb_list=cell2mat(feat_comb_list(:,id_Dict));
     
    fprintf(fid, '\n \n  Leader words in Testing Set: \n');
    fprintf(fid, '%3d\t',leader_test_words);
    fprintf(fid, '\n');
    for ii=1:length(leader_test_words)
        fprintf(fid, '\t%s\n',my_dictionary{leader_test_words(ii)});
        ind_word=find(words_feat_comb_list==leader_test_words(ii));
        if (~isempty(ind_word))
            for jj=1:num_groups
                m=cell2mat(feat_comb_list(ind_word(1),constante+jj));
                valor=feat_comb_list{ind_word(1),constante+num_groups+jj};
                fprintf(fid, '\t%2.2f\t',valor);
                for kk=1:length(m)
                    fprintf(fid, '\t%s\t',my_features(m(kk)));
                end
                fprintf(fid,'\n');
            end
        end
        fprintf(fid,'\n');
    end

    %Reviews Analysis
    %predict_table=[];
    set=cell2mat(Reviews(:,id_Set));
    my_set=cell2mat(feat_comb_list(:,id_Dict));
    
    
    
    
    %index=find(set==set_test);
    index=find(set==set_eval);
    
    
    
    
    for ii=1:length(index) % each review has different number of key words
        predicciones_test=[];
        accuracies_test=[];

        %extract rows of ELM_Words_Pred with the id_Revi. They are groups of 3
        indexes=find(ELM_Words_Pred(:,id_Word_Pred_Revi)==Reviews{index(ii),id_Revi});%several rows
        if ~isempty(indexes)
            for jj=1:length(indexes) % unique row
                predicciones_test=[predicciones_test ELM_Words_Pred(indexes(jj),(id_Sent+1):end)];
                my_word_ID=ELM_Words_Pred(indexes(jj),id_Dict);
                %my_set=cell2mat(feat_comb_list(:,id_Dict));
                my_row_comb_list=find(my_set==my_word_ID);
                accuracies_test  =[ accuracies_test  feat_comb_list{my_row_comb_list,(end-num_groups+1:end)} ];
            end

            predict_table(ii,1)=Reviews{index(ii),id_Sent};%primera column =resultados

            % el mas votado en columna 2 de predict_table
            sent_pred=unique(predicciones_test);
            valores=[];
            for jj=1:length(sent_pred)
                valores(jj)=length( find(predicciones_test == sent_pred(jj) ));
            end
            [val,index_val]=max(valores);
            index_val=find(valores==val);%indices de sent_pred
            
            my_length=length(index_val);
            if my_length>1 %empate
                accu_val=zeros(1,my_length);%segun index_val 
                for jj=1:my_length
                    my_accu_index=find(predicciones_test(1,:)==sent_pred(index_val(jj)));
                    accu_val(1,jj)=max(accuracies_test(1,my_accu_index));
                end
                [val,new_index]=max(accu_val);
                switch clasificador
                    case 1
                        predict_table(ii,2)=sent_pred(index_val(new_index));% el de mayor precisión con empate
                    case 2
                        predict_table(ii,3)=sent_pred(index_val(new_index));% el de mayor precisión con empate
                    case 3
                        predict_table(ii,4)=sent_pred(index_val(new_index));% el de mayor precisión con empate
                    case 4
                        predict_table(ii,5)=sent_pred(index_val(new_index));% el de mayor precisión con empate
                end
            else
                switch clasificador
                    case 1
                        predict_table(ii,2)=sent_pred(index_val(1));% el mas votado
                    case 2
                        predict_table(ii,3)=sent_pred(index_val(1));% el mas votado
                    case 3
                        predict_table(ii,4)=sent_pred(index_val(1));% el mas votado
                    case 4
                        predict_table(ii,5)=sent_pred(index_val(1));% el mas votado
                end
                  
            end            

            fprintf(fid, '\n Review %3d\t(Sentimiento:\t%d)\n',Reviews{index(ii),id_Revi},Reviews{index(ii),id_Sent});
            my_rev=Reviews{index(ii),revi_content};
            my_limit=Reviews{index(ii),revi_num_words};
            for kk=1:my_limit
                fprintf(fid, '\t%s', my_dictionary{my_rev(kk,1),id_Dict});
            end
            fprintf(fid, '\nPalabras con voto:\t%3d\t',ELM_Words_Pred(indexes,id_Dict));%indices de palabras
            fprintf(fid, '\n\n');
            for jj=1:length(predicciones_test)/num_groups
                fprintf(fid, '\t%s\t',my_dictionary{ELM_Words_Pred(indexes(jj),id_Dict)});
                fprintf(fid, '\t%3d\t',predicciones_test(( ((jj-1)*num_groups)+1 ):(jj*num_groups) ));
                fprintf(fid, '\n');
            end
        else
            fprintf(fid, '\n Review %3d\t(NO HAY palabras con voto en TRAINING set:)\n\n',Reviews{index(ii),id_Revi});
            %predict_table(ii,1)=0;predict_table(ii,2)=0;
            switch clasificador
                    case 1
                        predict_table(ii,2)=0;
                    case 2
                        predict_table(ii,3)=0;
                    case 3
                        predict_table(ii,4)=0;
                    case 4
                        predict_table(ii,5)=0;
             end
        end
        
        %PGD falta probar un voto por palabra, el mayoritario de cada palabra
    end
      
        
    fclose(fid);%comparacion_binario.txt
    
    

    switch clasificador
        case 1
            nombre='result_feature_binario_1';
        case 2
            nombre='result_feature_binario_2';
        case 3
            nombre='result_feature_binario_3';
        case 4
            nombre='result_feature_binario_4';
    end

    nombre=cat(2,nombre,'.mat');
    myfile=cat(2,path_resultados,nombre);
    save(myfile);
   



    %caracteristicas extraidas en feat_comb_list y despues votar, empleando:
        %feat_comb_list: tipo cell (una sola fila): 
        % Id_Dict | # groups | Group_1 | Group_2 | Group_3 | Group_1 % accuracy | Group_2 % acc. | Group_3 % accuracy 

    %ELM for each word in Features_Evaluation_Word, genera nuevo:
        %ELM_Words_Pred (tantas filas como filas del Training):
        %id_Dict | Id_Revi | id_Sent | Predict_1  | ... | Predict_num_groups 

    test_words_index = unique(Features_Evaluation_Words_binario(:,id_Dict));%array de indices de palabras en EVALUATION
    %Training es ahora training+test. Solo interesan palabras del conj de evaluacion de TASS

    ELM_Words_Pred=[];
    ELM_Words_Pred_eval=[];
    for ii=1:length(test_words_index)
        %PGD info: display palabra que se estudia
        my_dictionary(test_words_index(ii))


        %Extract all rows of Features_Training_Testing_Words_binario with this word
        Trai_Set=find(Features_Training_Testing_Words_binario(:,id_Dict)==test_words_index(ii));

        %Extract all rows of Features_Training_Words with this word
        Eval_Set=find(Features_Evaluation_Words_binario(:,id_Dict)==test_words_index(ii));

        id_Dict_feat_comb_list=cell2mat(feat_comb_list(:,id_Dict));
        index_feat_comb_list=find(id_Dict_feat_comb_list==test_words_index(ii));%una sola fila
        if ~isempty(index_feat_comb_list)

            ELM_Words_Pred_eval_row_definitiva=[];
            for xx=1:num_groups
                m=feat_comb_list{index_feat_comb_list(1),2+xx};
                ELM_Words_Pred_eval_row=[];
                [ELM_Words_Pred_eval_row]=evaluacion_word(Features_Training_Testing_Words_binario(Trai_Set,:),Features_Evaluation_Words_binario(Eval_Set,:),m); 
                %Update ELM_Words_Pred_eval
                if xx==1
                    ELM_Words_Pred_eval_row_definitiva=ELM_Words_Pred_eval_row;
                else
                    ELM_Words_Pred_eval_row_definitiva(:,end+1)=ELM_Words_Pred_eval_row(:,id_Sent+1);
                end
            end
            ELM_Words_Pred_eval=[ELM_Words_Pred_eval;ELM_Words_Pred_eval_row_definitiva];
        end
    end

    % OJO: falta comprobar que no queda ningún valor nulo de ELM_Words_Pred_eval(:,end)
    ELM_Words_Pred=ELM_Words_Pred_eval;

   
    
    

nombre='comparacion.txt';
myfile=cat(2,path_resultados,nombre);
fid = fopen(myfile, 'a');%Open or create new file for writing. Append data to the end of the file.
if fid < 3
    disp('ERROR al abrir Resul_palabras_analizar.txt');
end
t = datetime('now');
DateString = datestr(t);
fprintf(fid, '\n\n\t%s\n', DateString);


%Reviews Analysis
predict_table=[];
set=cell2mat(Reviews(:,id_Set));
my_set=cell2mat(feat_comb_list(:,id_Dict));


index=find(set==set_eval);

for ii=1:length(index) % each review has different number of key words
    predicciones_test=[];
    accuracies_test=[];
    
    predict_table(ii,1)=Reviews{index(ii),id_Sent};%primera column =resultados

    %extract rows of ELM_Words_Pred with the id_Revi. They are groups of 3
    indexes=find(ELM_Words_Pred(:,id_Word_Pred_Revi)==Reviews{index(ii),id_Revi});%several rows
    if ~isempty(indexes)
        for jj=1:length(indexes) % unique row
            predicciones_test=[predicciones_test ELM_Words_Pred(indexes(jj),(id_Sent+1):end)];
            my_word_ID=ELM_Words_Pred(indexes(jj),id_Dict);
            
            my_row_comb_list=find(my_set==my_word_ID);
            accuracies_test  =[ accuracies_test  feat_comb_list{my_row_comb_list,(end-num_groups+1:end)} ];
        end

        

        % el mas votado en columna 2 de predict_table
        sent_pred=unique(predicciones_test);%valores de las clases predichas y diferentes
        valores=[];
        for jj=1:length(sent_pred)
            valores(jj)=length( find(predicciones_test == sent_pred(jj) ));
        end
        [val,index_val]=max(valores);
        index_val=find(valores==val);%indices de sent_pred
        
        my_length=length(index_val);
        if my_length>1 %empate
            accu_val=zeros(1,my_length);%segun index_val 
            for jj=1:my_length
                my_accu_index=find(predicciones_test(1,:)==sent_pred(index_val(jj)));
                accu_val(1,jj)=max(accuracies_test(1,my_accu_index));
            end
            [val,new_index]=max(accu_val);
            predict_table(ii,2)=sent_pred(index_val(new_index));% el de mayor precisión con empate
        else
            predict_table(ii,2)=sent_pred(index_val(1));% el mas votado  
        end

        fprintf(fid, '\n Review %3d\t(Sentimiento:\t%d):\t%d\n',Reviews{index(ii),id_Revi},Reviews{index(ii),id_Sent},predict_table(ii,2));
        my_rev=Reviews{index(ii),revi_content};
        my_limit=Reviews{index(ii),revi_num_words};
        for kk=1:my_limit
            fprintf(fid, '\t%s', my_dictionary{my_rev(kk,1),id_Dict});
        end
        fprintf(fid, '\nPalabras con voto:\t%3d\t',ELM_Words_Pred(indexes,id_Dict));%indices de palabras
        fprintf(fid, '\n\n');
        for jj=1:length(predicciones_test)/num_groups
            fprintf(fid, '\t%s\t',my_dictionary{ELM_Words_Pred(indexes(jj),id_Dict)});
            fprintf(fid, '\t%3d\t',predicciones_test(( ((jj-1)*num_groups)+1 ):(jj*num_groups) ));
            fprintf(fid, '\n');
        end
    else
        fprintf(fid, '\n Review %3d\t(NO HAY palabras con voto en TRAINING set:)\n\n',Reviews{index(ii),id_Revi});
        
        predict_table(ii,2)=0;
    end
    
    
    % falta probar un voto por palabra, el mayoritario de cada palabra
    
end

% escribir predict_table
fprintf(fid, '\n\n Prediction table of Reviews\n Real sentiment \t Prediction sentiment');
for ii=1:length(index)% each review
    fprintf(fid, '\n%d\t%d',predict_table(ii,1),predict_table(ii,2));
end

    fclose(fid); 


disp("ACABADO");

    

