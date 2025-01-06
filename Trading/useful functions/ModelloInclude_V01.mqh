
   
   
//-----------------------------------------------------------------------------
// Funzione custom per il controllo della formazione di una nuova barra 
// la funzione restituisce (true) in caso di formazione di una nuova barra
// altrimenti restituisce (false)
// ESEMPIO :  if ( fxIsBarOpen()== false ){return;}
//-----------------------------------------------------------------------------
   bool fxIsBarOpen(){
      static datetime TempoUltimaBarra = 0; // la variabile TempoUltimaBarra è di tipo static quindi viene inizializzata solo al primo ingresso nella funzione 
      //verrà nuovamente inizializzata solo riavviando l'EA e richiamando nuovamente la funzione IsBarOpen()
      
      datetime TempoBarraAttuale = (datetime)SeriesInfoInteger(_Symbol,PERIOD_CURRENT,SERIES_LASTBAR_DATE); //acquisisco l'orario di apertura della barra attualmente in formazione 
      if(TempoUltimaBarra != TempoBarraAttuale){
         TempoUltimaBarra = TempoBarraAttuale;
         return (true);
      }else{
         return(false);
      }
   }  
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------



//-----------------------------------------------------------------------------
// Converte in numero reale il numero di pips fornito come argomento
// ESEMPIO :  double result = fxConvertPipToReal(50);
//-----------------------------------------------------------------------------
   double fxConvertPipToReal(double argPip){
         double real_val=0;
         if(Digits()==3 || Digits()==5){
            real_val=argPip*Point()*10;
              }else{
            real_val=argPip*Point();
           }
         return(NormalizeDouble(real_val,Digits()));
   }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Restituisce il prezzo Ask corrente
// ESEMPIO :  double ask = Ask();
//-----------------------------------------------------------------------------
   double Ask(string argSymbol=NULL){
      if(argSymbol == NULL) {argSymbol = _Symbol;}
      return(NormalizeDouble(SymbolInfoDouble(argSymbol,SYMBOL_ASK),_Digits));
   }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
  
//-----------------------------------------------------------------------------
// Restituisce il prezzo Bid corrente
// ESEMPIO :  double bid = Bid();
//-----------------------------------------------------------------------------
   double Bid(string argSymbol=NULL){
      if(argSymbol == NULL) {argSymbol = _Symbol;}
      return(NormalizeDouble(SymbolInfoDouble(argSymbol,SYMBOL_BID),_Digits));
   }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------







//-----------------------------------------------------------------------------
// Calcola il valore di prezzo normalizzato dello stoploss in base al tipo di ordine, al prezzo ingresso dell'ordine e al numero di pip di stoploss
// ESEMPIO :  double SLPrice = fxStopLoss(ORDER_TYPE_BUY,Ask,20);
//-----------------------------------------------------------------------------
   double fxStopLoss (int argType, double argOpenPrice, int argSL){
      double p=Point();
      if (MathMod(Digits(),2)==1){
         p*=10;
      }
      
      if (argSL== 0){ return(0);}
      if( argType == ORDER_TYPE_BUY  || argType == ORDER_TYPE_BUY_STOP  || argType == ORDER_TYPE_BUY_LIMIT ) { return(NormalizeDouble(argOpenPrice-argSL*p,Digits()));}
      if( argType == ORDER_TYPE_SELL || argType == ORDER_TYPE_SELL_STOP || argType == ORDER_TYPE_SELL_LIMIT) { return(NormalizeDouble(argOpenPrice+argSL*p,Digits()));}
      return(0); 
   }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------



	
