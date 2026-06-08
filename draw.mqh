//+------------------------------------------------------------------+
//|                                                         draw.mqh |
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
class draw
  {
public:
   double            dEntry;
   double            dSl;
   color             cEntry;
   string            shape;
   void              drawPoint(datetime time, double price, color c)
     {
      string a = "draw " + TimeToString(time) + DoubleToString(price);
      ObjectCreate(0,a,OBJ_TREND,0,time, price);
      ObjectSetInteger(0,a,OBJPROP_COLOR,c);
      ObjectSetInteger(0,a,OBJPROP_WIDTH,10);
     }
   void              drawEntry(double _priceEntry, double _priceSl, color _cEntry = clrGreen)
     {
      dEntry = _priceEntry;
      dSl = _priceSl;
      cEntry = _cEntry;
      datetime t0 = TimeCurrent();
      datetime t1 = t0 + 5 * PeriodSeconds();
      shape = "drawEntry " + TimeToString(t0) + DoubleToString(_priceEntry);
      // ساخت مستطیل
      ObjectCreate(0,shape,OBJ_RECTANGLE,0,t0,_priceEntry,t1,_priceSl);
      // تنظیم ظاهر
      ObjectSetInteger(0,shape,OBJPROP_COLOR,_cEntry);
      ObjectSetInteger(0,shape,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,shape,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,shape,OBJPROP_BACK,true);
      ObjectSetInteger(0,shape,OBJPROP_FILL,true);
     }
   void              updateEntry(double _priceEntry = 0, double _priceSl = 0, color _cEntry = 0) //delete last shape and draw again
     {
      if(_priceEntry == 0)
         _priceEntry = dEntry;
      if(_priceSl == 0)
         _priceSl = dSl;
      if(_cEntry == 0)
         _cEntry = cEntry;
      ObjectDelete(0, shape);
      drawEntry(_priceEntry, _priceSl, _cEntry);
     }
                     draw(void) {}
                    ~draw(void) {}
  };

//+------------------------------------------------------------------+
