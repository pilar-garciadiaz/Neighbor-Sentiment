# -*- coding: utf-8 -*-
"""
Created on Tue Apr 27 19:20:36 2021

@author: diego
"""

num_eng=8;

training_percent=0;
import matlab.engine
eng= matlab.engine.start_matlab()
eng1= matlab.engine.start_matlab()
eng2= matlab.engine.start_matlab()
eng3= matlab.engine.start_matlab()
eng4= matlab.engine.start_matlab()
eng5= matlab.engine.start_matlab()
eng6= matlab.engine.start_matlab()
eng7= matlab.engine.start_matlab()
# eng8= matlab.engine.start_matlab()
# eng9= matlab.engine.start_matlab()
# eng10= matlab.engine.start_matlab()
# eng11= matlab.engine.start_matlab()
# eng12= matlab.engine.start_matlab()
# eng13= matlab.engine.start_matlab()
# eng14= matlab.engine.start_matlab()
# eng15= matlab.engine.start_matlab()



import numpy
import numpy as np
import pandas as pd

import math

from datetime import datetime
import time

from numpy  import array
threshold_accu = 0.67;



sent_bad=1;
sent_regular=2;
sent_good=3;
sent_na=4;

set_trai=1;
set_test=2;
set_eval=3;

num_groups=3

###############################################################################
###############################################################################
#############################ESTRUCTURAS DE DATOS#############################
###############################################################################
###############################################################################

##############################Estructura de Reviews#############################
#id_Revi | id_Set | id_Sent | revi_num_words=#words | revi_content = Review_#_Table transpuesta

##############################Estructura de: #################################
##############Features_Training_Words, Features_Testing_Words, ###############
##########Features_Training_Testing_Words, Features_Evaluation_Words###########

#  id_Dict | id_Revi | id_Sent | Next1 | Next2 | Next3 | Next4 | Next5 | Back1 | Back2 | Back3 | Back4 | Back5 | Frec1 | Frec2

##. Pueden repetirse filas con =id_Dict con la misma Review o distinta Review
##. Tantas filas con el mismo id_Review como numero de palabras contenga

######################Estructura de:feat_comb_list, comb_list###################
# Id_Dict | # groups | Group_1 | Group_2 | Group_3 | Group_1 % accuracy | Group_2 % acc. | Group_3 % accuracy 


##. tipo cell (una sola fila)

##################Estructura de: ELM_Words_Pred, pred_table ###################
# id_Dict | Id_Revi | id_Sent | Predict_1  | ... | Predict_num_groups

##. (tantas filas como filas del Testing)

###############################################################################
###############################################################################
###############################################################################
###############################################################################

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Se Genera la matriz general Reviews y el diccionario'+'\n\n')  ##

        
print(time.asctime( time.localtime(time.time()) )  + ':' +' Se Genera la matriz general Reviews y el diccionario'+'\n\n')

#c0,c1,c2 =eng.read_reviews1('C:/Users/TFM/Desktop/TFM/reviews_tw_all.txt',nargout=3);
# c0,c1,c2 =eng.read_reviews1('C:/Users/TFM/Desktop/TFM/reviews_tw_definitivo.txt',nargout=3);
#c3,c4=eng.read_reviews2('C:/Users/TFM/Desktop/TFM/reviews_cod_all.txt',nargout=2);
# c3,c4=eng.read_reviews2('C:/Users/TFM/Desktop/TFM/reviews_cod.txt',nargout=2);

# c0,c1,c2,c3,c4=eng.read_reviews2('C:/Users/TFM/Desktop/TFM/reviews_cod_all.txt',nargout=5);
c0,c1,c2,c3,c4=eng.read_reviews2('C:/Users/TFM/Desktop/TFM/reviews_cod.txt',nargout=5);



# my_dictionary=eng.read_dictionary('C:/Users/TFM/Desktop/TFM/words_cod_all.txt');
my_dictionary=eng.read_dictionary('C:/Users/TFM/Desktop/TFM/words_cod.txt');

####OPCION: NUMPY + PANDAS DATAFRAMES
mimatriz=np.array([c0,c1,c2,c3,c4], dtype=object);
mimatrizT=mimatriz.T;

Reviews= pd.DataFrame(mimatrizT, columns=['id_reviews','id_set','id_sent','revi_num_words','revi_content'])

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Matriz Reviews y Diccionario generados'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Matriz Reviews y Diccionario generados'+'\n\n')  ##


###############################################################################
################Calcular el número mínimo de reviews de un tipo################
###############################################################################

df=Reviews;
freq=df['id_sent'].value_counts(); #1=sent_bad ; 2=sent_regular ; 3=sent_good ; 4=sent_na ; 5= ;
min_cardinal=min(freq[1],freq[2],freq[3],freq[4])

###############################################################################
###############################################################################


###############################################################################
###############################################################################
########Selección aleatoria de conjunto de pruebas sobre el total dado ########
###############################################################################
###############################################################################
    
print('A continuación se piden el % en los que dividir el set para entrenamiento y test')
training_percent=int(input('Escribe un número entero entre 0 y 100 para seleccionar el % de entrenamiento:'));
test_percent=int(input('Escribe un número entero entre 0 y 100 para seleccionar el % de test:'));
while training_percent+test_percent != 100:
    print('Porcentajes de entrenamiento y prueba erróneos,la suma de ambos es diferente a 100:')
    training_percent=int(input('Escribe un número entero entre 0 y 100 para seleccionar el % de entrenamiento:'));
    test_percent=int(input('Escribe un número entero entre 0 y 100 para seleccionar el % de test:'));
    

print('Valores definitivos de training y test:')
print('     Training Percent=', training_percent)
print('     Test Percent=', test_percent)


###############################################################################
###############################################################################
###########Para cada tipo se contabiliza el numero maximo de muetras###########
#####################para test y para training#################################
###############################################################################
###############################################################################



