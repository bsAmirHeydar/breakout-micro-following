//+------------------------------------------------------------------+
//|                                                         time.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
bool is1 = true;
int aHour1 = 0;
int aMinute1 = 30;
int bHour1 = 21;
int bMinute1 = 0;
bool isClose = true;
int cHour = 22;
int cMinute = 30;
bool time()
  {
   datetime now = TimeCurrent();
   MqlDateTime t;
   TimeToStruct(now, t);
   if(is1 &&
      !(
         (t.hour > aHour1 || (t.hour == aHour1 && t.min >= aMinute1)) &&
         (t.hour < bHour1 || (t.hour == bHour1 && t.min <= bMinute1))
      ))
      return false;
   return true;
  }
//+------------------------------------------------------------------+
bool closeTiming()
  {
   datetime now = TimeCurrent();
   MqlDateTime t;
   TimeToStruct(now, t);
   if(isClose &&         t.day_of_week == 5 &&
      (
         (t.hour > cHour || (t.hour == cHour && t.min >= cMinute))
      ))
      return true;
   return false;
  }
//+------------------------------------------------------------------+
