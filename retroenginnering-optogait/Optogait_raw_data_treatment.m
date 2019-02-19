%%extraction des données du fichier XML
%/!\ attention, les adresses sont basées spécifiquement sur les fichiers 
%directement extraits de l'optogait sur le poste dédié à l'acquisition,
%enregistrer des modifications avec une version différente de Excel (ou
%avec une même version, a vérifier) engendre des modifications dans la
%structure et va générer des erreurs
main = parseXML('3_box_pose_with_qualisys.xml');    %reading of the file, following a tree organization. might take some time to compute
dim_array_row=(size(main(2).Children(6).Children(2).Children,2)-1)/2;  %get the number of rows of the array
dim_array_col_tot=(size(main(2).Children(6).Children(2).Children(2).Children,2)-1)/2;  %get the number of columns
%get the raw values and fill a 'data' array with strings.
for i=1:dim_array_row
    dim_array_col=(size(main(2).Children(6).Children(2).Children(i*2).Children,2)-1)/2; 
    for j=1:dim_array_col          
        data(i,j)=string(main(2).Children(6).Children(2).Children(i*2).Children(j*2).Children(2).Children.Data); %the 'adress' of the value in the tree        
    end
end 
data=fillmissing(data,'constant',"0"); %fill the <missing> data with strings of 0, to ease the next steps of the algorithm
for i=1:dim_array_row-1 %only get the timestamp, as a numerical value, to facilitate the following incrementation
    only_numerical(i,1)=str2num(data(i+1,4));
end
for i=1:dim_array_row-1 %only get numerical values for the edges detected by the optogait
    for j=1:dim_array_col_tot/2-2
        only_numerical(i,j+1)=str2num(data(i+1,j*2+3));
    end
end

%cleaning the noise made by the qualisys
%deleting false edges
only_numerical_1=only_numerical;    %only temporary to work on a clean base
threshold=3 %The min number of led that have to be lit to be considered as an object
for i=1:size(only_numerical_1,1)    %go through the whole array
    j=3;    %will select the second edge
    while j<size(only_numerical_1)
        if only_numerical_1(i,j)==288   %if the selected cell is equal to 288 it means it has reached the end and breaks out the loop
            break;
        end
        %if the cell n-1 is smaller than the the cell n by a a value 
        %inferior to the threshold, it is considered as an arefact and 
        %the on or two cell concerned are deleted by shifting the position
        %of the neighbouring cell
        if only_numerical_1(i,j)-only_numerical_1(i,j-1)<threshold  
            if j==3
                only_numerical_1(i,j:end-1)=only_numerical_1(i,j+1:end);    %shift position only by one when at the beginning of the row
                only_numerical_1(i,end-1:end)=0;    %place a zero at the 'space' left by the shifting
            else
                only_numerical_1(i,j-1:end-2)=only_numerical_1(i,j+1:end);  %shift position by 2 to delete the pair of value that are too close
                only_numerical_1(i,end-2:end)=0;    %place zeros at the 'space' left by shifting
            end
            j=2;    %set j back at two to start over at the beginning of the row
        end
        j=j+1;
    end
end

%Theorically, with a hollow foot, the maximum number of edges detected is
%10. If a higher number of edge is detected after the first treatment, the
%concerned row is considered as an error and is deleted.
only_numerical_2=only_numerical_1   %only temporary to work on a clean base
j=1;
for i=1:size(only_numerical_1,1)    
    if only_numerical_1(i,12)~=0    %if there is more than 10 edges it means a value different than 0 would be present in the 12th cell of the row
        row_to_del(j)=i;    %creates a list of row to delete
        j=j+1;
    end
end
only_numerical_2(row_to_del,:)=[];  %delete the rows with too many edges
only_numerical_3(1:size(onl

%Deleting the blincking effect between true/false state of the led. If the
%state at the row n+1 is the same as the row n, the row n+1 is deleted
j=1;    %to increment the array row_to_del
for i=1:dim_array_row-2 %go through the array
    if only_numerical_trimmed(i,2:11)==only_numerical_trimmed(i+1,2:11) %check if the line n+1 is equal to the line n
        row_to_del(j)=i+1;  %if it is add the number of the row to the list of row to delete
        j=j+3;  %increment
    end
end
only_numerical_trimmed(row_to_del,:)=[];    %delete the row without interests. /!\ does not execute it twice 