max_index_data=[]

max_index_data.append(math.floor(min_cardinal*(training_percent/100)))
max_index_data.append(math.floor(min_cardinal*(test_percent/100))+max_index_data[0])
valor=min_cardinal-max_index_data[1]
if valor != 0:
    max_index_data=max_index_data+valor


# ###############################################################################
# ###############################################################################
# ###########Seleccion aleatoria para la creacion de conjuntos de ###############
# ######################### test y para training#################################
# ###############################################################################
# ###############################################################################

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Creación de conjuntos aleatorios de test y training'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Creación de conjuntos aleatorios de test y training'+'\n\n')  ##

index_na=Reviews[Reviews['id_sent']==4]['id_reviews'].to_numpy()-1
indices_na=np.random.permutation(index_na.size)
for ind in range(max_index_data[0]):
    Reviews['id_set'][index_na[indices_na[ind]]]=set_trai
for ind in range(max_index_data[0],index_na.size):
    Reviews['id_set'][index_na[indices_na[ind]]]=set_test
    
      
index_good=Reviews[Reviews['id_sent']==3]['id_reviews'].to_numpy()-1
indices_good=np.random.permutation(index_good.size)
for ind in range(max_index_data[0]):
    Reviews['id_set'][index_good[indices_good[ind]]]=set_trai
for ind in range(max_index_data[0],index_good.size):
    Reviews['id_set'][index_good[indices_good[ind]]]=set_test
    
index_regular=Reviews[Reviews['id_sent']==2]['id_reviews'].to_numpy()-1
indices_regular=np.random.permutation(index_regular.size)
for ind in range(max_index_data[0]):
    Reviews['id_set'][index_regular[indices_regular[ind]]]=set_trai
for ind in range(max_index_data[0],index_regular.size):
    Reviews['id_set'][index_regular[indices_regular[ind]]]=set_test
        
index_bad=Reviews[Reviews['id_sent']==1]['id_reviews'].to_numpy()-1
indices_bad=np.random.permutation(index_bad.size)
for ind in range(max_index_data[0]):
    Reviews['id_set'][index_bad[indices_bad[ind]]]=set_trai
for ind in range(max_index_data[0],index_bad.size):
    Reviews['id_set'][index_bad[indices_bad[ind]]]=set_test

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Fin creación de conjuntos aleatorios de test y training'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Fin creación de conjuntos aleatorios de test y training'+'\n\n')  ##
    
###############################################################################
###############################################################################
#################Guardamos la hora en la que realizamos########################
##########################la escritura#########################################
###############################################################################
###############################################################################
columns=['id_dict','id_set','id_sent','next1','next2','next3','next4','next5','back1','back2','back3','back4','back5','frec1','frec2']


###############################################################################
###############################################################################
#####################Create  Features Training Words###########################
###############################################################################
###############################################################################
###############################################################################

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Creación de Features Training Words'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Creación de Features Training Words'+'\n\n')  ##

file_comp=open('comparacionTrain.txt','w')
file_comp.write(time.asctime( time.localtime(time.time()) )  +'\n')
file_comp.write('_____________REVIEWS IN TRAINING SET:______________\n')
file_comp.close()


index_training=Reviews[Reviews['id_set']==1]['id_reviews'].to_numpy()-1
words_table_training=pd.DataFrame(columns=columns)

for i in index_training:
    # print('     index_training=', i)
    word_table_p=Reviews['revi_content'][i]
    size_word_table=Reviews['revi_content'][i].size[0]
    my_id_revi=np.full(size_word_table,Reviews['id_reviews'][i])
    my_id_sent=np.full(size_word_table,Reviews['id_sent'][i])
    word_table_f=pd.DataFrame(word_table_p,columns=['id_dict','next1','next2','next3','next4','next5','back1','back2','back3','back4','back5','frec1','frec2'])
    file_comp=open('comparacionTrain.txt','a')
    file_comp.write('Review:'+ "%d" %(i+1)+ '\n')
   
    word_table_f.insert(1,'id_set',my_id_revi,allow_duplicates=False)
    word_table_f.insert(1,'id_sent',my_id_sent,allow_duplicates=False)
    words_table_training=pd.concat([words_table_training,word_table_f],ignore_index=True)

Features_Training_Words=words_table_training;
file_comp.close()

max_Dict=max(Features_Training_Words['id_dict'])

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Fin creación de Features Training Words'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Fin creación de Features Training Words'+'\n\n')  ##

###############################################################################
###############################################################################
#####################Create  Features Testing Words###########################
###############################################################################
###############################################################################
###############################################################################

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Creación de Features Testing Words'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Creación de Features Testing Words'+'\n\n')  ##

file_comp=open('comparacionTest.txt','w')
file_comp.write(time.asctime( time.localtime(time.time()) )  +'\n')
file_comp.write('_____________REVIEWS IN TEST SET:______________\n')
file_comp.close()

index_testing=Reviews[Reviews['id_set']==2]['id_reviews'].to_numpy()-1
words_table_testing=pd.DataFrame(columns=columns)

for i in index_testing:
    word_table_pt=Reviews['revi_content'][i]
    size_word_table=Reviews['revi_content'][i].size[0]
    my_id_revi=np.full(size_word_table,Reviews['id_reviews'][i])
    my_id_sent=np.full(size_word_table,Reviews['id_sent'][i])
    word_table_ft=pd.DataFrame(word_table_pt,columns=['id_dict','next1','next2','next3','next4','next5','back1','back2','back3','back4','back5','frec1','frec2'])
    file_comp=open('comparacionTest.txt','a')
    file_comp.write('Review:'+ "%d" %(i+1)+ '\n')
   
    word_table_ft.insert(1,'id_set',my_id_revi,allow_duplicates=False)
    word_table_ft.insert(1,'id_sent',my_id_sent,allow_duplicates=False)
    words_table_testing=pd.concat([words_table_testing,word_table_ft],ignore_index=True)

