//+------------------------------------------------------------------+
//|                                                        order.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include "portfolio.mqh"

input double risk = 0.01; //Risk per order
int MagicNumber = 0; //Magic number
//input double commissionPerLot = 3.0; //Commission per lot
int maxOrder = 1; //Max order
bool isTrail = true; //Trail?
int slippage = 2; //Slippage

double all_commission = 0.0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculatePointValue(int _symID)
  {
   string symbol = universe[_symID].name;
   int pointScale = universe[_symID].point_scale;
   double tickValue;
   double tickSize;
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(!SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE, tickValue))
      return -1; // خطا در دریافت مقدار تیک ولیو
   if(!SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE, tickSize))
      return -1; // خطا در دریافت اندازه تیک
   double pointValue = tickValue * (point / tickSize);
   return pointValue * pointScale;
  }
double sum_commission;
double volume(int _symID, double sl_value, double _factor)
  {
   string sym = universe[_symID].name;
   double commissionFactor = universe[_symID].commission;
   double risk_order = risk * _factor * universe[_symID].vol_factor * AccountInfoDouble(ACCOUNT_BALANCE);
   double pointValue = CalculatePointValue(_symID);  // محاسبه Pip Value
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);
   double sl_point = sl_value / point;
   if(sl_point * pointValue == 0)
      return 0;
   double start_lot_size = NormalizeDouble(risk_order / (sl_point * pointValue), 2);
   double commission = start_lot_size * commissionFactor;
   while(true)
     {
      // محاسبه ضرر احتمالی (با توجه به استاپ‌لاس) برای حجم فعلی
      double potentialLoss = start_lot_size * sl_point * pointValue;
      // بررسی اینکه مجموع ضرر احتمالی و کمیسیون از ریسک کل بیشتر نشود
      if(potentialLoss + commission <= risk_order)
        {
         break;  // حجم نهایی محاسبه شد
        }
      start_lot_size -= 0.01;
      commission = start_lot_size * commissionFactor;
     }
   all_commission += commission;
   return start_lot_size;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool buy(int _symID, string orderType,double _entry,double _sl,double _tp, double _volFactor, ENUM_TIMEFRAMES _tf)
  {
   string sym = universe[_symID].name;
   if(countOrders(sym, 1) >= maxOrder || countOrders(sym, -1) >= maxOrder )
      return false;
// double spread = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID);
   MqlTradeRequest req;
   MqlTradeResult  res;
   ZeroMemory(req);
   ZeroMemory(res);
   req.symbol       = sym;
   req.volume       = volume(_symID, fabs(_entry - _sl), _volFactor);
   req.sl           = _sl;
   req.tp           = _tp;
   req.deviation    = 10;
   req.type_filling = ORDER_FILLING_IOC;
   req.comment = tradeComment(sym, _tf);
   if(orderType == "market")
     {
      req.action = TRADE_ACTION_DEAL;
      req.type   = ORDER_TYPE_BUY;
      req.price  = SymbolInfoDouble(sym, SYMBOL_ASK);
     }
   else
      if(orderType == "limit")
        {
         req.action = TRADE_ACTION_PENDING;
         req.type   = ORDER_TYPE_BUY_LIMIT;
         req.price  = _entry;
        }
      else
         if(orderType == "stop")
           {
            req.action = TRADE_ACTION_PENDING;
            req.type   = ORDER_TYPE_BUY_STOP;
            req.price  = _entry;
           }
         else
           {
            Print("نوع سفارش نامعتبر: ",orderType);
            return false;
           }
   bool ok = OrderSend(req,res);
   Print(sym," BUY ",orderType," ok=",ok," retcode=",res.retcode," lastErr=",GetLastError());
   return ok;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool sell(int _symID, string orderType,double _entry,double _sl,double _tp, double _volFactor, ENUM_TIMEFRAMES _tf)
  {
   string sym = universe[_symID].name;
   if(countOrders(sym, -1) >= maxOrder || countOrders(sym, 1) >= maxOrder)
      return false;
// double spread = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID);
   MqlTradeRequest req;
   MqlTradeResult  res;
   ZeroMemory(req);
   ZeroMemory(res);
   req.symbol       = sym;
   req.volume       = volume(_symID, fabs(_entry - _sl), _volFactor);
   req.sl           = _sl;
   req.tp           = _tp;
   req.deviation    = 10;
   req.type_filling = ORDER_FILLING_IOC;
   req.comment = tradeComment(sym, _tf);
   if(orderType == "market")
     {
      req.action = TRADE_ACTION_DEAL;
      req.type   = ORDER_TYPE_SELL;
      req.price  = SymbolInfoDouble(sym, SYMBOL_BID);
     }
   else
      if(orderType == "limit")
        {
         req.action = TRADE_ACTION_PENDING;
         req.type   = ORDER_TYPE_SELL_LIMIT;
         req.price  = _entry;
        }
      else
         if(orderType == "stop")
           {
            req.action = TRADE_ACTION_PENDING;
            req.type   = ORDER_TYPE_SELL_STOP;
            req.price  = _entry;
           }
         else
           {
            Print("نوع سفارش نامعتبر: ",orderType);
            return false;
           }
   bool ok = OrderSend(req,res);
   Print(sym," SELL ",orderType," ok=",ok," retcode=",res.retcode," lastErr=",GetLastError());
   return ok;
  }

//+------------------------------------------------------------------+
int countOrders(string sym, int Dir)
  {
   int cnt = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         string psym = PositionGetString(POSITION_SYMBOL);
         if(psym != sym)
            continue;
         long type = PositionGetInteger(POSITION_TYPE);
         if(Dir == 1 && type == POSITION_TYPE_BUY)
            cnt++;
         else
            if(Dir == -1 && type == POSITION_TYPE_SELL)
               cnt++;
        }
     }
   return cnt;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SendClose(string _sym, MqlTradeRequest &r, MqlTradeResult &s)
  {
   r.symbol = _sym;
   ENUM_ORDER_TYPE_FILLING fillings[3] =
     {
      ORDER_FILLING_IOC,
      ORDER_FILLING_FOK,
      ORDER_FILLING_RETURN
     };
   for(int i = 0; i < 3; i++)
     {
      r.type_filling = fillings[i];
      ZeroMemory(s);
      if(OrderSend(r, s))
        {
         if(s.retcode == TRADE_RETCODE_DONE)
            return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAll(string _sym, int _type)
  {
   MqlTradeRequest r;
   MqlTradeResult  s;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(!PositionSelectByTicket(t))
         continue;
      string symbol = PositionGetString(POSITION_SYMBOL);
      if(symbol != _sym)
         continue;
      long ptype = PositionGetInteger(POSITION_TYPE);
      if(((_type == 1 || _type == 10)  && ptype != POSITION_TYPE_BUY) ||
         ((_type == -1 || _type == 10) && ptype != POSITION_TYPE_SELL))
         continue;
      ZeroMemory(r);
      r.action    = TRADE_ACTION_DEAL;
      r.symbol    = symbol;
      r.volume    = PositionGetDouble(POSITION_VOLUME);
      r.position  = t;
      r.deviation = 20;
      if(ptype == POSITION_TYPE_BUY)
        {
         r.type  = ORDER_TYPE_SELL;
         r.price = SymbolInfoDouble(symbol, SYMBOL_BID);
        }
      else
        {
         r.type  = ORDER_TYPE_BUY;
         r.price = SymbolInfoDouble(symbol, SYMBOL_ASK);
        }
      if(!SendClose(symbol, r, s))
        {
         Print("Close failed. Retcode=", s.retcode,
               " Symbol=", symbol,
               " Ticket=", t);
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool trailAll(string _sym, int _type, double _newPrice)
{
   if(!isTrail)
      return false;

   bool ok = false;
   double newSL = NormalizeDouble(_newPrice,
                                  (int)SymbolInfoInteger(_sym, SYMBOL_DIGITS));

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(!PositionSelectByTicket(ticket))
         continue;

      if(PositionGetString(POSITION_SYMBOL) != _sym)
         continue;

      long ptype = PositionGetInteger(POSITION_TYPE);

      if((_type == 1  && ptype != POSITION_TYPE_BUY) ||
         (_type == -1 && ptype != POSITION_TYPE_SELL))
         continue;

      double currentSL = PositionGetDouble(POSITION_SL);

      // فقط تریل در جهت سود
      if(ptype == POSITION_TYPE_BUY)
      {
         if(currentSL > 0 && newSL <= currentSL)
            continue;
      }
      else if(ptype == POSITION_TYPE_SELL)
      {
         if(currentSL > 0 && newSL >= currentSL)
            continue;
      }

      MqlTradeRequest req;
      MqlTradeResult  res;
      ZeroMemory(req);
      ZeroMemory(res);

      req.action   = TRADE_ACTION_SLTP;
      req.symbol   = _sym;
      req.position = ticket;
      req.sl       = newSL;
      req.tp       = PositionGetDouble(POSITION_TP);

      if(OrderSend(req, res))
         ok = true;
   }

   return ok;
}
bool trailAllll(string _sym, int _type, double _newPrice)
  {
   if(!isTrail)
     {
      return false;
     }
   bool ok = false;
   double newSL = NormalizeDouble(_newPrice, (int)SymbolInfoInteger(_sym, SYMBOL_DIGITS));
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _sym)
         continue;
      long ptype = PositionGetInteger(POSITION_TYPE);
      if((_type == 1  && ptype != POSITION_TYPE_BUY) ||
         (_type == -1 && ptype != POSITION_TYPE_SELL))
         continue;
      MqlTradeRequest req;
      MqlTradeResult res;
      ZeroMemory(req);
      ZeroMemory(res);
      req.action   = TRADE_ACTION_SLTP;
      req.symbol   = _sym;
      req.position = ticket;
      req.sl       = newSL;                                  // trail SL to new price
      req.tp       = PositionGetDouble(POSITION_TP);         // keep current TP
      if(OrderSend(req,res))
         ok = true;
     }
   return ok;
  }
//+------------------------------------------------------------------+
string TfToString(ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1:
         return "M1";
      case PERIOD_M2:
         return "M2";
      case PERIOD_M3:
         return "M3";
      case PERIOD_M4:
         return "M4";
      case PERIOD_M5:
         return "M5";
      case PERIOD_M6:
         return "M6";
      case PERIOD_M10:
         return "M10";
      case PERIOD_M12:
         return "M12";
      case PERIOD_M15:
         return "M15";
      case PERIOD_M20:
         return "M20";
      case PERIOD_M30:
         return "M30";
      case PERIOD_H1:
         return "H1";
      case PERIOD_H2:
         return "H2";
      case PERIOD_H3:
         return "H3";
      case PERIOD_H4:
         return "H4";
      case PERIOD_H6:
         return "H6";
      case PERIOD_H8:
         return "H8";
      case PERIOD_H12:
         return "H12";
      case PERIOD_D1:
         return "D1";
      case PERIOD_W1:
         return "W1";
      case PERIOD_MN1:
         return "MN1";
     }
   return "TF_UNKNOWN";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string tradeComment(string sym, ENUM_TIMEFRAMES tf)
  {
   return sym + "_" + TfToString(tf);
  }
//+------------------------------------------------------------------+
