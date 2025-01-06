
library(ggplot2)   
data <- read.csv('distribution_world_Event.csv', header = TRUE)


# Carica il tuo file CSV
data <- read.csv('distribution_world_Event.csv', header = TRUE)

# Creazione di una stima della densità
#plot(density(data$news_resonance), 
     #main = "Stima della Densità", 
     #xlab = "Valori", 
     #ylab = "Densità", 
     #col = "blue", 
     #lwd = 2)

# Imposta il layout della finestra del grafico
par(mfrow = c(2, 1))  # 2 righe, 1 colonna

# Creazione di una stima della densità
plot(density(data$news_resonance), 
     main = "Stima della Densità", 
     xlab = "Valori", 
     ylab = "Densità", 
     col = "blue", 
     lwd = 2)

# Aggiungi linee per Q1 e Q3
Q1 <- quantile(data$news_resonance, 0.25)
Q3 <- quantile(data$news_resonance, 0.75)

abline(v = Q1, col = "orange", lwd = 2, lty = 2)  # Linea verticale per Q1
abline(v = Q3, col = "orange", lwd = 2, lty = 2)  # Linea verticale per Q3

# Calcolo dell'IQR e limite superiore
IQR_value <- IQR(data$news_resonance)
upper_limit <- Q3 + 1.5 * IQR_value
abline(v = upper_limit, col = "red", lwd = 2, lty = 2)  # Linea verticale per il limite superiore

# Creazione del boxplot
boxplot(data$news_resonance, 
        main = "Boxplot della Risonanza delle News", 
        horizontal = TRUE, 
        col = "lightgray", 
        border = "black", 
        notch = TRUE)

# Ripristina il layout originale
par(mfrow = c(1, 1))


# distribuzione assimietrica a destra

# calcoliamo Q3 il primo 75 percentile della distribuzione
Q3 <- quantile(data$news_resonance, 0.75)

# per il nostro scopo tutto quello che viene dopo quel Q3 è rilevante e diventa dummy attributo "yes"
data$anomaly <- ifelse(data$news_resonance > Q3, "Yes", "No")

# Supponiamo che tu abbia già creato il tuo dataframe, chiamato 'data'

# Percorso completo dove vuoi salvare il file CSV
file_path <- "C:/Users/andre/OneDrive/Desktop/usi/USI/TERZO ANNO/SEMESTRE AUTUNNALE/Econometria/progetto_SanGallo/regression_nfpdays - Copia_per_esperimenti/final_merge_oro_e_news/my_dataframe.csv"

# Esporta il dataframe come file CSV
write.csv(data, file = file_path, row.names = FALSE)

# Controlla se il file è stato creato
if (file.exists(file_path)) {
  print("Il file è stato esportato con successo.")
} else {
  print("Si è verificato un errore nell'esportazione del file.")
}