Features_Testing_Words=words_table_testing;
file_comp.close()

valor=max(Features_Testing_Words['id_dict'])

if valor > max_Dict :
    max_Dict=valor

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Fin creación de Features Testing Words'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Fin creación de Features Testing Words'+'\n\n')  ##


###############################################################################
###############################################################################
#################Create  Features Training+Testing Words#######################
###############################################################################
###############################################################################
###############################################################################

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Creación de Features Training+Testing Words'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Creación de Features Training+Testing Words'+'\n\n')  ##

file_comp=open('comparacionTrain_Test.txt','w')
file_comp.write(time.asctime( time.localtime(time.time()) )  +'\n')
file_comp.write('_____________REVIEWS IN TRAINING+TESTING SET:______________\n')
file_comp.close()

index_training=Reviews[Reviews['id_set']==1]['id_reviews'].to_numpy()-1
words_table_training_testing=pd.DataFrame(columns=columns)

for i in index_training:
    word_table_p=Reviews['revi_content'][i]
    size_word_table=Reviews['revi_content'][i].size[0]
    my_id_revi=np.full(size_word_table,Reviews['id_reviews'][i])
    my_id_sent=np.full(size_word_table,Reviews['id_sent'][i])
    word_table_f=pd.DataFrame(word_table_p,columns=['id_dict','next1','next2','next3','next4','next5','back1','back2','back3','back4','back5','frec1','frec2'])
    file_comp=open('comparacionTrain_Test.txt','a')
    file_comp.write('Review:'+ "%d" %(i+1)+ '\n')
   
    word_table_f.insert(1,'id_set',my_id_revi,allow_duplicates=False)
    word_table_f.insert(1,'id_sent',my_id_sent,allow_duplicates=False)
    words_table_training_testing=pd.concat([words_table_training_testing,word_table_f],ignore_index=True)

index_testing=Reviews[Reviews['id_set']==2]['id_reviews'].to_numpy()-1

for i in index_testing:
    word_table_pt=Reviews['revi_content'][i]
    size_word_table=Reviews['revi_content'][i].size[0]
    my_id_revi=np.full(size_word_table,Reviews['id_reviews'][i])
    my_id_sent=np.full(size_word_table,Reviews['id_sent'][i])
    word_table_ft=pd.DataFrame(word_table_pt,columns=['id_dict','next1','next2','next3','next4','next5','back1','back2','back3','back4','back5','frec1','frec2'])
    file_comp=open('comparacionTrain_Test.txt','a')
    file_comp.write('Review:'+ "%d" %(i+1)+ '\n')
   
    word_table_ft.insert(1,'id_set',my_id_revi,allow_duplicates=False)
    word_table_ft.insert(1,'id_sent',my_id_sent,allow_duplicates=False)
    words_table_training_testing=pd.concat([words_table_training_testing,word_table_ft],ignore_index=True)

Features_Training_Testing_Words=words_table_training_testing;
file_comp.close()


file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Fin creación de Features Training+Testing Words'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Fin creación de Features Training+Testing Words'+'\n\n')  ##


###############################################################################
###############################################################################
#################Create  Features Evaluation Words#######################
###############################################################################
###############################################################################
###############################################################################

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Creación de Features Evalutaion Words'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Creación de Features Evalutaion Words'+'\n\n')  ##

file_comp=open('comparacionEval.txt','w')
file_comp.write(time.asctime( time.localtime(time.time()) )  +'\n')
file_comp.write('_____________REVIEWS IN EVALUATION SET:______________\n')
file_comp.close()

index_evaluation=Reviews[Reviews['id_set']==3]['id_reviews'].to_numpy()-1
words_table_evaluation=pd.DataFrame(columns=columns)

for i in index_evaluation:
    word_table_e=Reviews['revi_content'][i]
    size_word_table=Reviews['revi_content'][i].size[0]
    my_id_revi=np.full(size_word_table,Reviews['id_reviews'][i])
    my_id_sent=np.full(size_word_table,Reviews['id_sent'][i])
    word_table_e=pd.DataFrame(word_table_e,columns=['id_dict','next1','next2','next3','next4','next5','back1','back2','back3','back4','back5','frec1','frec2'])
    file_comp=open('comparacionEval.txt','a')
    file_comp.write('Review:'+ "%d" %(i+1)+ '\n')
   
    word_table_e.insert(1,'id_set',my_id_revi,allow_duplicates=False)
    word_table_e.insert(1,'id_sent',my_id_sent,allow_duplicates=False)
    words_table_evaluation=pd.concat([words_table_evaluation,word_table_e],ignore_index=True)

Features_Evaluation_Words=words_table_evaluation;
file_comp.close()

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Fin creación de Features Evaluation Words'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Fin creación de Features Evaluation Words'+'\n\n')  ##



###############################################################################
###############################################################################
#########################Clasificación Multiclase #############################
#################GGA for each word in Features_Evaluation_Word ################
###############################################################################
###############################################################################


test_words_index=Features_Evaluation_Words['id_dict'].unique()
test_words_index.sort()
# test_words_index=test_words_index-1          !!!!!!!!!!!!!!!!!!!!!!!!

file_comp=open('Resul_palabras_analizar.txt','w')
file_comp.write(time.asctime( time.localtime(time.time()) )  +'\n')
file_comp.write('_____________LISTA DE PALABRAS PRESENTES EN EVALUATION______________\n')

for i in test_words_index:
    
    file_comp.write( my_dictionary[int(i)-1] + '\n')

