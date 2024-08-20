import pandas as pd 
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.pipeline import Pipeline
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import GridSearchCV

# HO PRESO DATASET DAL SITO DEL DATA.GOV 
  # #https://catalog.data.gov/dataset/crime-data-from-2020-to-present

# importazione del csv
csv_crime  = 'C:/Users/User/Desktop/dataset/Crime_Data_from_2020_to_Present.csv'

Crime2_df = pd.read_csv(csv_crime, sep = ",")
#print(Crime2_df.columns.tolist())
#new_df = Crime2_df[["Crm Cd 1", "Crm Cd Desc"]]
#print(new_df.head(500))

# Creazione del dizionario di mapping basato sull'immagine fornita
crime_mapping = {
    110: 'Homicide', 113: 'Homicide', 
    121: 'Rape', 122: 'Rape', 815: 'Rape', 820: 'Rape', 821:'Rape',812:'Rape',810:'Rape',
    210: 'Robbery', 220: 'Robbery', 
    230: 'Agg.Assault', 231: 'Agg.Assault', 235: 'Agg.Assault', 236: 'Domestic Violence', 251: 'Domestic Violence',250: 'Domestic Violence',
    926: 'Domestic Violence', 761: 'Domestic Violence', 

    435: 'Simple Assault', 436: 'Simple Assault', 437: 'Simple Assault',
    622: 'Simple Assault',  623: 'Simple Assault', 624: 'Simple Assault', 625: 'Simple Assault', 626: 'Domestic Violence', 627: 'Domestic Violence',
    647: 'Domestic Violence', 763: 'Domestic Violence', 928: 'Domestic Violence', 930: 'Domestic Violence', 956: 'Domestic Violence', 901: 'Domestic Violence', 902:'Domestic Violence',

    310: 'Burglary', 320: 'Burglary', 
 
    510: 'MVT', 420: 'MVT', 433: 'MVT', 
    330: 'BTFV', 331: 'BTFV',  410: 'BTFV',  420: 'BTFV', 421: 'BTFV',
    350: 'Personal Theft',351: 'Personal Theft',352: 'Personal Theft',353: 'Personal Theft',450: 'Personal Theft',451: 'Personal Theft',452: 'Personal Theft',453: 'Personal Theft',

    341: 'Other Theft', 343: 'Other Theft', 345: 'Other Theft', 440: 'Other Theft', 
    441: 'Other Theft', 442: 'Other Theft', 443: 'Other Theft', 444: 'Other Theft', 445: 'Other Theft',
    470: 'Other Theft', 471: 'Other Theft', 472: 'Other Theft', 473: 'Other Theft', 474: 'Other Theft', 475: 'Other Theft', 520:'Other Theft',
    480: 'Other Theft', 485: 'Other Theft', 487: 'Other Theft', 491: 'Other Theft', 354: 'Other Theft',668: 'Other Theft',669: 'Other Theft',662: 'Other Theft',
    888: 'Trepassing',745:'Vandalism',740:'Vandalism',
    745:'Vandalism'  ,

    886:'Minors',813:'Minors'
}

