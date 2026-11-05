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

function [ELM_Words_Pred]=evaluacion_word_binario(Trai_Set,Eval_Set,m,binario_num)

global data_train;
global data_test;

global neuron_number;

global num_charact;%la ultima columna NO SE CUENTA, es el campo a predecir

global id_Dict
global word_Revi;
global id_Sent;



ELM_Words_Pred=[];

if (~isempty(Trai_Set)) && (~isempty(Eval_Set))

    data_train=Trai_Set;
    data_test=Eval_Set;

    [num_rows,num_columns]=size(data_test);
    [num_rows,num_charact]=size(data_train);
    if num_charact~=num_columns
        my_test=['Error en datos de entrada en gga para palabra' num2str(Test_Set(id_Dict,1),'%d')];
        disp(my_test)
        return
    end

    %PGD OJO si cambian los campos
    num_charact=num_charact-2;%  word_Revi id_Sent

    ELM_Words_Pred=data_test(:,id_Dict:id_Sent);

    data_train(:,word_Revi:id_Sent)=[];
    data_train=[data_train Trai_Set(:,id_Sent)];%la ultima columna es el campo a predecir

    data_test(:,word_Revi:id_Sent)=[];
    data_test=[data_test Eval_Set(:,id_Sent)];%la ultima columna es el campo a predecir


    % m=find(ptos_asig==ptos_grupos(ii));
    m=[(num_charact+1) m];%columna 1=resultados


    % se ejecuta una sola vez
    [TY,TestingAccuracy]=ELM(data_train(:,m), data_test(:,m),1, neuron_number, 'sig');

    ELM_Words_Pred=[ELM_Words_Pred TY'];
    
end 
    