file_comp.write('_____________LISTA DE PALABRAS DESCARTADAS POR NO PRESENTES O ESCASAS EN EL CONJUNT0 DE ENTRENAMIENTO TRAIN+TEST______________\n')
file_comp.close()




###############################################################################
###############################################################################
#################Creacion de comb_list y pred_table#######################
###############################################################################
###############################################################################
###############################################################################
#para crear las tabla comb list. Sus columnas varian en funcion del numero de grupos. Para ello:
    
part_1=['id_dict','n_grupos']
part_2=[]
part_3=[]
for i in range(num_groups):
    a="grupo" + "%d" %(i+1)
    part_2.append(a)
    b="Group"+"%d" %(i+1) +"% Accuracy"
    part_3.append(b)
columnas_comb_list=part_1+part_2+part_3
feat_comb_list=pd.DataFrame(columns=columnas_comb_list)

#para pred_table
part_11=['id_dict','id_revi','id_sent']
part_22=[]
for i in range(num_groups):
    a="predict" + "%d" %(i+1)
    part_22.append(a)
columnas_pred_table=part_11+part_22

###############################################################################
###############################################################################
#################gga_word y escritura datos#######################
###############################################################################
###############################################################################
###############################################################################

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Comienzo gga_word y preparación de datos de entrada'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Comienzo gga_word y preparación de datos de entrada'+'\n\n')  ##


#-----------------------MODIFICADO------------------------
z=0
ELM_words_pred=pd.DataFrame(columns=columnas_pred_table)
leader_test_words=[];
deleted_test_words=[];
test_words_index=Features_Evaluation_Words['id_dict'].unique()
test_words_index.sort()
wi=0

in_gga_trai_gga=[]
in_gga_test_gga=[]
new_test_words_index=[]

for word in test_words_index:
    
    test_set=Features_Testing_Words[Features_Testing_Words['id_dict']==word].index.to_list()
    trai_set=Features_Training_Words[Features_Training_Words['id_dict']==word].index.to_list()
    if ((len(test_set) !=0) and (len(trai_set) != 0)):
        in_gga_trai=[]
        in_gga_test=[]
        for i in trai_set: #Entrada a gga_word (Trai)
            in_gga_trai=np.concatenate((np.array(in_gga_trai),np.array(Features_Training_Words.to_numpy()[int(i)])))
            in_gga_trai=in_gga_trai.tolist()
        in_gga_trai_gga.append(in_gga_trai)

        for i in test_set: #Entrada a gga_word (Test)
            in_gga_test=np.concatenate((np.array(in_gga_test),np.array(Features_Testing_Words.to_numpy()[int(i)])))
            in_gga_test=in_gga_test.tolist()
        in_gga_test_gga.append(in_gga_test)
        
        new_test_words_index.append(word)
    else:
        file_comp=open('Resul_palabras_analizar.txt','a')
        file_comp.write( my_dictionary[int(word)-1] + ':No existe palabra en conj de entrenamiento o prueba train+test set\n')
        file_comp.close()
    

resto=len(in_gga_trai_gga)%num_eng  
in_gga_trai_paralelize=in_gga_trai_gga[0:len(in_gga_trai_gga)-resto]   
in_gga_test_paralelize=in_gga_test_gga[0:len(in_gga_trai_gga)-resto]
in_gga_trai_not_paralelize=in_gga_trai_gga[len(in_gga_trai_gga)-resto:]
in_gga_test_not_paralelize=in_gga_test_gga[len(in_gga_trai_gga)-resto:]
        
file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Comienza paralaelizacion:'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Comienza paralaelizacion:'+'\n\n')  ##