//-----------------------------------------------------------------------------
// Calcola il valore di prezzo normalizzato del takeprofit in base al tipo di ordine, al prezzo ingresso dell'ordine e al numero di pip di take profit
// ESEMPIO :  double TPPrice = fxTakeProfit(ORDER_TYPE_SELL,Bid,20);
//-----------------------------------------------------------------------------
   double fxTakeProfit (int argType, double argOpenPrice, int argTP){
      double p=Point();
      if (MathMod(Digits(),2)==1){
         p*=10;
      }
      if (argTP== 0){ return(0);}
      if( argType == ORDER_TYPE_BUY  || argType == ORDER_TYPE_BUY_STOP  || argType == ORDER_TYPE_BUY_LIMIT) { return(NormalizeDouble(argOpenPrice+argTP*p,Digits()));}
      if( argType == ORDER_TYPE_SELL || argType == ORDER_TYPE_SELL_STOP || argType == ORDER_TYPE_SELL_LIMIT) { return(NormalizeDouble(argOpenPrice-argTP*p,Digits()));}
      return(0); 
   }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------



//-----------------------------------------------------------------------------
// FUNZIONE PER LA VERIFICA CHE IL LIVELLO DI PREZZO CheckLevel SIA ENTRO I LIMITE DELLO STOPLEVEL
// PUO ESSERE USATA AD ESEMPIO PER VERIFICARE LA CORRETTA DISTANZA DELLO STOPLOSS RISPETTO AL PREZZO DI INGRESSO  BaseLevel
// RESTITUISCE IL VALORE CORRETTO DEL PREZZO CheckLevel IN BASE ALLE LIMITAZIONI DI STOPLEVEL IMPOSTE DAL BROKER
// ESEMPIO :  StopLossPrice=AdjustStopLevel(Bid,StopLossPrice);
//-----------------------------------------------------------------------------
   double fxAdjustStopLevel(double BaseLevel,double CheckLevel){
      double Diff=MathAbs(BaseLevel-CheckLevel);// calcolo la differenza in valore assoluto tra il livello di prezzo base (BaseLevel) e il livello di prezzo da controllare (CheckLevel)
      double StopLevel = SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL) * Point(); // converto lo stoplevel da punti in reale
      if(Diff <= StopLevel) { // il prezzo da controllare non rispetta la limitazione di stoplevel
         if(BaseLevel>CheckLevel){ //esempio: caso in cui CheckLevel è lo stoploss di un ordine buy oppure CheckLevel è il takeprofit di un ordine sell
            CheckLevel=NormalizeDouble(BaseLevel-StopLevel,Digits());
         }else{
            CheckLevel=NormalizeDouble(BaseLevel+StopLevel,Digits());
         }
      }
      return (CheckLevel);
  }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------





//-----------------------------------------------------------------------------
// Gestisce lo spostamento dello stoploss a breakeven per ogni ordine a mercato,
// in base al magicnumber e ai pip di attivazione 
// ESEMPIO :  bool result = fxBreakEven(MagicNumber,30);
//-----------------------------------------------------------------------------
bool fxBreakEven(int argMagicNumber, int argBeakevenPip){
         bool response=false;
         // conversione da PIP in POINT
         if(Digits()==3 || Digits()==5){ 
            argBeakevenPip= argBeakevenPip*10;
         }  
         // esco dalla funzione se i pip di attivazione sono settati a zero
         if (argBeakevenPip==0 ) {return(false);}
         // conversione da POINT a prezzo reale
         double realSpread = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD)*Point();
         double realBeakeven =argBeakevenPip*Point()+realSpread; //per calcolo livello di attivazione breakeven
         
         int pos_total=PositionsTotal();
         for (int i = pos_total - 1; i >= 0; i-- ){
            ulong ticket=PositionGetTicket(i); //acquisisco il ticket della posizione in base all'indice
            if( ! PositionSelectByTicket(ticket)){ continue; } // seleziono la posizione in base al ticket
            if (PositionGetInteger(POSITION_MAGIC)==argMagicNumber && PositionGetString(POSITION_SYMBOL)== Symbol()){
               MqlTradeRequest request;
               ZeroMemory(request);
               MqlTradeResult result;
               ZeroMemory(result);
                  
               long posType = PositionGetInteger(POSITION_TYPE);
               double currentSL = PositionGetDouble(POSITION_SL);
               double currentTP = PositionGetDouble(POSITION_TP);
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);            

               request.action = TRADE_ACTION_SLTP;
               request.symbol = _Symbol;
               request.tp = currentTP;
               request.position=ticket;
               
               // Modifica posizione BUY
               if (posType == POSITION_TYPE_BUY){
                  double currentPrice = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                  double breakEvenPrice = openPrice + realSpread;
                  double currentProfit = currentPrice - openPrice;

                  if(currentSL < openPrice-realSpread && currentProfit >= realBeakeven){
                     request.sl = breakEvenPrice;
                     bool res=OrderSend(request,result);
                     response=true;
                  }                
                }
                
               // Modifica posizione SELL
               if (posType == POSITION_TYPE_SELL){
                  double currentPrice = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
                  double breakEvenPrice = openPrice - realSpread;
                  double currentProfit = openPrice - currentPrice;
            
                  if(currentSL > openPrice+realSpread && currentProfit >= realBeakeven){
                     request.sl = breakEvenPrice;
                     bool res=OrderSend(request,result);
                     response=true;
                  }
               }
            }//end if (PositionGetInteger             
         }// exit for
         return(response);
}
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------