# Definisci il dizionario di mappatura
weapon_mapping = {
    'STRONG-ARM (HANDS, FIST, FEET OR BODILY FORCE)': 'Other',
    'VEHICLE': 'Other',
    'UNKNOWN WEAPON/OTHER WEAPON': 'Other',
    'VERBAL THREAT': 'Other',
    'BELT FLAILING INSTRUMENT/CHAIN': 'Blunt Objects',
    'HAND GUN': 'Firearms',
    'UNKNOWN FIREARM': 'Firearms',
    'KNIFE WITH BLADE 6INCHES OR LESS': 'Sharp Objects',
    'FIXED OBJECT': 'Blunt Objects',
    'KITCHEN KNIFE': 'Sharp Objects',
    'MACHETE': 'Sharp Objects',
    'UNKNOWN TYPE CUTTING INSTRUMENT': 'Sharp Objects',
    'MACE/PEPPER SPRAY': 'Other',
    'STICK': 'Blunt Objects',
    'OTHER KNIFE': 'Sharp Objects',
    'PHYSICAL PRESENCE': 'Other',
    'KNIFE WITH BLADE OVER 6 INCHES IN LENGTH': 'Sharp Objects',
    'HAMMER': 'Blunt Objects',
    'AIR PISTOL/REVOLVER/RIFLE/BB GUN': 'Firearms',
    'SEMI-AUTOMATIC PISTOL': 'Firearms',
    'SIMULATED GUN': 'Firearms',
    'RAZOR': 'Sharp Objects',
    'OTHER FIREARM': 'Firearms',
    'FOLDING KNIFE': 'Sharp Objects',
    'PIPE/METAL PIPE': 'Blunt Objects',
    'ROCK/THROWN OBJECT': 'Blunt Objects',
    'RIFLE': 'Firearms',
    'OTHER CUTTING INSTRUMENT': 'Sharp Objects',
    'FIRE': 'Other',
    'REVOLVER': 'Firearms',
    'BOTTLE': 'Blunt Objects',
    'SCISSORS': 'Sharp Objects',
    'SWITCH BLADE': 'Sharp Objects',
    'BRASS KNUCKLES': 'Blunt Objects',
    'CLUB/BAT': 'Blunt Objects',
    'BLUNT INSTRUMENT': 'Blunt Objects',
    'BOARD': 'Blunt Objects',
    'STUN GUN': 'Other',
    'CLEAVER': 'Sharp Objects',
    'RAZOR BLADE': 'Sharp Objects',
    'SCREWDRIVER': 'Sharp Objects',
    'SHOTGUN': 'Firearms',
    'CONCRETE BLOCK/BRICK': 'Blunt Objects',
    'CAUSTIC CHEMICAL/POISON': 'Other',
    'SEMI-AUTOMATIC RIFLE': 'Firearms',
    'SCALDING LIQUID': 'Other',
    'TIRE IRON': 'Blunt Objects',
    'BOWIE KNIFE': 'Sharp Objects',
    'GLASS': 'Blunt Objects',
    'AXE': 'Sharp Objects',
    'TOY GUN': 'Other',
    'BOMB THREAT': 'Explosives',
    'SAWED OFF RIFLE/SHOTGUN': 'Firearms',
    'MARTIAL ARTS WEAPONS': 'Blunt Objects',
    'DEMAND NOTE': 'Other',
    'DIRK/DAGGER': 'Sharp Objects',
    'ASSAULT WEAPON/UZI/AK47/ETC': 'Firearms',
    'ROPE/LIGATURE': 'Other',
    'HECKLER & KOCH 93 SEMIAUTOMATIC ASSAULT RIFLE': 'Firearms',
    'EXPLOSIVE DEVICE': 'Explosives',
    'SWORD': 'Sharp Objects',
    'MAC-11 SEMIAUTOMATIC ASSAULT WEAPON': 'Firearms',
    'SYRINGE': 'Other',
    'BOW AND ARROW': 'Other',
    'LIQUOR/DRUGS': 'Other',
    'DOG/ANIMAL (SIC ANIMAL ON)': 'Other',
    'BLACKJACK': 'Blunt Objects',
    'ICE PICK': 'Sharp Objects',
    'RELIC FIREARM': 'Firearms',
    'AUTOMATIC WEAPON/SUB-MACHINE GUN': 'Firearms',
    'ANTIQUE FIREARM': 'Firearms',
    'HECKLER & KOCH 91 SEMIAUTOMATIC ASSAULT RIFLE': 'Firearms',
    'STRAIGHT RAZOR': 'Sharp Objects',
    'M1-1 SEMIAUTOMATIC ASSAULT RIFLE': 'Firearms',
    'STARTER PISTOL/REVOLVER': 'Firearms',
    'UZI SEMIAUTOMATIC ASSAULT RIFLE': 'Firearms',
    'MAC-10 SEMIAUTOMATIC ASSAULT WEAPON': 'Firearms',
    'UNK TYPE SEMIAUTOMATIC ASSAULT RIFLE': 'Firearms',
    'M-14 SEMIAUTOMATIC ASSAULT RIFLE': 'Firearms'
}

area_mapping = {
    'Wilshire': 'West',
    'Central': 'Central',
    'Southwest': 'South',
    'Van Nuys': 'North',
    'Hollywood': 'West',
    'Southeast': 'South',
    'Newton': 'East',
    'Mission': 'West',
    'Rampart': 'Central',
    'West Valley': 'North',
    'West LA': 'North',
    'Olympic': 'Central',
    'Hollenbeck': 'East',
    'Topanga': 'West',
    'Northeast': 'East',
    '77th Street': 'South',
    'Pacific': 'West',
    'N Hollywood': 'North',
    'Harbor': 'South',
    'Foothill': 'North',
    'Devonshire': 'North'
}




# Definisci la funzione per categorizzare gli orari
def categorize_time(time):
    if 600 <= time < 1200:
        return 'Morning'
    elif 1200 <= time < 1800:
        return 'Afternoon'
    elif 1800 <= time < 2400:
        return 'Evening'
    else:
        return 'Night'
    


 # Converti la colonna delle date in formato datetime
Crime2_df['DATE OCC'] = pd.to_datetime(Crime2_df['DATE OCC'], format='%m/%d/%Y %I:%M:%S %p') 

# Definisci una funzione per mappare i mesi alle stagioni
def get_season(date):
    month = date.month
    if month in [12, 1, 2]:
        return 'Winter'
    elif month in [3, 4, 5]:
        return 'Spring'
    elif month in [6, 7, 8]:
        return 'Summer'
    elif month in [9, 10, 11]:
        return 'Fall'

#CREARE COLONNA STAGIONE 
Crime2_df['Season'] = Crime2_df['DATE OCC'].apply(get_season)