def function_paral(n):
    
    #pgd
    file_comp=open('Logs_pgd.txt','a')
    file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 1'+'\n\n')  ##
    print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 1'+'\n\n')  ##
    

    t,r=eng.gga_word(in_gga_test_paralelize[n],in_gga_trai_paralelize[n],15,my_dictionary,int(max_Dict),nargout=2)
    
    #pgd
    file_comp=open('Logs_pgd.txt','a')
    file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 2'+'\n\n')  ##
    print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 2'+'\n\n')  ##
    
    
    t1,r1=eng1.gga_word(in_gga_test_paralelize[n+1],in_gga_trai_paralelize[n+1],15,my_dictionary,int(max_Dict),nargout=2)
    
    #pgd
    file_comp=open('Logs_pgd.txt','a')
    file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 3'+'\n\n')  ##
    print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 3'+'\n\n')  ##
    
    
    t2,r2=eng2.gga_word(in_gga_test_paralelize[n+2],in_gga_trai_paralelize[n+2],15,my_dictionary,int(max_Dict),nargout=2)
    
    #pgd
    file_comp=open('Logs_pgd.txt','a')
    file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 4'+'\n\n')  ##
    print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 4'+'\n\n')  ##
    
    
    t3,r3=eng3.gga_word(in_gga_test_paralelize[n+3],in_gga_trai_paralelize[n+3],15,my_dictionary,int(max_Dict),nargout=2)
    
    #pgd
    file_comp=open('Logs_pgd.txt','a')
    file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 5'+'\n\n')  ##
    print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 5'+'\n\n')  ##
    
    
    t4,r4=eng4.gga_word(in_gga_test_paralelize[n+4],in_gga_trai_paralelize[n+4],15,my_dictionary,int(max_Dict),nargout=2)
    
    #pgd
    file_comp=open('Logs_pgd.txt','a')
    file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 6'+'\n\n')  ##
    print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 6'+'\n\n')  ##
    
    
    t5,r5=eng5.gga_word(in_gga_test_paralelize[n+5],in_gga_trai_paralelize[n+5],15,my_dictionary,int(max_Dict),nargout=2)
    
    #pgd
    file_comp=open('Logs_pgd.txt','a')
    file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 7'+'\n\n')  ##
    print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 7'+'\n\n')  ##
    
    
    t6,r6=eng6.gga_word(in_gga_test_paralelize[n+6],in_gga_trai_paralelize[n+6],15,my_dictionary,int(max_Dict),nargout=2)
    
    #pgd
    file_comp=open('Logs_pgd.txt','a')
    file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 8'+'\n\n')  ##
    print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 8'+'\n\n')  ##
    
    
    t7,r7=eng7.gga_word(in_gga_test_paralelize[n+7],in_gga_trai_paralelize[n+7],15,my_dictionary,int(max_Dict),nargout=2)
    
    # #pgd
    # file_comp=open('Logs_pgd.txt','a')
    # file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 9'+'\n\n')  ##
    # print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 9'+'\n\n')  ##
    
    
    # t8,r8=eng8.gga_word(in_gga_test_paralelize[n+8],in_gga_trai_paralelize[n+8],15,my_dictionary,int(max_Dict),nargout=2)
    
    # #pgd
    # file_comp=open('Logs_pgd.txt','a')
    # file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 10'+'\n\n')  ##
    # print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 10'+'\n\n')  ##
    
    
    # t9,r9=eng9.gga_word(in_gga_test_paralelize[n+9],in_gga_trai_paralelize[n+9],15,my_dictionary,int(max_Dict),nargout=2)
    
    # #pgd
    # file_comp=open('Logs_pgd.txt','a')
    # file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 11'+'\n\n')  ##
    # print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 11'+'\n\n')  ##
    
    # t10,r10=eng10.gga_word(in_gga_test_paralelize[n+10],in_gga_trai_paralelize[n+10],15,my_dictionary,int(max_Dict),nargout=2)
    
    # #pgd
    # file_comp=open('Logs_pgd.txt','a')
    # file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 12'+'\n\n')  ##
    # print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 12'+'\n\n')  ##
    
    # t11,r11=eng11.gga_word(in_gga_test_paralelize[n+11],in_gga_trai_paralelize[n+11],15,my_dictionary,int(max_Dict),nargout=2)

    # #pgd
    # file_comp=open('Logs_pgd.txt','a')
    # file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 13'+'\n\n')  ##
    # print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 13'+'\n\n')  ##
    # file_comp.close()
    
    # t12,r12=eng12.gga_word(in_gga_test_paralelize[n+12],in_gga_trai_paralelize[n+12],15,my_dictionary,int(max_Dict),nargout=2)
    
    # #pgd
    # file_comp=open('Logs_pgd.txt','a')
    # file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 14'+'\n\n')  ##
    # print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 14'+'\n\n')  ##
    # file_comp.close()
    
    # t13,r13=eng13.gga_word(in_gga_test_paralelize[n+13],in_gga_trai_paralelize[n+13],15,my_dictionary,int(max_Dict),nargout=2)

    # #pgd
    # file_comp=open('Logs_pgd.txt','a')
    # file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 15'+'\n\n')  ##
    # print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 15'+'\n\n')  ##
    # file_comp.close()
    
    # t14,r14=eng14.gga_word(in_gga_test_paralelize[n+14],in_gga_trai_paralelize[n+14],15,my_dictionary,int(max_Dict),nargout=2)

    # #pgd
    # file_comp=open('Logs_pgd.txt','a')
    # file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 16'+'\n\n')  ##
    # print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 16'+'\n\n')  ##
    # file_comp.close()
    
    # t15,r15=eng15.gga_word(in_gga_test_paralelize[n+15],in_gga_trai_paralelize[n+15],15,my_dictionary,int(max_Dict),nargout=2)

    # #pgd
    # file_comp=open('Logs_pgd.txt','a')
    # file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Inicio engine 15'+'\n\n')  ##
    # print(time.asctime( time.localtime(time.time()) )  + ':' +'  Inicio engine 15'+'\n\n')  ##
    # file_comp.close()
    
    return t,r,t1,r1,t2,r2,t3,r3,t4,r4,t5,r5,t6,r6,t7,r7;#,t8,r8,t9,r9,t10,r10,t11,r11,t12,r12,t13,r13,t14,r14,t15,r15;
    # return t,r,t1,r1;


def function_no_paral(x,y):
    t,r=eng.gga_word(x,y,15,my_dictionary,int(max_Dict),nargout=2)
    
    return t,r;


t=0
table_out_gga_complete=pd.DataFrame(columns=['comb_list','pred_table'])


from multiprocessing.dummy import Pool as ThreadPool 
pool = ThreadPool(7)
n=0
ins=[]
a_comb_list=[]
b_pred_table=[]
params_in=[]


for i in range(int((len(in_gga_test_paralelize)/num_eng))):
    ins.append(n)
    n=n+num_eng

    
out_pool_p=pool.starmap(function_paral, zip(ins) )


for iii in range(int(len(out_pool_p))):  #
    
    for ii in range(int(len(out_pool_p[0]))):
        if ii%2 >0:
            b_pred_table.append(out_pool_p[iii][ii])
        else:
            a_comb_list.append(out_pool_p[iii][ii])


matriz_results_paral=np.array([a_comb_list,b_pred_table], dtype=object);
matriz_results_paralT=matriz_results_paral.T;
table_paralelize= pd.DataFrame(matriz_results_paralT, columns=['comb_list','pred_table'])


##########not paralelice#####
if int(len(in_gga_test_not_paralelize)) >0:
    out_pool_np=pool.starmap(function_no_paral, zip(in_gga_test_not_paralelize,in_gga_trai_not_paralelize)) 
    table_out_pool_np=np.array(out_pool_np,dtype=object)
    table_no_paralelize=pd.DataFrame(table_out_pool_np,columns=['comb_list','pred_table'])
else:
    table_no_paralelize=pd.DataFrame(columns=['comb_list','pred_table'])
    

pool.close() 
pool.join()

