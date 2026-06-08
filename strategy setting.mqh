//+------------------------------------------------------------------+
//|                                             strategy setting.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

#include "draw.mqh"
#include "order.mqh"
#include "volatility.mqh"

input double atrFactor = 2.0;
int riskCount = 0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class strategy
  {
public:
   int               symID;
   string            orderType;
   double            entry;
   double            sl;
   double            tp;
   double            volFactor;
   double            buySL;
   double            sellSL;
   double            buyEntry;
   double            sellEntry;
   int               buyIndex;
   int               sellIndex;
   double            buyStopValue;
   double            sellStopValue;
   bool              firstBuyBE;
   bool              firstSellBE;

   void              initial(int _symID)
     {
      symID = _symID;
     }
   void              run(bool _justTrail = false)
     {
      string sym = universe[symID].name;
      ENUM_TIMEFRAMES entryTF = PERIOD_CURRENT;
      universe[symID].tf = entryTF;
      double spread = SymbolInfoDouble(sym, SYMBOL_ASK) - SymbolInfoDouble(sym, SYMBOL_BID);
      double highest = iHigh(sym, entryTF, iHighest(sym, entryTF, MODE_HIGH, 10, 0));
      double lowest = iLow(sym, entryTF, iLowest(sym, entryTF, MODE_LOW, 10, 0));
      double price = iClose(sym, entryTF, 0);
      double atrArray[];
      int atrIndex = iATR(sym, entryTF, 14);
      CopyBuffer(atrIndex,0,0,1,atrArray);
      double atr = atrArray[0];
      if(countOrders(sym, 1) == 0)
         reset(1);
      if(countOrders(sym, -1) == 0)
         reset(-1);
      if(price >= highest)
        {
         if(buyEntry != 0.0)
           {
            if(!firstBuyBE)
              {
               if(price >= buyEntry + buyStopValue * 0.2)
                 {
                 
                  trailAll(sym, 1, price - buyStopValue * 0.1);
                 }
              }
            else
               trailAll(sym, 1, price - buyStopValue * 0.1);
           }
         if(buyEntry == 0.0)
           {
            orderType = "market";
            entry = SymbolInfoDouble(sym, SYMBOL_ASK);
            buyEntry = entry;
            sl = entry - 2 * atr;
            buyStopValue = entry - sl;
            tp = entry + (entry -sl) * 10;
            buy(symID, orderType, entry, sl, tp, 1, entryTF);
           }
        }
      else
         if(price <= lowest)
           {
            if(sellEntry != 0.0)
              {
               if(!firstSellBE)
                 {
                  if(price <= sellEntry + sellStopValue * 0.2)
                    {
                     trailAll(sym, -1, price + sellStopValue * 0.1);
                    }
                 }
               else
                  trailAll(sym, -1, price + sellStopValue * 0.1);
              }
            if(sellEntry == 0.0)
              {
               orderType = "market";
               entry = SymbolInfoDouble(sym, SYMBOL_BID);
               sellEntry = entry;
               sl = entry + 2 * atr + spread;
               sellStopValue = sl - entry;
               tp = entry - (sl - entry) * 10;
               sell(symID, orderType, entry, sl, tp, 1, entryTF);
              }
           }
     }
   void              reset(int _type)
     {
      if(_type == 1)
        {
         buyIndex = 0;
         buyEntry = 0.0;
         buySL = 0.0;
         buyStopValue = 0.0;
         firstBuyBE = false;
        }
      else
         if(_type == -1)
           {
            sellIndex = 0;
            sellEntry = 0.0;
            sellSL = 0.0;
            sellStopValue = 0.0;
            firstSellBE = false;
           }
     }
                     strategy()
     {
      orderType = "market";
     }
                    ~strategy(void) {}
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