//-----------------------------------------------------------------------------
// Gestisce lo spostamento dello stoploss per ogni ordine a mercato,
// effettuato con la modalità  trailing stop, in base al magicnumber, ai pip di attivazione e ai pip di step
// ESEMPIO :  bool result = fxTrailingStop(MagicNumber,30,20);
//-----------------------------------------------------------------------------
bool fxTrailingStop(int argMagicNumber, int argActivationPip,int argStepPip){
         bool response=false; 
         // conversione da PIP in POINT
         if(Digits()==3 || Digits()==5){ 
            argActivationPip= argActivationPip*10;
            argStepPip= argStepPip*10;
         }  
         // esco dalla funzione se i parametri di gestione trailing stop sono settati a zero
         if (argActivationPip==0 || argStepPip==0) {return(false);}
         
         // conversione da POINT a prezzo reale
         double realActivation =argActivationPip*Point();
         double realStep=argStepPip*Point();


         // controllo dell'attivazione del trailing stop e della conseguente gestione dello spostamento dello stoploss
         int pos_total=PositionsTotal();
         for (int i = pos_total - 1; i >= 0; i-- ){
            ulong ticket=PositionGetTicket(i); //acquisisco il ticket della posizione in base all'indice
            if( ! PositionSelectByTicket(ticket)){ continue; } // seleziono la posizione in base al ticket
            if (PositionGetInteger(POSITION_MAGIC)==argMagicNumber && PositionGetString(POSITION_SYMBOL)== Symbol()){
               MqlTradeRequest request;
               ZeroMemory(request);
               MqlTradeResult result;
               ZeroMemory(result);

               long posType = PositionGetInteger(POSITION_TYPE);
               double currentSL = PositionGetDouble(POSITION_SL);
               double currentTP = PositionGetDouble(POSITION_TP);
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);            

               request.action = TRADE_ACTION_SLTP;
               request.symbol = _Symbol;
               request.tp = currentTP;
               request.position=ticket;
               
               double Bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
               double Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      
                // Modifica ordine BUY
                if (posType == POSITION_TYPE_BUY && Bid > openPrice + realActivation ) {
                   if (currentSL == 0 || currentSL < Bid - realStep-realActivation) {
                       request.sl = Bid - realStep;
                       bool res=OrderSend(request,result);
                       response=true;
                   }   
                }
                
                // Modifica ordine SELL
                if (posType == POSITION_TYPE_SELL && Ask < openPrice - realActivation ) {
                   if (currentSL == 0 || currentSL > Ask + realStep+realActivation) {
                       request.sl = Ask+realStep;
                       bool res=OrderSend(request,result);
                       response=true;                
                   }
                }
              }//end if (PositionGetInteger             
         }// exit for
         return(response);
}
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------