table_out_gga_complete=pd.concat([table_paralelize,table_no_paralelize],ignore_index=True)


file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Fin paralaelizacion:'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Fin paralaelizacion:'+'\n\n')  ##


file_comp=open('data.txt','w')
file_comp.write(time.asctime( time.localtime(time.time()) ) +'\n' )  ##
for dato in range(len(table_out_gga_complete)):
    comb_list=table_out_gga_complete['comb_list'][dato]
    if int(len(comb_list)) >0:
        a=comb_list[0]
        b=comb_list[num_groups+2]
        c=comb_list[2]
        d=comb_list[num_groups+3]
        e=comb_list[3]
        f=comb_list[num_groups+4]
        g=comb_list[4]
        file_comp=open('data.txt','a')
        file_comp.write( str(a) + ', ' + str(b) + ', ' + str(c)+'\n')
        file_comp.write( str(a) + ', ' + str(d) + ', ' + str(e)+'\n')
        file_comp.write( str(a) + ', ' + str(f) + ', ' + str(g)+'\n')

file_comp.close()
    



for dato in range(len(table_out_gga_complete)):
    comb_list=table_out_gga_complete['comb_list'][dato]
    pred_table=table_out_gga_complete['pred_table'][dato]
    word=new_test_words_index[dato]
        
    if (len(comb_list) != 0):
        dele_vote=0;
        for i in range(num_groups):
            if (comb_list[2+num_groups+i] < threshold_accu):
                dele_vote=dele_vote+1
            
        if (dele_vote < 1):
            #Guardamos comb_list
            comb_list_table=[]
            array_comb_list=[]
            comb_list_table.append(comb_list)
            array_comb_list=pd.DataFrame(comb_list_table,columns=columnas_comb_list)
            feat_comb_list=pd.concat([feat_comb_list,array_comb_list],ignore_index=True)
            #Guardamos Pred Table
            for i in range(int(pred_table.size[1]/(3+num_groups))):
                array_pred_table=[]
                array_pred_table.append(pred_table[0][2*num_groups*i:2*num_groups*(i+1)])
                array_pred_table=pd.DataFrame(array_pred_table,columns=columnas_pred_table)
                ELM_words_pred=pd.concat([ELM_words_pred,array_pred_table],ignore_index=True)
            #Guardamos leade test words. Guardamos i = indice de la palabra
            leader_test_words.append(word)
        else:
            deleted_test_words.append(word)
    else:
        file_comp=open('Resul_palabras_analizar.txt','a')
        file_comp.write( my_dictionary[int(word)-1] + ':Escasas muestras con la palabra en training o testing set\n')
        file_comp.close()
        

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Fin gga y clasificación palabras a analizar'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Fin gga y clasificación palabras a analizar'+'\n\n')  ##





###############################################################################
###############################################################################
################## Analisis clasificador multiclase#######################
###############################################################################
###############################################################################

#########################Not Relevant#########################################

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Escribimos palabras no relevantes en Not_relevant_words_testing_set.txt'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Escribimos palabras no relevantes en Not_relevant_words_testing_set.txt'+'\n\n')  ##


file_comp=open('Not_relevant_words_testing_set.txt','w')
file_comp.write(time.asctime( time.localtime(time.time()) )  +'\n')
file_comp.write('\n \n __________NOT RELEVANT WORDS IN TESTING SET__________: \n')
file_comp.write('\n Id_word _____ Word_dictyonary: \n')

for i in deleted_test_words:
    file_comp.write("   %d" %(i))
    file_comp.write('               '+ my_dictionary[int(i)-1] + '\n')
file_comp.write('\n')
file_comp.close()

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Fin escritura palabras no relevantes en Not_relevant_words_testing_set.txt'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Fin escritura palabras no relevantes en Not_relevant_words_testing_set.txt'+'\n\n')  ##


###########################Relevant#########################################
file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Escribimos palabras relevantes en Leader_words_testing_set.txt'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Escribimos palabras relevantes en Leader_words_testing_set.txt'+'\n\n')  ##


words_feat_comb_list=feat_comb_list['id_dict'].to_numpy()

file_comp=open('Leader_words_testing_set.txt','w')
file_comp.write(time.asctime( time.localtime(time.time()) )  +'\n')
file_comp.write('\n \n __________LEADER WORDS IN TESTING SET__________: \n')

part_i=[]

for i in range(num_groups):
    a="Result %d" %(i+1) +"____________________________" 
    part_i.append(a)
    

file_comp.write('\n Id_word _____ Word_dictyonary__________')
for i in range(len(part_i)):
    file_comp.write(part_i[i])
file_comp.write('\n')


for leader in leader_test_words:
    file_comp.write("   %d" %(leader))
    file_comp.write('         '+ my_dictionary[int(leader)-1])
    for n in range(num_groups):
        file_comp.write('                 '+columnas_comb_list[n+2]+': ')
        
        # %pgd
        # valor=feat_comb_list[feat_comb_list['id_dict']==leader].to_numpy()[0][2+n]
        # file_comp.write(" %f" %(valor) )
        
        
        valor=feat_comb_list[feat_comb_list['id_dict']==leader].to_numpy()[0][2+num_groups+n] #En el 100 iria leader_test_words
        file_comp.write(" %f" %(valor) )
    file_comp.write('\n')
file_comp.close()

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Fin escritura palabras relevantes en Leader_words_testing_set.txt'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Fin escritura palabras relevantes en Leader_words_testing_set.txt'+'\n\n')  ##




###############################################################################
############################Comentarios de MATLAB###################################################




# % PGD para (training + testing) + EVALUATION sets: desde aqui

# %Ejecutar ELM para cada palabra de evaluation set sobre train+test con las
# %caracteristicas extraidas en feat_comb_list y despues votar, empleando:
#     %feat_comb_list: tipo cell (una sola fila): 
#     % Id_Dict | # groups | Group_1 | Group_2 | Group_3 | Group_1 % accuracy | Group_2 % acc. | Group_3 % accuracy 