# CREARE COLONNA PER ZONA DI LOS ANGELES
Crime2_df['Macro Area'] = Crime2_df['AREA NAME'].map(area_mapping)

# ORA ABBIAMO CREATO QUESTA COLONNA CHE AL POSTO DELL'ORARIO 1358 distingue semplicemente tra "Mattino, pome , sera,notte"
Crime2_df['TIME CATEGORY'] = Crime2_df['TIME OCC'].apply(categorize_time)

# Creare una nuova colonna 'Crime Category' utilizzando il mapping
Crime2_df['Crime Category'] = Crime2_df['Crm Cd 1'].map(crime_mapping)

# Sostituire i valori NaN con 'Others'
Crime2_df['Crime Category'].fillna('Others', inplace=True)




#Casi_con_Armi = Crime2_df[Crime2_df['Weapon Used Cd'].notnull()]
#print(Casi_con_Armi[['Weapon Used Cd', 'Weapon Desc']])




# Mappa le descrizioni delle armi in macro categorie
Crime2_df['Weapon Category'] = Crime2_df['Weapon Desc'].map(weapon_mapping)

#print(Crime2_df[['Crime Category','Weapon Category','TIME CATEGORY','AREA NAME','AREA','Macro Area','Season','Vict Sex','Vict Descent','Vict Age']].head(800))

dataset_Nuovo = Crime2_df[['Weapon Category','TIME CATEGORY','Macro Area','Season','Vict Sex','Vict Descent','Vict Age','Crime Category']]
#print(dataset_Nuovo.iloc[60000:120000]) # dalla riga 900 alla 1200

#print(Crime2_df.columns.tolist())

# Mostra tutti i valori unici nella colonna 'Weapon Desc'
#età = Crime2_df['Crime Category'].unique()

# Stampa i valori unici
#print(età)
#----------------------------------------------------------------GESTIONE FEATURE AGE VICT----------------------------------------------
    #1) gestione degli outiliers  ( elimino righe del dataset in cui l'età è un valore negativo o superiore a 100)

dataset_Nuovo_Pulito_Outliers = dataset_Nuovo[(dataset_Nuovo['Vict Age'] >= 0) & (dataset_Nuovo['Vict Age'] <= 100)]

# verificare ora tutti i possibili valori che ha la feature Vict age
età_nuovo = dataset_Nuovo_Pulito_Outliers['Vict Age'].unique()
#print(età_nuovo)
  # ok ora il dataset non contiene piu valori outliers ( quante osservazioni abbiamo perso??)

# controllo di non aver perso troppe osservazioni con questa modifica 
#print(dataset_Nuovo.shape[0]) # numero righe dataset prima 
#print(dataset_Nuovo_Pulito_Outliers.shape[0]) # numero righe dataset dopo modifica
# risultato : ottimo perchè dopo la rimozione delle righe con età anomala, il dataset ha subito una riduzione di circa lo 0,0134%.

# 2) Standardizzazione  variabile 

X = dataset_Nuovo_Pulito_Outliers.drop('Crime Category', axis=1)
y = dataset_Nuovo_Pulito_Outliers['Crime Category']

# Crea variabili dummy per tutte le colonne categoriali
X_dummies = pd.get_dummies(X, drop_first=True)
#print(X_dummies.head()) per vedere come sono cambiate le colonne  

# suddivisione dei dati 
X_train, X_test, y_train, y_test = train_test_split(X_dummies, y, test_size=0.2, random_state=42)

#----------------------------- MODELLO ML SCELTO: LOGISTIC REGRESSION

# Definisci la pipeline
pipeline = Pipeline([
    ('scaler', StandardScaler()),  # Step di standardizzazione
    ('logreg', LogisticRegression(random_state=42))  # Step del modello
])

# Definisci la griglia dei parametri (semplificata per testare prima)
param_grid = {
    'logreg__C': [0.01, 0.1, 1]  # Proviamo con 5 valori diversi di C
}


#Definisci la Grid Search con 5-fold cross-validation
grid_search = GridSearchCV(pipeline, param_grid, cv=5, scoring='accuracy', n_jobs=-1, verbose=1)

# Esegui la ricerca sui dati di addestramento
grid_search.fit(X_train, y_train)

# Ottieni i migliori parametri
print("Best Parameters:", grid_search.best_params_)
print("Best Cross-Validation Accuracy:", grid_search.best_score_)


# Miglior modello dopo la grid search
best_model = grid_search.best_estimator_

# Fai previsioni sui dati di test
y_pred = best_model.predict(X_test)

# Calcola e stampa la Confusion Matrix
from sklearn.metrics import confusion_matrix, classification_report

conf_matrix = confusion_matrix(y_test, y_pred)
#print("Confusion Matrix:\n", conf_matrix)

# Calcola e stampa il Classification Report
class_report = classification_report(y_test, y_pred)
print("Classification Report:\n", class_report)
























