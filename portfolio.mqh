//+------------------------------------------------------------------+
//|                                                    portfolio.mqh |
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

struct symbol
  {
   int               id;
   string            name;
   int               point_scale;
   string            group;
   double            vol_factor;
   double            commission;
   ENUM_TIMEFRAMES   tf;
  };
//+------------------------------------------------------------------+
symbol universe[];
void addSymbol(string _name, int _point_scale, string _group, double _vol_factor, double _commission)
  {
   int x = ArraySize(universe);
   ArrayResize(universe, x + 1);
   universe[x].id = x;
   universe[x].name = _name;
   universe[x].point_scale = _point_scale;
   universe[x].group = _group;
   universe[x].vol_factor = _vol_factor;
   universe[x].commission = _commission;
  }
//+------------------------------------------------------------------+
void initialSymbol()
  {
   addSymbol("#US30", 1, "Indices-Amarica", 1, 0);
  // addSymbol("#USNDAQ100", 1, "Indices-Amarica", 1, 0);
 //  addSymbol("#USSPX500", 100, "Indices-Amarica", 1, 0);
//  addSymbol("#US2000", 100, "Indices-Amarica", 0.25);
 //  addSymbol("#UK100", 100, "Indices-Europe", 0.25, 0);
 //  addSymbol("#Euro50", 100, "Indices-Europe", 0.25,0);
//  addSymbol("#France40", 100, "Indices-Europe", 0.25);
  // addSymbol("#Germany40", 100, "Indices-Europe", 0.25,0);
// addSymbol("#Japan225", 100, "Indices-Asia", 0.5);
// addSymbol("#AUS200", 100, "Indices-Asia", 0.5);
 //  addSymbol("BRENT", 1, "Energy", 0.5,7);
   //addSymbol("WTI", 1, "Energy", 1, 7);
// addSymbol("NAT.GAS", 1, "Energy", 0.5);
   addSymbol("GOLD", 1, "Metals", 1, 7);
  // addSymbol("SILVER", 1, "Metals", 0.5,7);
//addSymbol("PALLADIUM", 1, "Metals", 0.5);
// addSymbol("PLATINUM", 1, "Metals", 0.5);
// addSymbol("ALIMINIUM", 1, "Metals", 0.5);
// addSymbol("COPPER", 1, "Metals", 0.5);
// addSymbol("LEAD", 1, "Metals", 0.5);
// addSymbol("ZINC", 1, "Metals", 0.5);
 //  addSymbol("BITCOIN", 100, "Crypto", 0.5, 7);
 //  addSymbol("ETHEREUM", 100, "Crypto", 0.5, 7);
// addSymbol("SOLONA", 1, "Crypto", 0.5);
// addSymbol("XRP", 1, "Crypto", 0.5);
  // addSymbol("EURUSD", 1, "Pair", 1, 7);
 //  addSymbol("USDJPY", 1, "Pair", 1, 7);
  }
//+------------------------------------------------------------------+