# %ELM for each word in Features_Evaluation_Word, genera nuevo:
#     %ELM_Words_Pred (tantas filas como filas del Training):
#     %id_Dict | Id_Revi | id_Sent | Predict_1  | ... | Predict_num_groups 
        
# %no debe recoger nada del anterior ELM_Words_Pred
# % ELM_Words_Pred_eval=ELM_Words_Pred(:,id_Dict:id_Sent);
# % num=length(ELM_Words_Pred_eval);
# % ELM_Words_Pred_eval(:,num+1)=0;%inicializado con valor nulo



###############################################################################
###############################################################################
file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Comienzo ejecución ELM para cada palabra de evaluation set sobre tran+test'+'\n\n')  ##
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Comienzo evaluation_word'+'\n\n')  ##

print(time.asctime( time.localtime(time.time()) )  + ':' +' Comienzo ejecución ELM para cada palabra de evaluation set sobre tran+test'+'\n\n')  ##
print(time.asctime( time.localtime(time.time()) )  + ':' +' Comienzo evaluation_word'+'\n\n')  ##


columnas_evaluacion_table=['id_dict','id_revi','id_sent','pred1']
ELM_words_pred_eval=pd.DataFrame(columns=columnas_evaluacion_table);
ELM_w_p_e=pd.DataFrame()
table_complete_predictions=pd.DataFrame()


for word in test_words_index:
    eval_set=Features_Evaluation_Words[Features_Evaluation_Words['id_dict']==word].index.to_list()
    trai_test_set=Features_Training_Testing_Words[Features_Training_Testing_Words['id_dict']==word].index.to_list()
    id_dict_feat_comb_list=feat_comb_list[feat_comb_list['id_dict']==word]
    index_feat_comb_list=id_dict_feat_comb_list.index.to_list()
    
    if (len(index_feat_comb_list) !=0):
        
        ELM_words_pred_eval=pd.DataFrame(columns=columnas_evaluacion_table);
        in_evaluation_word_trai_test=[]
        in_evaluation_word_eval=[]
        
        for i in eval_set: #Entrada a gga_word (Trai)
            in_evaluation_word_eval=np.concatenate((np.array(in_evaluation_word_eval),np.array(Features_Evaluation_Words.to_numpy()[int(i)])))
            in_evaluation_word_eval=in_evaluation_word_eval.tolist()
        for i in trai_test_set: #Entrada a gga_word (Test)
            in_evaluation_word_trai_test=np.concatenate((np.array(in_evaluation_word_trai_test),np.array(Features_Training_Testing_Words.to_numpy()[int(i)])))
            in_evaluation_word_trai_test=in_evaluation_word_trai_test.tolist()
        for n in range(num_groups):
            m=feat_comb_list.to_numpy()[index_feat_comb_list[0]][2+n]
            ELM_words_pred_eval_row=eng.evaluacion_word(in_evaluation_word_trai_test,in_evaluation_word_eval,15,m,nargout=1)

            if (n==0):
                for i in range(int(ELM_words_pred_eval_row.size[1]/(4))):
                    array_evaluacion_table=[];
                    array_evaluacion_table.append(ELM_words_pred_eval_row[0][(i*4):(4*(i+1))])
                    array_evaluacion_table=pd.DataFrame(array_evaluacion_table,columns=columnas_evaluacion_table)
                    ELM_words_pred_eval=pd.concat([ELM_words_pred_eval,array_evaluacion_table],ignore_index=True)
            
            else:
                ELM_words_pred_2=pd.DataFrame(columns=columnas_evaluacion_table);
                
                for i in range(int(ELM_words_pred_eval_row.size[1]/(4))):
                    array_evaluacion_table=[];
                    array_evaluacion_table.append(ELM_words_pred_eval_row[0][(i*4):(4*(i+1))])
                    array_evaluacion_table=pd.DataFrame(array_evaluacion_table,columns=columnas_evaluacion_table)
                    ELM_words_pred_2=pd.concat([ELM_words_pred_2,array_evaluacion_table],ignore_index=True)
                
                parte2=ELM_words_pred_2['pred1'].to_numpy()
                ELM_words_pred_eval.insert(3+n,'pred'+"%d" %(n+1),parte2,allow_duplicates=False)

        ELM_w_p_e=pd.concat([ELM_w_p_e,ELM_words_pred_eval],ignore_index=True)

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' FIN evaluation_word'+'\n\n')  ##
   
print(time.asctime( time.localtime(time.time()) )  + ':' +' FIN evaluation_word'+'\n\n')  ##

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' Calculamos Y escribimos resultados de prediccion'+'\n\n')  ##
 
print(time.asctime( time.localtime(time.time()) )  + ':' +' Calculamos Y escribimos resultados de prediccion'+'\n\n')  ##

z=0

#####Escribo en .txt para borrar lo anterior#############################
file_comp=open('Prediction_complete2.txt','w')                          ## 
file_comp.write(time.asctime( time.localtime(time.time()) )  +'\n\n')  ##
# file_comp.close()                                                      ##
#########################################################################
file_comp=open('Prediction.txt','w')                                   ##
file_comp.write(time.asctime( time.localtime(time.time()) )  +'\n\n')  ##
# file_comp.close()                                                      ## 
#########################################################################       


results_complete_prediction=[]

part_accu=[]
for i in range(num_groups):
    p_a="Acc"+"%d" %(i+1) 
    part_accu.append(p_a)
columnas_accu=part_accu
        
index=Reviews[Reviews['id_set']==3].index