//-----------------------------------------------------------------------------
// Calcola il volume da investire secondo il metodo Fixed Fractional
// il volume viene modulato in base ad percentuale fissa ed in relazione alla distanza dello stoploss dal prezzo di ingresso
// richiede i seguenti parametri 
// argMode   0 : il calcolo del capitale a rischio viene effettuato utilizzando come base di calcolo il saldo
// argMode = 1 : il calcolo del capitale a rischio viene effettuato utilizzando come base di calcolo il margine libero
// argMode = 2 : il calcolo del capitale a rischio viene effettuato utilizzando come base di calcolo il valore dell'equity (l'equity 
// argMode > 2 : il calcolo del capitale a rischio viene effettuato utilizzando come base di calcolo il saldo
// argRiskPercent = percentuale di capitale a rischio che verrà calcolato in relazione alla base di calcolo definita con argMode
// argStopLossPoints = i punti di stoploss che in genere si calcolano con la formula (Prezzo Ingresso - Prezzo SL) /Point()

// ESEMPIO :  double Size= fxGetSize(0,RiskPercent,SLpoints);
//-----------------------------------------------------------------------------
double fxGetSize(uint argMode, double argRiskPercent,double argStopLossPoints){ 
   
   double RiskPerTrade=0;
   double LotSize=0; // inizializzo la variabile LotSize a zero
   
   // Base per il calcolo del volume a seconda della modalità selezionata ------------
   double BaseCalculation=0;
   if (argMode==0){
      BaseCalculation=AccountInfoDouble(ACCOUNT_BALANCE);//calcolo in base al saldo
   }else if (argMode==1){
      BaseCalculation= AccountInfoDouble(ACCOUNT_MARGIN_FREE); //calcolo in base al margine libero
   }else if (argMode==2){
      BaseCalculation=AccountInfoDouble(ACCOUNT_EQUITY); //calcolo in base all'equity (l'equity comprende le operazioni flottanti)
   }else{
      BaseCalculation=AccountInfoDouble(ACCOUNT_BALANCE);//calcolo in base al saldo
   }
   //--------------------------------------------------------------------------------
   
   RiskPerTrade=BaseCalculation * argRiskPercent/100;
   
   if(argStopLossPoints > 0 && RiskPerTrade > 0 ) {
      LotSize = SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE) * RiskPerTrade / (MathAbs(argStopLossPoints) * SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE) * SymbolInfoDouble(Symbol(),SYMBOL_POINT) );
   }

   //--- se il volume calcolato ricade fuori dalle restrizioni min o max imposte dal broker, viene forzato al MINLOT o MAXLOT
     if(LotSize<SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN)){  LotSize=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN); }
     if(LotSize>SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX)){  LotSize=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX); }
   //--------------------------------------------

   //--- il volume viene arrotondato in base dalle restrizioni relative al LOTSTEP imposte dal broker e quindi normalizzato
    int decimals = 0; 
    if(SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP) == 0.1)   { decimals = 1; }
    if(SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP) == 0.01)  { decimals = 2; }
    if(SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP) == 0.001) { decimals = 3; }
    LotSize=NormalizeDouble(LotSize,decimals);
   //--------------------------------------------
    return (LotSize);
  }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------







//-----------------------------------------------------------------------------
// Funzione per l'invio di un ordine pendente buystop, sellstop, buylimit o sellimit
//-----------------------------------------------------------------------------
   bool fxOpenOrder(const string symbol,const ENUM_ORDER_TYPE order_type,const double volume,const double limit_price,
                       const double price,const double sl,const double tp,const string comment,const int magic,
                       ENUM_ORDER_TYPE_TIME type_time,const datetime expiration){
      MqlTradeRequest   m_request;              // request data
      MqlTradeResult    m_result;               // result data
   
   //--- reset delle strutture
      ZeroMemory(m_request);
      ZeroMemory(m_result);
   
   //--- impostazione della struttura request
      m_request.action      =TRADE_ACTION_PENDING;
      m_request.symbol      =symbol;
      m_request.magic       =magic;
      m_request.volume      =volume;
      m_request.type        =order_type;
      m_request.stoplimit   =limit_price;
      m_request.price       =price;
      m_request.sl          =sl;
      m_request.tp          =tp;
      m_request.type_time   =type_time;
      m_request.expiration  =expiration;
      m_request.comment=comment;
   
   
      //--- tentativi multipli di invio ordine con i parametri impostati nella struttura request
      int retries = 0;
      int Retry = 5; //numero di tentativi se l'invio dell'ordine restituisce errore
      int Wait = 3; //numero di secondi di attesa tra un tentativo e il successivo quando l'invio dell'ordine restituisce errore

      while((m_result.retcode != TRADE_RETCODE_DONE && m_result.retcode != TRADE_RETCODE_PLACED) && retries < Retry+1) {
            if(OrderSend(m_request,m_result)==false || (m_result.retcode != TRADE_RETCODE_DONE && m_result.retcode != TRADE_RETCODE_PLACED) ){
                Print("OrderSend error: " + m_result.comment);
                Sleep(Wait*1000);
            }else{
               return(true);
            }
            retries++;
       }      
      //---------------------------------------------------------------------------------------------   
      return(false);
      
  }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------




