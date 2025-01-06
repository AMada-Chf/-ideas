# Caricamento dei dati
data_Daily <- read.csv('final_merge_4.1_csv_12colonne.csv', header = TRUE)

# Eliminazione delle prime 3 righe del dataset inutili
data_Daily <- data_Daily[-(1:3), ]

#-----------------creazione volatilità media settimanale-------------------------
library(dplyr)
library(lubridate)
library(hms)
library(car)  # Caricamento del pacchetto


data_Daily <- data_Daily %>%
  # Convertiamo la colonna date in formato data
  mutate(date = as.Date(as.character(date), format = "%Y%m%d")) %>%
  # Creiamo la colonna settimana (anno e numero di settimana)
  mutate(week = format(date, "%Y-%U")) %>%
  # Raggruppiamo per settimana e ordiniamo per data
  group_by(week) %>%
  arrange(date) %>%
  # Calcoliamo la media cumulativa del daily range per la settimana
  mutate(
    cumulative_range = cumsum(dailyrange),
    count = row_number(),
    volatility_mean_week = cumulative_range / count
  ) %>%
  ungroup() %>%
  # Rimuoviamo le colonne temporanee e riposizioniamo la nuova colonna
  select(date, dayofweek, dailyrange, volatility_mean_week, everything())

# Creazione della colonna "orario Eastern Time" con valore fisso "08:30 AM"
data_Daily <- data_Daily %>%
  mutate(eastern_time = "08:30 AM") %>%  # Qui aggiungiamo la colonna
  # Creiamo la colonna datetime in Eastern Time
  mutate(eastern_datetime = as.POSIXct(paste(date, eastern_time), format = "%Y-%m-%d %I:%M %p", tz = "America/New_York")) %>%
  # Convertiamo la colonna eastern_datetime in UTC
  mutate(eastern_datetime_utc = format(eastern_datetime, tz = "UTC", usetz = FALSE, format = "%H:%M"))  # Qui estraiamo solo l'orario

print(data_Daily)

# Creare un sottodataframe senza righe con NA in nessuna colonna
filtered_data <- na.omit(data_Daily)

# Importo file con candele al minuto
data_1minute_Xauusd <- read.csv("XAUUSD1minute.csv")

#--------------------------MERGE DEI DATI ----------------------------------------------------

# Formattiamo le date
data_1minute_Xauusd <- data_1minute_Xauusd %>%
  mutate(Date = as.Date(as.character(Date), format = "%Y%m%d")) %>%
  rename(date = Date)

# Filtriamo le righe in `data_1minute_Xauusd` con date presenti in `filtered_data`
merged_data <- data_1minute_Xauusd %>%
  filter(date %in% filtered_data$date) %>%
  inner_join(filtered_data, by = "date")

# Verifica del risultato
head(merged_data)


#  dataframe si chiami merged_data
merged_data$eastern_datetime_utc_full <- paste0(merged_data$eastern_datetime_utc, ":00")



