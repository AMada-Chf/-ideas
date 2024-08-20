# importo libreria che ha dei metodi che useremo 
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats

# specifichiamo il percorso del mio csv

csv_algo = 'C:/Users/User/Desktop/spunti_statistica_python/validazione_strategia_conPython/rendimenti_Algo.csv'


# leggiamo file csv in un Dataframe (formato come tabella)pandas
df = pd.read_csv(csv_algo, sep=';') 

# visualizzimamo le prime 5 righe del 
#print(df.head())

# togli la prima colonna "ovvero che ha indice 0",  converte in array .values.flatten() ,  converte in lista .tolist()
rendimenti_mensili = df.iloc[:, 1:].values.flatten()

#togli elementi Nan
rendimenti_mensili_senza_Nan = rendimenti_mensili[~np.isnan(rendimenti_mensili)]

print(rendimenti_mensili_senza_Nan)

# creiamo distribuzione dei rendimenti algo
plt.hist(rendimenti_mensili_senza_Nan,bins = 100, alpha = 0.40, density= True, label = 'RENIDIMENTI_ALGO')

plt.show()

#media algo
print(rendimenti_mensili_senza_Nan.mean(),rendimenti_mensili_senza_Nan.std())

# VERIFICA DI IPOTESI 
t_statistic,p_value = stats.ttest_1samp(rendimenti_mensili_senza_Nan, 0)
# print(verifica_ipotesi)

print(f"t-statistic: {t_statistic:.4f}")
print(f"p-value: {p_value:.4f}")

if p_value < 0.05:
    print("ci sono sufficienti prove per affermare ch i rendimenti non sono casuali")


#------------------------------------SHARPE RATIO---------------------------------------------------------------------
bond_yearly = 2 
rendimento_bond_monthly = 2/12

media_rendimenti_algo = rendimenti_mensili_senza_Nan.mean()
deviaz_standard_rendimenti_algo = rendimenti_mensili_senza_Nan.std()


sharpe_ratio = (media_rendimenti_algo-rendimento_bond_monthly)/deviaz_standard_rendimenti_algo
print(sharpe_ratio)

# interpretazione risultato
# Un Sharpe Ratio di 0.367 indica che per ogni unità di rischio assunta, 
# l'investimento ha generato un rendimento aggiuntivo di circa 0.367 unità rispetto al tasso privo di rischio

#----------------------------------------------------------------------------------------------------------------