//-----------------------------------------------------------------------------
// Funzione per l'apertura immediata di una posizione buy o sell
//-----------------------------------------------------------------------------
   bool fxOpenPosition(const string symbol,const ENUM_ORDER_TYPE order_type,const double volume,const int deviation,
                   double price,const double sl,const double tp,const int magic,const string comment){
      MqlTradeRequest   m_request;              // request data
      MqlTradeResult    m_result;               // result data
   
   //--- reset delle strutture
      ZeroMemory(m_request);
      ZeroMemory(m_result);
   
   //--- impostazione della struttura request
      m_request.action      =TRADE_ACTION_DEAL;             // assegno il tipo di azione che verrà eseguita da OrderSend
      m_request.symbol      =symbol;                        // assegno il nome del mercato in cui verrà inviato l'ordine
      m_request.magic       =magic;                         // assegno il magic number
      m_request.volume      =volume;                        // assegno il volume dell'operazione in lotti
      m_request.type        =order_type;                    // assegno il tipo di ordine che voglio inviare
      m_request.price       =NormalizeDouble(price,_Digits);// assegno il prezzo di ingresso a mercato
      m_request.sl          =0;                             // assegno il valore 0 al prezzo dello Stop Loss
      m_request.tp          =0;                             // assegno il valore 0 al prezzo  del Profit
      m_request.type_filling = ORDER_FILLING_FOK;           // assegno il tipo di esecuzione   
      m_request.deviation  =deviation;                      // assegno il massimo valore di deviazione in punti, rispetto al prezzo richiesto per l'ingresso a mercato
      m_request.comment=comment;
      
      //--- tentativi multipli di invio ordine con i parametri impostati nella struttura request
      int retries = 0;
      int Retry = 5; //numero di tentativi se l'invio dell'ordine restituisce errore
      int Wait = 3; //numero di secondi di attesa tra un tentativo e il successivo quando l'invio dell'ordine restituisce errore

      while((m_result.retcode != TRADE_RETCODE_DONE && m_result.retcode != TRADE_RETCODE_PLACED) && retries < Retry+1) {
            MqlTick objPrice;
            SymbolInfoTick(_Symbol,objPrice);//aggiorno il prezzo prima di tentare di inviare l'ordine
            if(order_type == ORDER_TYPE_BUY){
               price = objPrice.ask;
            }else if(order_type == ORDER_TYPE_SELL){
               price = objPrice.bid;
            }else if(price < 0){ //prezzo non valido
               Print("Ordine respinto a causa del prezzo non valido");
         	   return(false);
            }
            m_request.price = NormalizeDouble(price, Digits());     
            if(OrderSend(m_request,m_result)==false || (m_result.retcode != TRADE_RETCODE_DONE && m_result.retcode != TRADE_RETCODE_PLACED) ){
                Print("OrderSend error: " + m_result.comment);
                Sleep(Wait*1000);
            }
            retries++;
       }      
      //---------------------------------------------------------------------------------------------
      
      
      //--- se i tentativi di apertura della posizione hanno successo inserisco stoplosse e takeprofit
         if(m_result.retcode == TRADE_RETCODE_DONE || m_result.retcode == TRADE_RETCODE_PLACED){
            if (PositionSelectByTicket(m_result.deal)){ 
               ZeroMemory(m_request);
               //invio la request di modifica inserendo nella posizione stoplosse e takeprofit
               m_request.action = TRADE_ACTION_SLTP;
               m_request.symbol = _Symbol;
               m_request.sl = NormalizeDouble(sl,_Digits);
               m_request.tp = NormalizeDouble(tp,_Digits);
               m_request.position=PositionGetInteger(POSITION_TICKET);
               
               ZeroMemory(m_result);
               return(OrderSend(m_request,m_result));  
            }
         }   
      //---------------------------------------------------------------------------------------------
         
      return(false);
  }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------




