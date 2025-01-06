**file : crimini_2_ispezioneDataset.py**

**objective**: predict the type of crime that was committed based on the features. data taken from : DATA.GOV

https://catalog.data.gov/dataset/crime-data-from-2020-to-present

dataset downloaded from Data.gov relating to Crime Data from 2020 to Present by the Los Angeles Police Department (LAPD)

This is a draft code, the code and model need to be improved. In fact, forecasting performances are very low

    **sub file : crimini_3_ottimizzazione.py**
    - same code in which I included an optimization of a parameter of the chosen model, namely Logistic Regression to 
      increase performance

    **sub file : Crimini_4_confrontoModelliML**
      in this file I tried to compare 3 different classification models:
      -logistic Regression 
      -KNeighborsRanking
      -DecisionTreeClassifier

      to see if the low performance problem was due to the algorithm used,
      but not having found a good match, I will go back to clean the data in a better way.
      In the next files I will handle missing values ​​with imputation and probably perform a balancing of the dataset, 
      because 
      some classes have a significantly lower number of observations than others, and the model is not able to predict them


      Some balancing methods require too much computational effort due to the large number of observations in the dataframe 
      (around 1 million)
       - let's start from a Pre Processing of the data
      Handling missing data for each column of the dataframe, we noticed that
          *Weapon Category has 600000 rows with missing values ​​(about 63% of the dataset)
          *Victim Sex & Victim Descent approximately 132500 missing values ​​(approximately 14% of the dataset)

       Since it is very common for a crime to take place without weapons, I decided to make an imputation of this type:
        data['Weapon Category'].fillna('No Weapon', inplace=True)

       For victim sex the possible choices are ['M' 'X' 'F' nan 'H' '-'], where X is unknown, while for H, Nan, - , i have 
        inputated in 'no Victim'

        data['Victim Sex'].fillna('no Vict', inplace=True)
        data['Victim Sex'].replace('-', 'no Vict', inplace=True)
        data['Victim Sex'].replace('H', 'no Vict', inplace=True)

       
**file: crimes_5_Balanciamento_giusto.py**

we made the inputations but the performance remained low
now we will do two things:
data preprocessing: (dimensionality reduction + Data Pruning)  reducing the number of features and the number of redundant observations -2) once done we will try again to use an Over-sampling Balancing technique such as SMOTE

**file : Crimini_6_prova_risoluzione_errori**

- fixed printing errors
decided to use another ML model more appropriate for datasets with high dimensionality and numerous observations called LIGHTGBM, the performance improved slightly.

**FINAL CONSIDERATIONS FROM CLASSIFICATION REPORT UPLOADED "final_Considerations_Crimini_6"**

**Classification Report Overview**
**Precision**: Proportion of true positives among predicted positives. Measures accuracy of positive predictions.
**Recall**: Proportion of true positives captured among actual positives. Measures ability to find all positives.
**F1-score**: Harmonic mean of precision and recall. Useful for balance between precision and recall.
**Support**: Number of actual occurrences of each class in the test set.

the unique class well predicted is MVT ( Motor Vehicle Theft ) 

**MVT**

- Precision: 0.80 – 80% of predicted MVT cases are correct.
- Recall: 0.99 – 99% of actual MVT cases were correctly identified.
- F1-score: 0.89 – Strong performance in balancing precision and recall.

**Other theft**

- Model captures a good number of theft cases ( high recall ) but precision is moderate

the Others classes have poor performance , likely due to low support and Class imbalance issues.


[I was aware of the classes not being well balanced and I tried with some OVer Sampling methods but they were very heavy from a computational point of view and it crashed during execution, so I opted to change the model from Logistic Regression to one like LightGBM which was better suited for my type of dataset but without obtaining great results ]



