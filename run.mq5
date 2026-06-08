//+------------------------------------------------------------------+
//|                                                          run.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "time.mqh"
#include "strategy setting.mqh"
#include "order.mqh"
#include "portfolio.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
strategy edge[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   initialSymbol();
   for(int i = 0;i < ArraySize(universe);i++)
     {
      ArrayResize(edge, ArraySize(edge) + 1);
      edge[i].initial(universe[i].id);
     }
//---
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ArrayResize(edge, 0);
   ArrayResize(universe, 0);
   printf("Commission : " + DoubleToString(all_commission));
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {     

   string commentDisplay = "";
   for(int i = 0;i < ArraySize(universe);i++)
     {
      if(closeTiming())
        {
         closeAll(universe[i].name, 1);
         closeAll(universe[i].name,-1);
        }
      if(time())
         edge[i].run();
      commentDisplay += tradeComment(universe[i].name, universe[i].tf) +" :" + DoubleToString(iClose(universe[i].name, universe[i].tf,0)) + "\n";
     }
   Comment(commentDisplay);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int32_t id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
  }
//+------------------------------------------------------------------+