//-----------------------------------------------------------------------------
// Scansiona il numero di posizioni a mercato restituendo il conteggio totale
// la scansione delle posizioni viene effettuata in base al magicnumber quindi è specifica per l'EA in esecuzione
// ESEMPIO :  int result = fxPositionCount(MagicNumber);
//-----------------------------------------------------------------------------
   int fxPositionCount(int argMagicNumber){
      int Count =0;
      int pos_total=PositionsTotal();
      for (int i = pos_total - 1; i >= 0; i-- ){
         ulong ticket=PositionGetTicket(i); //acquisisco il ticket della posizione in base all'indice
         if( ! PositionSelectByTicket(ticket)){ continue; } // seleziono la posizione in base al ticket
         if (PositionGetInteger(POSITION_MAGIC)==argMagicNumber){
            Count= Count+1;
         }
      }      
      return(Count);
   }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------



//-----------------------------------------------------------------------------
// Controlla la presenza di posizioni a mercato restituendo true se ne trova almeno una e restituendo false se non ne trova nessuna.
// La scansione delle posizioni viene effettuata in base al tipo ordine e al magicnumber quindi è specifica per l'EA in esecuzione
// ESEMPIO :  bool result = fxActivePositions(ORDER_TYPE_SELL,MagicNumber); 
//-----------------------------------------------------------------------------
   bool fxActivePositions (int argType,int argMagicNumber ){
      int pos_total=PositionsTotal();
      for (int i = pos_total - 1; i >= 0; i-- ){
         ulong ticket=PositionGetTicket(i); //acquisisco il ticket della posizione in base all'indice
         if( ! PositionSelectByTicket(ticket)){ continue; } // seleziono la posizione in base al ticket
         if (PositionGetInteger(POSITION_TYPE)==argType && PositionGetInteger(POSITION_MAGIC)==argMagicNumber){
            return(true);
         }
      
      }
      return(false);
   }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------






//-----------------------------------------------------------------------------
// Controlla la presenza di ordini pendenti restituendo true se ne trova almeno uno e restituendo false se non ne trova nessuno.
// La scansione degli ordini pendenti viene effettuata in base al tipo ordine e al magicnumber quindi è specifica per l'EA in esecuzione
// ESEMPIO :  bool result = fxPendinOrders(ORDER_TYPE_BUY_STOP,MagicNumber); 
//-----------------------------------------------------------------------------
   bool fxPendinOrders (int argType,int argMagicNumber ){
      int ord_total=OrdersTotal();
      for (int i = ord_total - 1; i >= 0; i-- ){
         ulong ticket=OrderGetTicket(i); //acquisisco il ticket dell'ordine in base all'indice
         if( ! OrderSelect(ticket)){ continue; } // seleziono l'ordine in base al ticket
         if (OrderGetInteger(ORDER_TYPE)==argType && OrderGetInteger(ORDER_MAGIC)==argMagicNumber){
            return(true);
         }
      
      }
      return(false);
   }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------




