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

function read_reviews2(nombre)

% Reviews_Table
global Reviews;

global id_Revi;
global id_Set;
global id_Sent;
global revi_num_words;
global revi_content;


[rows,cols]=size(Reviews);
contador_review=1;
fileID = fopen(nombre,'rt');
if fileID >= 3
    
    tline=fgetl(fileID);
    while ischar(tline)
        
        if ~contains('%%',tline)
            k = strfind(tline,';');
            
            my_array=[];
            my_array(1,1)=str2double(tline( 1:k(1)-1 ));
            for ii=2:length(k)
                my_array(1,ii)=str2double(tline(k(ii-1)+1:k(ii)-1));
            end
            my_array(1,ii+1)=str2double(tline(k(ii)+1:end));
            
            if contador_review<=rows
                contenido=cell2mat(Reviews(contador_review,revi_content));
                contenido=[contenido;my_array];
                Reviews{contador_review,revi_content}=contenido;
            else
                disp('ERROR: intenta leer mas resenas de las esperadas');
                
                
                % debug
                contador=1;
                tline=fgetl(fileID);
                while ischar(tline)
                    if contains('%%',tline)
                        contador=contador+1;
                    end
                    tline=fgetl(fileID);
                end
                disp('Numero de resenas sobrantes: ');
                contador
                
                
                break;
                
            end
           
             
        else
            contador_review=contador_review+1;
        end
        
        tline=fgetl(fileID);
    end
   
    fclose(fileID);
    
    
    [rows,cols]=size(Reviews);
    for ii=1:rows
        [words_number,cols]=size(Reviews{ii,revi_content});
        Reviews{ii,revi_num_words}=words_number;
    end
    
end