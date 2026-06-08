//+------------------------------------------------------------------+
//|                                                   volatility.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#ifndef __VOL_MQH__
#define __VOL_MQH__

//+------------------------------------------------------------------+
//| Aggregation Methods                                              |
//+------------------------------------------------------------------+
enum Agg
  {
   AGG_MEAN = 0,   // Mean absolute log return
   AGG_MED  = 1,   // Median absolute log return
   AGG_RMS  = 2    // Root mean square log return
  };

//+------------------------------------------------------------------+
//| Source Types                                                     |
//+------------------------------------------------------------------+
enum Src
  {
   SRC_CC = 0,     // Close-to-Close
   SRC_HL = 1      // High-to-Low
  };

//+------------------------------------------------------------------+
//| Resolve Symbol                                                   |
//+------------------------------------------------------------------+
string ResolveSymbol(const string sym = "")
  {
   if(sym == NULL || sym == "")
      return _Symbol;

   return sym;
  }

//+------------------------------------------------------------------+
//| Resolve Timeframe                                                |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES ResolveTimeframe(const ENUM_TIMEFRAMES tf = PERIOD_CURRENT)
  {
   return tf;
  }

//+------------------------------------------------------------------+
//| Sort Array                                                       |
//+------------------------------------------------------------------+
void SortArr(double &a[])
  {
   int n = ArraySize(a);

   for(int i = 0; i < n - 1; i++)
     {
      for(int j = i + 1; j < n; j++)
        {
         if(a[j] < a[i])
           {
            double t = a[i];
            a[i] = a[j];
            a[j] = t;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Mean                                                             |
//+------------------------------------------------------------------+
double Mean(double &a[])
  {
   int n = ArraySize(a);

   if(n <= 0)
      return 0.0;

   double s = 0.0;

   for(int i = 0; i < n; i++)
      s += a[i];

   return s / n;
  }

//+------------------------------------------------------------------+
//| Median                                                           |
//+------------------------------------------------------------------+
double Med(double &a[])
  {
   int n = ArraySize(a);

   if(n <= 0)
      return 0.0;

   double b[];
   ArrayResize(b, n);

   for(int i = 0; i < n; i++)
      b[i] = a[i];

   SortArr(b);

   if((n % 2) == 1)
      return b[n / 2];

   return (b[n / 2 - 1] + b[n / 2]) / 2.0;
  }

//+------------------------------------------------------------------+
//| RMS                                                              |
//+------------------------------------------------------------------+
double RMS(double &a[])
  {
   int n = ArraySize(a);

   if(n <= 0)
      return 0.0;

   double s = 0.0;

   for(int i = 0; i < n; i++)
      s += a[i] * a[i];

   return MathSqrt(s / n);
  }

//+------------------------------------------------------------------+
//| Aggregate                                                        |
//+------------------------------------------------------------------+
double Aggregate(double &a[], const Agg agg = AGG_MEAN)
  {
   if(agg == AGG_MED)
      return Med(a);

   if(agg == AGG_RMS)
      return RMS(a);

   return Mean(a);
  }

//+------------------------------------------------------------------+
//| 1) Core Function: Close-to-Close Log Return                       |
//|                                                                  |
//| Returns:                                                         |
//| abs(log(Close[sh] / Close[sh + 1]))                               |
//+------------------------------------------------------------------+
double LogCC(
   const int sh,
   const string sym = "",
   const ENUM_TIMEFRAMES tf = PERIOD_CURRENT
)
  {
   if(sh < 0)
      return 0.0;

   string s = ResolveSymbol(sym);
   ENUM_TIMEFRAMES t = ResolveTimeframe(tf);

   int bars = iBars(s, t);

// برای Close-to-Close باید کندل sh و sh+1 وجود داشته باشد
   if(bars <= 0 || sh + 1 >= bars)
      return 0.0;

   double c0 = iClose(s, t, sh);
   double c1 = iClose(s, t, sh + 1);

   if(c0 <= 0.0 || c1 <= 0.0)
      return 0.0;

   return MathAbs(MathLog(c0 / c1));
  }

//+------------------------------------------------------------------+
//| 2) Simple Volatility Function                                    |
//|                                                                  |
//| فقط period می‌گیرد و روی Close-to-Close کار می‌کند              |
//| shift پیش‌فرض = 1                                                |
//|                                                                  |
//| agg:                                                             |
//| AGG_MEAN => mean                                                 |
//| AGG_MED  => median                                               |
//| AGG_RMS  => root mean square                                     |
//+------------------------------------------------------------------+
double VolCC(
   const int period,
   const Agg agg = AGG_MEAN,
   const int sh = 1,
   const string sym = "",
   const ENUM_TIMEFRAMES tf = PERIOD_CURRENT
)
  {
   if(period <= 0 || sh < 0)
      return 0.0;

   string s = ResolveSymbol(sym);
   ENUM_TIMEFRAMES t = ResolveTimeframe(tf);

   int bars = iBars(s, t);

// چون LogCC برای آخرین عضو به i+1 نیاز دارد
   if(bars <= 0 || sh + period >= bars)
      return 0.0;

   double v[];
   ArrayResize(v, period);

   for(int i = 0; i < period; i++)
     {
      int idx = sh + i;
      v[i] = LogCC(idx, s, t);
     }

   return Aggregate(v, agg);
  }

//+------------------------------------------------------------------+
//| 3-A) Core Function: High-to-Low Log Range                         |
//|                                                                  |
//| Returns:                                                         |
//| abs(log(High[sh] / Low[sh]))                                      |
//+------------------------------------------------------------------+
double LogHL(
   const int sh,
   const string sym = "",
   const ENUM_TIMEFRAMES tf = PERIOD_CURRENT
)
  {
   if(sh < 0)
      return 0.0;

   string s = ResolveSymbol(sym);
   ENUM_TIMEFRAMES t = ResolveTimeframe(tf);

   int bars = iBars(s, t);

   if(bars <= 0 || sh >= bars)
      return 0.0;

   double h = iHigh(s, t, sh);
   double l = iLow(s, t, sh);

   if(h <= 0.0 || l <= 0.0)
      return 0.0;

   return MathAbs(MathLog(h / l));
  }

//+------------------------------------------------------------------+
//| 3-B) Source-Based Single Log Move                                |
//|                                                                  |
//| src = SRC_CC => Close-to-Close                                    |
//| src = SRC_HL => High-to-Low                                       |
//+------------------------------------------------------------------+
double LogMove(
   const int sh,
   const Src src = SRC_CC,
   const string sym = "",
   const ENUM_TIMEFRAMES tf = PERIOD_CURRENT
)
  {
   if(src == SRC_HL)
      return LogHL(sh, sym, tf);

   return LogCC(sh, sym, tf);
  }

//+------------------------------------------------------------------+
//| 3-C) Full Volatility Function                                    |
//|                                                                  |
//| این همان تابع عمومی‌تر است                                       |
//| source، period، shift، method، symbol، timeframe دارد            |
//+------------------------------------------------------------------+
double Vol(
   const int period,
   const int sh = 1,
   const Agg agg = AGG_MEAN,
   const Src src = SRC_CC,
   const string sym = "",
   const ENUM_TIMEFRAMES tf = PERIOD_CURRENT
)
  {
   if(period <= 0 || sh < 0)
      return 0.0;

   string s = ResolveSymbol(sym);
   ENUM_TIMEFRAMES t = ResolveTimeframe(tf);

   int bars = iBars(s, t);

   if(bars <= 0)
      return 0.0;

   if(src == SRC_CC)
     {
      // Close-to-Close برای آخرین مقدار به i+1 نیاز دارد
      if(sh + period >= bars)
         return 0.0;
     }
   else
     {
      // High-to-Low فقط خود کندل را لازم دارد
      if(sh + period - 1 >= bars)
         return 0.0;
     }

   double v[];
   ArrayResize(v, period);

   for(int i = 0; i < period; i++)
     {
      int idx = sh + i;
      v[i] = LogMove(idx, src, s, t);
     }

   return Aggregate(v, agg);
  }
enum VolRatioMode
  {
   VOL_RATIO_ABOVE = 0,
   VOL_RATIO_BELOW = 1
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool volState(
   const string sym,
   const ENUM_TIMEFRAMES tf,
   const int recentBars = 5,
   const int shortPeriod = 20,
   const int longPeriod = 200,
   const double threshold = 1.0,
   const VolRatioMode mode = VOL_RATIO_ABOVE,
   const Agg agg = AGG_MED,
   const Src src = SRC_CC,
   int sh = 1
)
  {
   if(recentBars <= 0 || shortPeriod <= 0 || longPeriod <= 0)
      return false;

   for(sh; sh <= recentBars; sh++)
     {
      double fast = Vol(shortPeriod, sh, agg, src, sym, tf);
      double slow = Vol(longPeriod,  sh, agg, src, sym, tf);

      if(slow <= 0.0)
         return false;

      double ratio = fast / slow;

      if(mode == VOL_RATIO_ABOVE)
        {
         if(ratio <= threshold)
            return false;
        }
      else
         if(mode == VOL_RATIO_BELOW)
           {
            if(ratio >= threshold)
               return false;
           }
         else
           {
            return false;
           }
     }

   return true;
  }
//+------------------------------------------------------------------+
//| Weak Range Result                                                |
//+------------------------------------------------------------------+
struct WeakRangeResult
  {
   bool   found;
   int    startShift;   // شروع محدوده ضعف
   int    endShift;     // پایان محدوده ضعف
   double highestHigh;
   double lowestLow;
  };

//+------------------------------------------------------------------+
//| Check consecutive volState                                       |
//+------------------------------------------------------------------+
bool volStateRun(
   const string sym,
   const ENUM_TIMEFRAMES tf,
   const int runBars,
   const int shortPeriod = 20,
   const int longPeriod = 200,
   const double threshold = 1.0,
   const VolRatioMode mode = VOL_RATIO_ABOVE,
   const Agg agg = AGG_MED,
   const Src src = SRC_CC,
   const int startShift = 1
)
  {
   if(runBars <= 0)
      return false;

   for(int i = 0; i < runBars; i++)
     {
      int sh = startShift + i;

      double fast = Vol(shortPeriod, sh, agg, src, sym, tf);
      double slow = Vol(longPeriod,  sh, agg, src, sym, tf);

      if(slow <= 0.0)
         return false;

      double ratio = fast / slow;

      if(mode == VOL_RATIO_ABOVE)
        {
         if(ratio <= threshold)
            return false;
        }
      else if(mode == VOL_RATIO_BELOW)
        {
         if(ratio >= threshold)
            return false;
        }
      else
         return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Find weakness range                                              |
//| ضعف از جایی شروع می‌شود که weakRun پشت‌سرهم BELOW باشد          |
//| و تا جایی ادامه دارد که strongRun پشت‌سرهم ABOVE دیده نشده      |
//+------------------------------------------------------------------+
WeakRangeResult FindWeakRange(
   const string sym,
   const ENUM_TIMEFRAMES tf,
   const int weakRun = 5,
   const int strongRun = 5,
   const int shortPeriod = 20,
   const int longPeriod = 200,
   const double threshold = 1.0,
   const Agg agg = AGG_MED,
   const Src src = SRC_CC,
   const int searchStartShift = 1,
   const int maxSearchShift = 500
)
  {
   WeakRangeResult res;
   res.found       = false;
   res.startShift  = -1;
   res.endShift    = -1;
   res.highestHigh = 0.0;
   res.lowestLow   = 0.0;

   string s = ResolveSymbol(sym);
   ENUM_TIMEFRAMES t = ResolveTimeframe(tf);

   int bars = iBars(s, t);
   if(bars <= 0)
      return res;

   int searchLimit = MathMin(maxSearchShift, bars - 1);
   if(searchStartShift > searchLimit)
      return res;

   // 1) پیدا کردن شروع محدوده ضعف
   int weakStart = -1;
   for(int sh = searchStartShift; sh <= searchLimit; sh++)
     {
      if(volStateRun(s, t, weakRun, shortPeriod, longPeriod, threshold,
                     VOL_RATIO_BELOW, agg, src, sh))
        {
         weakStart = sh;
         break;
        }
     }

   if(weakStart < 0)
      return res;

   // 2) از اینجا به بعد تا قبل از strongRun پشت‌سرهم قدرت، محدوده ادامه دارد
   int weakEnd = searchLimit;

   for(int sh = weakStart; sh <= searchLimit; sh++)
     {
      if(volStateRun(s, t, strongRun, shortPeriod, longPeriod, threshold,
                     VOL_RATIO_ABOVE, agg, src, sh))
        {
         // محدوده ضعف تا کندل قبل از شروع قدرت است
         weakEnd = sh - 1;
         break;
        }
     }

   if(weakEnd < weakStart)
      weakEnd = weakStart;

   // 3) استخراج Highest High و Lowest Low در بازه
   double hh = -DBL_MAX;
   double ll =  DBL_MAX;

   for(int sh = weakStart; sh <= weakEnd; sh++)
     {
      double h = iHigh(s, t, sh);
      double l = iLow(s, t, sh);

      if(h > hh)
         hh = h;

      if(l < ll)
         ll = l;
     }

   if(hh == -DBL_MAX || ll == DBL_MAX)
      return res;

   res.found       = true;
   res.startShift  = weakStart;
   res.endShift    = weakEnd;
   res.highestHigh = hh;
   res.lowestLow   = ll;

   return res;
  }

#endif
//+------------------------------------------------------------------+