//-----------------------------------------------------------------------------
// Effettual la chiusura di ordini pendenti restituendo true se ne chude almeno uno e restituendo false se non ne chude nessuno.
// La scansione degli ordini pendenti viene effettuata in base al tipo ordine e al magicnumber quindi è specifica per l'EA in esecuzione
// ESEMPIO :  bool result = fxPendingDelete(ORDER_TYPE_BUY_STOP,MagicNumber); 
//-----------------------------------------------------------------------------
   bool fxPendingDelete (int argType,int argMagicNumber ){
      bool response=false;
      int ord_total=OrdersTotal();
      for (int i = ord_total - 1; i >= 0; i-- ){
         ulong ticket=OrderGetTicket(i); //acquisisco il ticket dell'ordine in base all'indice
         if( ! OrderSelect(ticket)){ continue; } // seleziono l'ordine in base al ticket
         if (OrderGetInteger(ORDER_TYPE)==argType && OrderGetInteger(ORDER_MAGIC)==argMagicNumber && OrderGetString(ORDER_SYMBOL)==Symbol()){
               MqlTradeRequest request;
               ZeroMemory(request);
               MqlTradeResult result;
               ZeroMemory(result);
               request.action = TRADE_ACTION_REMOVE;  // assegno il tipo di azione che verrà eseguita da OrderSend
               request.magic  = argMagicNumber;       // assegno il magic number
               request.order  = ticket;               // assegno il ticket
               bool res =OrderSend(request,result);   
               response=true;
         }
      }
      return(response);
   }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------





//-----------------------------------------------------------------------------
// Chiude le posizioni a mercato restituendo true se ne chiude almeno una e restituendo false se non ne chiude nessuno.
// La scansione delle posizioni viene effettuata in base al tipo  e al magicnumber quindi è specifica per l'EA in esecuzione
// ESEMPIO :  bool result = fxClosePosition(ORDER_TYPE_BUY,MagicNumber); 
//-----------------------------------------------------------------------------
   bool fxClosePosition(int argType,int argMagicNumber ){
      bool response=false;
      int pos_total=PositionsTotal();
      for (int i = pos_total - 1; i >= 0; i-- ){
         ulong ticket=PositionGetTicket(i); //acquisisco il ticket della posizione in base all'indice
         if( ! PositionSelectByTicket(ticket)){ continue; } // seleziono la posizione in base al ticket
         if (PositionGetInteger(POSITION_TYPE)==argType && PositionGetInteger(POSITION_MAGIC)==argMagicNumber && PositionGetString(POSITION_SYMBOL)== Symbol()){
               MqlTradeRequest request;
               ZeroMemory(request);
               MqlTradeResult result;
               ZeroMemory(result);

               if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
                  request.type =ORDER_TYPE_SELL;
                  request.price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
               }else{
                  request.type =ORDER_TYPE_BUY;
                  request.price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
               }
               
               //--- setting request
               request.action = TRADE_ACTION_DEAL;    // assegno il tipo di azione che verrà eseguita da OrderSend
               request.magic  = argMagicNumber;       // assegno il magic number
               request.position  = ticket;            // assegno il ticket della posizione
               request.symbol   =_Symbol;             // assegno il nome del mercato in cui verrà inviato l'ordine
               request.volume   =PositionGetDouble(POSITION_VOLUME); // assegno il volume dell'operazione in lotti
               request.type_filling=ORDER_FILLING_FOK;// assegno il tipo di esecuzione
               request.deviation=0;                   // assegno il massimo valore di deviazione in punti, rispetto al prezzo richiesto per l'ingresso a mercato
            
               bool res =OrderSend(request,result);
               if(result.retcode==10008 || result.retcode==10009) {
                  response=true;
               }else{
                  response=false;
               }

         }
      }
      return(response);
    }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------




