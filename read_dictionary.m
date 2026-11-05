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

function read_dictionary(nombre)
%reinicio diccionario


% Reviews_Table
global my_dictionary;


%  ojo reinicio diccionario
my_dictionary=[];

fileID = fopen(nombre,'rt');
if fileID >= 3
    C = textscan(fileID,'%s %u8','Delimiter',';');
end
fclose(fileID);

my_dictionary=C{1,1};
C=[];

% DEBUG ojo Isa comenzó en 0, sumo 1
% my_dictionary(1,:)=[];

