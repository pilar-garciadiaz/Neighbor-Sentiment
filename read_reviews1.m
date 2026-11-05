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

function read_reviews1(nombre)

% Reviews_Table
global Reviews;

global id_Revi;
global id_Set;
global id_Sent;
global revi_num_words;
global revi_content;

global id_Set;
global id_Sent;
global set_eval;
global added_sent;%generico para clasificadores binarios y conjunto evaluacion de TASS
global path_resultados;

Reviews=cell(1,revi_content);
contador=1;
fileID = fopen(nombre,'rt');
if fileID >= 3
    
    tline=fgetl(fileID);
    while ischar(tline)
        k = strfind(tline,';');
        
        % ISB comenzó en 0, sumo 1
        Reviews{contador,id_Revi}=str2double( tline(1:k(1)-1) )+1;% ISB comenzó en 0, sumo 1
        Reviews{contador,id_Set}=str2double(tline(k(1)+1:k(2)-1));
%         Reviews{contador,id_Sent}=str2double(tline(k(2)+1:end));
        Reviews{contador,id_Sent}=str2double(tline(k(2)+1:k(3)-1));
        %Reviews{contador,:}
        tline=fgetl(fileID);
        contador=contador+1;
    end

    fclose(fileID);
   
end

nombre='reviews_tw_definitivo.txt';
myfile=cat(2,path_resultados,nombre);
fid = fopen(myfile, 'w+');
if fid < 3
    disp('Error al abrir archivo reviews_tw_definitivo.txt');
    return
end
datos_matriz=cell2mat(Reviews);
datos_matriz(:,1)=datos_matriz(:,1)-1;
index=find(datos_matriz(:,id_Set)==set_eval);
datos_matriz(index,id_Sent)=added_sent;
dlmwrite(myfile,datos_matriz,'delimiter',';');
fclose(fid);