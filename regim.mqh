//+------------------------------------------------------------------+
//|                                                        regim.mqh |
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
#include "clear trend.mqh"

input ENUM_TIMEFRAMES regimTf = PERIOD_H1; //Regim Timeframe
input bool regimTrendFilter = true;
input bool regimClearFilter = true;
bool regimTrend(string sym, int dir)
  {
   if(!regimTrendFilter)
      return true;
   double highest = iHigh(sym, regimTf, iHighest(sym, regimTf, MODE_HIGH, 20, 1));
   double lowest = iLow(sym, regimTf, iLowest(sym, regimTf, MODE_LOW, 20, 1));
   double price = iClose(sym, regimTf, 0);
   if(dir == 1 && price > highest)
      return true;
   else
      if(dir == -1 && price < lowest)
         return true;
      else
         return false;
  }
//+------------------------------------------------------------------+
bool regimClearity(string sym)
  {
   if(!regimClearFilter)
      return true;
   if(isClear(sym, regimTf))
      return true;
   return false;
  }
//+------------------------------------------------------------------+
bool regimCheck(string sym, int dir)
  {
   return regimTrend(sym, dir) && regimClearity(sym);
  }
//+------------------------------------------------------------------+