# Convertire le colonne in POSIXct
merged_data <- merged_data %>%
  mutate(
    Timestamp_POSIX = as.POSIXct(paste("1970-01-01", Timestamp), 
                                 format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
    Eastern_POSIX = as.POSIXct(paste("1970-01-01", eastern_datetime_utc_full), 
                               format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
  )

# Calcolare la differenza di tempo in minuti
merged_data <- merged_data %>%
  mutate(
    time_diff_min = abs(difftime(Timestamp_POSIX, Eastern_POSIX, units = "mins"))
  )

# Filtrare le righe con differenza ≤ 5 minuti
merged_data_interval_five <- merged_data %>%
  filter(time_diff_min <= 5) %>%
  select(-Timestamp_POSIX, -Eastern_POSIX, -time_diff_min)

# Visualizzare il risultato
print(merged_data_interval_five)


#---------------------------------------------------------------------------------------------

# Creare il dataframe giornaliero mantenendo tutte le colonne originali
volatility_news <- merged_data_interval_five %>%
  group_by(date) %>%                          # Raggruppare i dati per giorno
  summarise(
    price_range = max(High, na.rm = TRUE) - min(Low, na.rm = TRUE), # Calcolare il range
    across(everything(), first)  # Mantenere il primo valore di tutte le altre colonne
  ) %>%
  ungroup() %>%                               # Rimuovere i gruppi
  relocate(price_range, .after = date)        # Posizionare price_range dopo date


#------------------------------------ REGRESSION --------------------------------------------


model <- lm(price_range ~ volatility_mean_week + dummyRes + scostamento, 
            data = volatility_news)

#summary(model)


#-----------------------------TEST AUTOCCORELAZIONE---------------------------------------


# Eseguire il test di Durbin-Watson
dw_test <- durbinWatsonTest(model)

# Stampare i risultati del test
print(dw_test)


# INTERPRETAZIONE RISULTATI

# Più il p-value è grande rispetto a 0.05, più siamo sicuri che non ci sia autocorrelazione significativa nei residui.
    # Se il p-value è minore di 0.05 (𝑝<0.05 ) :   C'è evidenza statisticamente significativa di autocorrelazione (positiva o negativa) nei residui.  quindi i residui non sono indipendenti
    # Se il p-value è maggiore di 0.05  puoi considerare i residui indipendenti.
# Nel Tuo Caso:
 # lag Autocorrelation D-W Statistic p-value
#    1       0.2154425       1.491955    0.06


# È maggiore di 0.05 non c'è evidenza forte di autocorrelazione significativa.  p-value è vicino al limite (0.05),
#quindi potresti considerare una debole possibilità di autocorrelazione positiva.


   
# Se aveessimo fatto test accademico Durbin con (k= 3 n = 44 a= 0.05)    sarebbe uscito appunto 1.49 dove essendo compreso tra dl (1.39)   e du(1.65) xiamo in mezzo
   # siamo in una zona indeterminata
   # occorreva che d dovesse essere maggiore di 1.65 affinche si potesse rigettare ipotesi


# DETTO QUESTO SI PUO DECIDERE DI UTILIZZARE UN MODELLO CHE TENGA CONTO DELL'AUTOCORRELAZIONE OVVERO (GLS)



#-------------------------------------MODELLO TRASFORMATO -----------------------------------------------------------------------------

#STEP 1 ) ESEGUO UNA SECONDA REGRESSIONE ( et = p*et-1 + ut)  sul coefficiente p    il modello è sull 'errore obiettivo : stimare coefficiente di correlazione tra il residuo e il precedente

# Residui
res_mqo <- model$residuals # estraggo i residui della regressione 'reg1'

#estrarre numero di ossservazioni
T <- 44 # equivalente a T <- 44

# Vettore dei residui (escludendo la prima osservazione)
Ve_t <- res_mqo[2:T]

# Vettore dei residui ritardati
Ve_tm1 <- res_mqo[1:(T-1)]


# Regressione senza costante    e_t = rho e_t-1 + u_t                         
reg2 <- lm(Ve_t ~ 0 + Ve_tm1) # eseguo effettivamamente la regressione
summary(reg2)
rho_hat <-reg2$coefficients[1] # estraggo la stima di rho dal vettore dei coeff.    0.2196979



# creo la matrice P e poi trasformo le variabili
# premoltiplicando per P: P*y = P*X + P*epsilon (vedi appunti)

#
#P <- diag(T) 
#P[1,1] <- (1 - rho_hat^2)^(1/2)  # ELEMENTO IN POSIZIONE 1 1 DELLA MATRICE P E' QUELLO DIVERSO
#for(i in 2:T) {    # PER TUTTI GLI ALTRI SULLA DIAGONALE
 # P[i,i-1] <- -rho_hat   # A gradini
#}
# Controllo la matrice P appena creata
#View(P)

# Creazione della matrice P

# Supponiamo che T sia il numero di osservazioni e rho_hat sia il valore stimato di rho
T <- 44  # Sostituisci con il numero di osservazioni effettive
#rho_hat <- 0.2196979  # Sostituisci con il valore di rho stimato

# Creazione della matrice P
P <- diag(T)  # Matrice identità di dimensione T

# Primo elemento della diagonale principale
P[1, 1] <- sqrt(1 - rho_hat^2)

# Iterazione per gli elementi sopra e sotto-diagonali
for (i in 2:T) {
  P[i, i - 1] <- -rho_hat  # Elementi sotto la diagonale
  P[i - 1, i] <- -rho_hat  # Elementi sopra la diagonale
}

# Verifica della simmetria
is_symmetric <- all(P == t(P))  # Controlla se la matrice è simmetrica
cat("La matrice P è simmetrica:", is_symmetric, "\n")

# Controllo del prodotto P %*% P'
diag_check <- P %*% t(P)  # Dovrebbe essere quasi diagonale
cat("Controllo prodotto P %*% t(P):\n")
print(diag_check)

# Visualizzazione della matrice P
View(P)  # Apri la matrice in una tabella interattiva


# prendo la nostra colonna che corrispondeva alla y 
y_original <- volatility_news$price_range
X_original <- model.matrix(model)

# Trasforma la variabile dipendente
y_transformed <- P %*% y_original

# Trasforma la matrice delle variabili indipendenti
X_transformed <- P %*% X_original


#-----------------------------------eseguiamo la regressione m.q.o su y_tilde = X_tilde*Beta + Epsilon_tilde   ( A MANO COME SU CARTA)

# Calcolo manuale dei coefficienti
beta_star <- solve(t(X_transformed) %*% X_transformed) %*% t(X_transformed) %*% y_transformed

# Visualizza i coefficienti stimati
print(beta_star)


#------------------------------ COME PROVA UTILIZZO DI  NUOVO LA FUNZIONE LM che fa la stessa cosa 

model_transformed <- lm(y_transformed ~ X_transformed - 1)  # "-1" per escludere l'intercetta
summary(model_transformed)

# Perché il Modello Trasformato Risolve l'Autocorrelazione
# Trasformazione delle Variabili:
 # Moltiplicando le variabili y e x per P(p) hai creato una nuova versione del modello in cui i residui non dovrebbero più essere correlati tra loro.

# Rimozione dell'Autocorrelazione
 # La trasformazione rimuove l'effetto di p (il grado di correlazione tra i residui consecutivi) e ricentra il modello per rendere i residui bianchi (cioè indipendenti e non correlati).


# ANCHE SE IL MODELLO TRASFORMATO E' PROGETTATO PER ELIMINARE AUTOCORRELAZIONE , E' SEMPRE BUONA PRATICA VERIFICARLO UTILIZZANDO DI NUOVO IL DURBIN 
# SUI RESIDUI DEL NUOVO MODELLO

#------------------------------- QUESTO E' FATTO PER MODELLI NON TRASFORMATI LM SI APSETTTA VARIABILI ORIGINALI #---------------------

# Eseguire il test di Durbin-Watson
#dw_test2 <- durbinWatsonTest(model_transformed)

# Stampare i risultati del test
#print(dw_test)
#------------------------------------------------------------------------------------------------------------------------------------

resid_transformed <- residuals(model_transformed)
durbinWatsonTest(resid_transformed)  # 2.4361   # elkiminazione autocorrelazione avvenuta con successo 