//-----------------------------------------------------------------------------
// Chiude una o più posizioni a mercato in base al durata impostata in ore (solo se il numero di ore è maggiore di zero) 
// e al magicnumber e vengono eseguiti massimo 3 tentativi di chiusura
// ESEMPIO :   bool result= fxClosePositionByDuration(MagicNumber ,PERIOD_M5,36); // chiude l'ordine dopo un ora (36 ore);
//-----------------------------------------------------------------------------
bool fxClosePositionByDuration( int argMagicNumber, ENUM_TIMEFRAMES argTimeframe, int argHours){
   int retries= 3;
   bool response = false;
   if (argHours<=0 ) return(response);
   
    int pos_total=PositionsTotal();
    for (int i = pos_total - 1; i >= 0; i-- ){
       ulong ticket=PositionGetTicket(i); //acquisisco il ticket della posizione in base all'indice
       if( ! PositionSelectByTicket(ticket)){ continue; } // seleziono la posizione in base al ticket
       if (PositionGetInteger(POSITION_MAGIC)==argMagicNumber && PositionGetString(POSITION_SYMBOL)== Symbol()){
            MqlTradeRequest request;
            ZeroMemory(request);
            MqlTradeResult result;
            ZeroMemory(result);
            
            datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
            
            if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
               request.type =ORDER_TYPE_SELL;
               request.price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
            }else{
               request.type =ORDER_TYPE_BUY;
               request.price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
            }
               
            //--- setting request
            request.action = TRADE_ACTION_DEAL;    // assegno il tipo di azione che verrà eseguita da OrderSend
            request.magic  = argMagicNumber;       // assegno il magic number
            request.position  = ticket;            // assegno il ticket della posizione
            request.symbol   =_Symbol;             // assegno il nome del mercato in cui verrà inviato l'ordine
            request.volume   =PositionGetDouble(POSITION_VOLUME); // assegno il volume dell'operazione in lotti
            request.type_filling=ORDER_FILLING_FOK;// assegno il tipo di esecuzione
            request.deviation=0;                   // assegno il massimo valore di deviazione in punti, rispetto al prezzo richiesto per l'ingresso a mercato           
            
            if (iTime(Symbol(),argTimeframe,0) > openTime+ (argHours*3600)){
               for (int n=0; n < retries; n++)   {
                  bool res =OrderSend(request,result);
                  if(result.retcode==10008 || result.retcode==10009) {
                     response=true;
                     break;
                  }else{
                     response=false;
                  }
               }
            }
      } 
   }// exit for
   return(response);
}
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
   



//-----------------------------------------------------------------------------
// Questa funzione può essere usata per disabilitare il trading in uno o più giorni della settimana 
// ESEMPIO :  bool result =  fxIsTradingDay(true,false,true,true,true,false);
// l'esempio restituirà false durante il lunedi e il venerdi e potrà essere usato per disabilitare il trading in quei giorni
//-----------------------------------------------------------------------------
bool fxIsTradingDay(bool Sun=true, bool Mon=true, bool Tue=true, bool Wed=true, bool Thu=true, bool Fri=true){      
      MqlDateTime tm; // dichiaro tm come oggetto con la struttura MqlDateTime
      TimeCurrent(tm);// assegno la data e ora corrente alla struttura tm 
      bool result = false;
      if(tm.day_of_week == 0 && Sun==true) {result = true;}
      if(tm.day_of_week == 1 && Mon==true) {result = true;}
      if(tm.day_of_week == 2 && Tue==true) {result = true;}
      if(tm.day_of_week == 3 && Wed==true) {result = true;}
      if(tm.day_of_week == 4 && Thu==true) {result = true;}
      if(tm.day_of_week == 5 && Fri==true) {result = true;}
      return(result);
   }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------





//-----------------------------------------------------------------------------
// Funzione per disegnare un simbolo sul grafico
// ESEMPIO DI UTILIZZO: 
// int ObjectID=0;
// ObjectID=ObjectID+1;
// DrawSymbol(IntegerToString(ObjectID) ,CharToStr(159), Time[1], High[1], Green, "Wingdings", 14);
//-----------------------------------------------------------------------------
void DrawSymbol(string obj_name,string objSymbol, datetime obj_time, double obj_val, color obj_col,string obj_font, int obj_font_dim){
   ObjectCreate(ChartID(),obj_name, OBJ_TEXT, 0, obj_time, obj_val); 
   //--- set the text
   ObjectSetString(ChartID(),obj_name,OBJPROP_TEXT,objSymbol);
   //--- set text font
   ObjectSetString(ChartID(),obj_name,OBJPROP_FONT,obj_font);
   //--- set font size
   ObjectSetInteger(ChartID(),obj_name,OBJPROP_FONTSIZE,obj_font_dim);
   //--- set color
   ObjectSetInteger(ChartID(),obj_name,OBJPROP_COLOR,obj_col);

}
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------




