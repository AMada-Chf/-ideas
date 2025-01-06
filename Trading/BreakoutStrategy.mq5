//+------------------------------------------------------------------+
//|                                        StrategiaBreakout_V02.mq5 |
//|                              
//|                                 |
//+------------------------------------------------------------------+
#property copyright 
#property link      
#property version   "2.00"

#include <ModelloInclude_V01.mqh>



/*
SPIEGAZIONE LOGICA STRATEGIA
Coppie di valute: qualsiasi
Timeframe: preferibilmente H1 e superiori
Logica esaminata ad apertura di barra

Inserimento dei parametri per gestire:
   rischio percentuale per calcolo del volume col metodo Fixed Fractional
   barre scansionate per determinae i livelli di ingresso
   gap per determinae i livelli di ingresso
   barre di validità ordini pendenti
   l'indicatore ATR utilizzato per il calcolo di stoploss e takeprofit

Regole d'acquisto
   Calcolo il range scansionando N barre a ritroso e determino i livelli di prezzo minimo e massio raggiunti
   Filtro orario che determina la valutazione delle regole di ingresso
	Posiziono un Buy Stop sopra livello di prezzo max del range + gap, solamente se non ci sono ordini a mercato e se non ci sono ordini pendenti
	SL e TP calcolati in base all'indicatore Atr e fattori gestiti da parametri esterni
	Volume calcolato col metodo Fixed Fractional con rischio gestito tramite parametro esterno
	Cancellazione ordine pendente definita come numero barre trascorse dall'inserimento e gestita con parametro esterno
	In caso di ingresso a mercato, l'ordine pendente Sell Stop verrà cancellato 

Regole di vendita
   Calcolo il range scansionando N barre a ritroso e determino i livelli di prezzo minimo e massio raggiunti
   Filtro orario che determina la valutazione delle regole di ingresso
	Posiziono un Sell Stop sotto livello di prezzo min del range - gap, solamente se non ci sono ordini a mercato e se non ci sono ordini pendenti
	SL e TP calcolati in base all'indicatore Atr e fattori gestiti da parametri esterni
	Volume calcolato col metodo Fixed Fractional con rischio gestito tramite parametro esterno
	Cancellazione ordine pendente definita come numero barre trascorse dall'inserimento e gestita con parametro esterno
	In caso di ingresso a mercato, l'ordine pendente Buy Stop verrà cancellato 
*/




//+------------------------------------------------------------------+
//| Dichiarazione variabili globali esterne                          |
//+------------------------------------------------------------------+
input int MagicNumber = 12345;  // Magic Number identificativo univoco dell'EA
input double RiskPercent =1.5;// Percentuale rischio FF

input int BarreInEsame = 20;
input int GapEntry = 5;
input int BarsValid = 1;

input int atrPeriod=14;
input int atrBars=24;
input double atrSLFactor=0.5;
input double atrTPFactor=2;


    //VARIABILI PER GESTIRE IL FILTRO GIORNI SETTIMANA
    input bool    Sunday = false; //Trading consentito la domenica
    input bool    Monday = true;//Trading consentito il lunedi
    input bool    Tuesday = true;//Trading consentito il martedi
    input bool    Wednesday = true;//Trading consentito il mercoledi
    input bool    Thursday = true;//Trading consentito il giovedi
    input bool    Friday = true;//Trading consentito il venerdi


//+------------------------------------------------------------------+
//| Dichiarazione variabili globali interne                          |
//+------------------------------------------------------------------+
double LivelloMIN =0;
double LivelloMAX =0;

double atrData[]; // array per contenere i valori di ATR.
int atrHandle;
int atrDataNr;