for i in index:
    
    indexes=ELM_w_p_e[ELM_w_p_e['id_revi']==Reviews.loc[i]['id_reviews']]

 
    
    if len(indexes) != 0:
        
        prediccion_previa=Reviews.loc[i]['id_sent']
        predicciones=ELM_w_p_e[ELM_w_p_e['id_revi']==Reviews.loc[i]['id_reviews']]
        predicciones=pd.concat([predicciones],ignore_index=True)
        palabras_dict=predicciones['id_dict']
        accuracys=[]
        
        for palabra in palabras_dict:
            # print(palabra)
            accuracys.append(feat_comb_list[feat_comb_list['id_dict']==palabra].to_numpy()[0][2+num_groups:]) # en palabras_dict.to_numpy()[0] se cambia por en palabra 
            accuracys_table=pd.DataFrame(accuracys,columns=columnas_accu)
              
        prediction_complete=pd.concat([predicciones,accuracys_table],axis=1) 
        table_complete_predictions=pd.concat([table_complete_predictions,prediction_complete],ignore_index=True)
        votes=[]
        acc=[]
        
        for n in range(len(predicciones)):
            for m in range(num_groups):
                votes.append(predicciones.loc[n][3+m])
        
                acc.append(accuracys_table.loc[n][m])
                             
                            
        resenas=[]        
        
        
        negativos=votes.count(1)
        regular=votes.count(2)
        positivos=votes.count(3)
        no_aplica=votes.count(4)
        
        
        resenas.append(negativos)
        resenas.append(regular)
        resenas.append(positivos)
        resenas.append(no_aplica)
                    

        
        sent_max=[]  
        if len(resenas)!=len(set(resenas)): #Hay valores repetidos -Cogemos el valor de maximo %
            for l in range(len(resenas)):
                if resenas.count(resenas[l])>1:
                    if resenas[l] == max(resenas):
                        sent_max.append(l)
                else:
                    if resenas[l]==max(resenas):
                        sent_max.append(l)
                        
            if len(sent_max)<2:
                prediction_def=sent_max[0]+1
                
            else:
                aux=prediction_complete.to_numpy()
                accura=[]
                #Extraemos en un array todos los valores de Acc1..AccN
                for u in range(num_groups):
                    accura=np.concatenate((accura,accuracys_table['Acc'+'%d' %(u+1)].to_numpy()),axis=0)
                    accura=np.unique(accura)
                    accura.sort()
                    accura=accura[::-1]
                               
                   
               
                for x in range(accura.size):
                    coor=np.where(accuracys_table==accura[x])
                    for m in range(coor[0].size):
                        coor1=coor[0][m]
                        coor2=coor[1][m]+3+num_groups
                        prediction_def=prediction_complete.loc[coor1][coor2-num_groups]
                        if (prediction_def-1 in sent_max) == True: 
                            # print(m)
                            flag=1
                            break
                    if flag==1:
                        break
                         
                        
       
        else:
            if positivos>regular:
                if positivos>negativos:
                    if positivos > no_aplica:
                        prediction_def=3
                else:
                    if negativos > no_aplica:
                        prediction_def=1
                    else:
                        prediction_def=4
                    
            else:
                if regular > negativos:
                    if regular>no_aplica:
                        prediction_def=2
                    else:
                        prediction_def=4
                    
                else:
                    if negativos > no_aplica:
                        prediction_def=1
                    else:
                        prediction_def=4
            
        results_complete_prediction.append(prediction_def)
        file_comp=open('Prediction.txt','a')
        file_comp.write('\n'+ str(prediction_def))
        # file_comp.close()
                       
        #####Desde aquí Escribimos en documento la información obtenida#####
        frase_completa=Reviews.loc[i]['revi_content']
        # print(i)
        filas,columnas=frase_completa.size    
    
        file_comp=open('Prediction_complete2.txt','a')
        file_comp.write(time.asctime( time.localtime(time.time()) )  +'\n\n')
        file_comp.write('Nº Review:' + str(Reviews.loc[i]['id_reviews'])+'                  ')
        for palabra in palabras_dict:
            file_comp.write(my_dictionary[int(palabra)-1] +'   ')
        file_comp.write('\n\n')

        
        file_comp.write('Frase:')
        for fila in range(filas):
            palabra=frase_completa[fila][0]
            file_comp.write(my_dictionary[int(palabra)-1]+'    ')
        file_comp.write('\n\n')
        
        
        for palabra in palabras_dict:
            file_comp.write('                      '+str(palabra)+'\t')
            for r in range(num_groups):
                # print(r)
                file_comp.write('         '+str(predicciones[predicciones['id_dict']==palabra].to_numpy()[0][3+r])+'\t')
            file_comp.write('\n')

        file_comp.write('\n')
        file_comp.write('                             Sentimiento:'+ str(Reviews.loc[i]['id_sent'])+'  ')
        file_comp.write('Predición: '+str(prediction_def))


        file_comp.write('\n\n')
        # file_comp.close()
            
            
    else:
        prediction_def=0
        results_complete_prediction.append(prediction_def)
        file_comp=open('Prediction.txt','a')
        file_comp.write('\n'+ str(prediction_def))
        # file_comp.close()
        
        
        file_comp=open('Prediction_complete2.txt','a')
        file_comp.write(time.asctime( time.localtime(time.time()) )  +'\n\n')
        file_comp.write('Review:' + str(Reviews.loc[i]['id_reviews'])+'     '+'No hay palabras con voto coincidentes')
        file_comp.write('\n\n')
        # file_comp.close()
        
        #####################Hasta aquí para escribir información en el documento##############

file_comp.close()

file_comp=open('Logs.txt','a')
file_comp.write(time.asctime( time.localtime(time.time()) )  + ':' +' FIN de manera satisfactoria'+'\n\n')  ##
   
print(time.asctime( time.localtime(time.time()) )  + ':' +' FIN de manera satisfactoria'+'\n\n')  ##
