file : crimini_2_ispezioneDataset.py

objective: predict the type of crime that was committed based on the features. data taken from : DATA.GOV

https://catalog.data.gov/dataset/crime-data-from-2020-to-present

dataset downloaded from Data.gov relating to Crime Data from 2020 to Present by the Los Angeles Police Department (LAPD)

This is a draft code, the code and model need to be improved. In fact, forecasting performances are very low

sub file : crimini_3_ottimizzazione.py
 - same code in which I included an optimization of a parameter of the chosen model, namely Logistic Regression to increase performance

sub file : Crimini_4_confrontoModelliML
 in this file I tried to compare 3 different classification models:
 -logistic Regression 
 -KNeighborsRanking
 -DecisionTreeClassifier

 to see if the low performance problem was due to the algorithm used,
  but not having found a good match, I will go back to clean the data in a better way.
     In the next files I will handle missing values ​​with imputation and probably perform a balancing of the dataset, because some classes have a significantly lower 
     number of observations than others, and the model is not able to predict them

 Alcuni metodi di bilanciamento richiedono uno sforzo computazionale troppo elevato a causa del grosso numero di osservazioni nel dataframe (circa 1 milione)
 - ripartiamo da un Pre Processing dei dati
      Gestione dati mancanti per ciascuna colonna del dataframe, abbiamo notato che
          *Weapon Category ha 600000 righe con valori mancanti (circa 63% del dataset)
          *Victim Sex & Victim Descent circa 132500 valori mancanti ( circa il 14% del dataset)

       Visto che è molto frequente che un crimine si svolga senza armi ho deciso di fare un imputazione di questo tipo :
        data['Weapon Category'].fillna('No Weapon', inplace=True)

       Per victim sex le possibili scelte ['M' 'X' 'F' nan 'H' '-'] , dove X è unknown , mentre H, nan , - , le inputo come no Victim
        data['Victim Sex'].fillna('no Vict', inplace=True)
        data['Victim Sex'].replace('-', 'no Vict', inplace=True)
        data['Victim Sex'].replace('H', 'no Vict', inplace=True)

       Per victim Descent le possibili scelte , dove nan, - le inputo come no Vict
        data['Victim Sex'].fillna('no Vict', inplace=True)
        data['Victim Sex'].replace('-', 'no Vict', inplace=True)
file : crimini_5_Bilanciamento_giusto.py

abbiamo apportato le imputazioni ma le performance sono rimaste basse
ora faremo due cose :
preprocessing dei dati : ( dimensionality reduction + Data Pruning ) ovvero ridurre il numero di features e il numero di osservazioni rindondanti -2) una volta fatto andremo a riprovare ad utilizzare una tecnica di Bilnciamneto di Over-sampling come SMOTE
file : Crimini_6_prova_risoluzione_errori

sistemato errori che stampava
deciso di utilizzare un altro modello di ML più appropriato per dataset con alta dimenisonalità e numerose osservazioni chiamato LIGHTGBM , le performance sono leggermente migliorate.