int P;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---

   ArraySetAsSeries(atrData,true);    // impostazione  di atrData come array corrispondente ad una timeseries
   atrHandle = iATR(_Symbol, _Period, atrPeriod); // Ottenimento del controllo per l'indicatore ATR
 
   // Valorizzo la variabile P che mi servirà per rendere indipendente l'EA rispetto ai mercati quotati con cifre decimali diverse
   P = 1;
   if(_Digits == 5 || _Digits == 3 || _Digits == 1) {
      P = 10;
   }

   return(INIT_SUCCEEDED);
  }
  
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//---
  }
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   
//################## PARTE DI CODICE ESEGUITA AD OGNI TICK ##################    
    
   // -------------------- Aggiornamento dei dati attuali dell'indicatore --------------------

   atrDataNr = CopyBuffer(atrHandle, 0, 0, atrBars, atrData); // Lettura dei dati aggiornati di ATR
   
   double ATR1 = atrData[1];     // valore di ATR relativo alla barra shift 1
 
 
  // -------------------- CANCELLAZIONE --------------------
      // --- Regole di cancellazione (Long Trades) ---
      if ( fxActivePositions (ORDER_TYPE_BUY,MagicNumber )==true ){
         fxPendingDelete(ORDER_TYPE_SELL_STOP,MagicNumber);
      }
       
      // --- Regole di cancellazione (Short Trades) ---
      if ( fxActivePositions (ORDER_TYPE_SELL,MagicNumber )==true ){
         fxPendingDelete(ORDER_TYPE_BUY_STOP,MagicNumber);
      } 

      if (fxIsTradingDay(Sunday,Monday,Tuesday,Wednesday,Thursday,Friday)==false){return;} // la funzione fxIsTradingDay restituirà true o false in base alle impotazioni dei parametri di input disabilitando il trading nei giorni false


      if ( fxIsBarOpen()== false ){return;} // questa condizione determina l'esecuzione del codice successivo solo all'apertura di una nuova barra
      
      
//################## PARTE DI CODICE ESEGUITA AD APERTURA DI BARRA ##################

      int ShiftLivelloMin = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,BarreInEsame,1);
      int ShiftLivelloMax = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,BarreInEsame,1);
   
      LivelloMIN= iLow(Symbol(),PERIOD_CURRENT,ShiftLivelloMin);
      LivelloMAX= iHigh(Symbol(),PERIOD_CURRENT,ShiftLivelloMax); 
   
      double EntryLong = LivelloMAX + fxConvertPipToReal(GapEntry);
      double EntryShort = LivelloMIN - fxConvertPipToReal(GapEntry);


   // -------------------- REGOLE POSIZIONAMENTO ORDINI --------------------

      if   (ShiftLivelloMax >2 && ShiftLivelloMin>2){ // questa condizione è stata aggiunta per considerare validi solo i livelli min e max partendo da due barre precedenti quella attuale
      
         // --- Regole di ingresso (Long Trades) ---
         if ( fxActivePositions (ORDER_TYPE_BUY,MagicNumber )==false && fxActivePositions (ORDER_TYPE_SELL,MagicNumber )==false && fxPendinOrders(ORDER_TYPE_BUY_STOP,MagicNumber)== false){
            double SLPrice = EntryLong-ATR1*atrSLFactor;
            double TPPrice = EntryLong+ATR1*atrTPFactor;
            
            SLPrice= fxAdjustStopLevel(EntryLong,SLPrice); // verifica dello stoploss in base allo stoplevel
            TPPrice= fxAdjustStopLevel(EntryLong,TPPrice); // verifica del take profit in base allo stoplevel
           
            double PuntiSL = NormalizeDouble(MathAbs((EntryLong-SLPrice) /Point()),0);
            
            double FFSize= fxGetSize(0, RiskPercent,PuntiSL); // calcolo del volume operazione
            
            bool res = fxOpenOrder(Symbol(),ORDER_TYPE_BUY_STOP,FFSize,0,EntryLong,SLPrice,TPPrice,"BUY STOP",
               MagicNumber,ORDER_TIME_SPECIFIED,TimeCurrent()+BarsValid*PeriodSeconds(PERIOD_CURRENT));
         }
      
         // --- Regole di ingresso (Short Trades) ---
         if ( fxActivePositions (ORDER_TYPE_BUY,MagicNumber )==false && fxActivePositions (ORDER_TYPE_SELL,MagicNumber )==false && fxPendinOrders(ORDER_TYPE_SELL_STOP,MagicNumber)==false){
            double SLPrice = EntryShort+ATR1*atrSLFactor;
            double TPPrice = EntryShort-ATR1*atrTPFactor;
            
            SLPrice= fxAdjustStopLevel(EntryShort,SLPrice); // verifica dello stoploss in base allo stoplevel
            TPPrice= fxAdjustStopLevel(EntryShort,TPPrice); // verifica del take profit in base allo stoplevel
            
            double PuntiSL = NormalizeDouble(MathAbs((EntryShort-SLPrice) /Point()),0);
          
            double FFSize= fxGetSize(0, RiskPercent,PuntiSL); // calcolo del volume operazione
            
            bool res = fxOpenOrder(Symbol(),ORDER_TYPE_SELL_STOP,FFSize,0,EntryShort,SLPrice,TPPrice,"SELL STOP",
               MagicNumber,ORDER_TIME_SPECIFIED,TimeCurrent()+BarsValid*PeriodSeconds(PERIOD_CURRENT));
         }
      
      }


} 
   
//+------------------------------------------------------------------+









