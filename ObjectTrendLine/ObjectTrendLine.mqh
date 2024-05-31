//+------------------------------------------------------------------+
//|                                            Diamond Systems Corp. |
//|                                        https://algotrading.today |
//+------------------------------------------------------------------+

#define RIGHT_OFFSET_IN_BARS 10

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   ObjectsDeleteAll(ChartID(), "TrendLineExample");
   ObjectsDeleteAll(ChartID(), "ArrowExample_");

   Print("========== START ===========");

   // Get coordinates
   double price1;  // Coordinate 1
   double price2;  // Coordinate 2
   int    barStart;
   int    barEnd;

   GetCoordinates(price1, price2, barStart, barEnd);

   datetime time1 = iTime(_Symbol, PERIOD_CURRENT, barStart);
   datetime time2 = iTime(_Symbol, PERIOD_CURRENT, barEnd);

   Print(StringFormat("Coordinate 1: Price=%.5f; Time=%s", price1, TimeToString(time1)));
   Print(StringFormat("Coordinate 2: Price=%.5f; Time=%s", price2, TimeToString(time2)));

   // Calculate
   int x = barStart - barEnd;
   double y = NormalizeDouble(MathAbs(price1 - price2), _Digits);
   double step = y / x;

   Print(StringFormat("Distance X: %d Bars", x));
   Print(StringFormat("Distance Y: %d Points", (int)MathRound(y / _Point)));
   Print(StringFormat("Step: %.5f Pips", step));

   // Drawing objects
   CreateTrendLine(time1, price1, time2, price2);
   for (int ibar = barEnd-1, i = x+1; ibar > 0; ibar--, i++)
      CreateArrowPoint(iTime(_Symbol, PERIOD_CURRENT, ibar), NormalizeDouble(price1 + (step * i), _Digits));
   
   Print("========== END ===========");
}

//+------------------------------------------------------------------+
//| Get coordinates for TrendLine                                    |
//+------------------------------------------------------------------+
void GetCoordinates(double &price1, double &price2, int &barStart, int &barEnd)
{
   // Get coordinates from Fractals
   int handle = iFractals(_Symbol, PERIOD_CURRENT);
   if (handle != INVALID_HANDLE)
   {
      double arrows[];
      int cnt;
      
      cnt = CopyBuffer(handle, 0, RIGHT_OFFSET_IN_BARS, 40, arrows);
      if (cnt >= 0)
      {
         double val = 0.0;
         for (int i = cnt-1; i >= 0; i--)
         {
            if (arrows[i] == EMPTY_VALUE)
               continue;
            
            if (val == 0.0 || val <= arrows[i])
            {
               barEnd = RIGHT_OFFSET_IN_BARS + cnt - i - 1;
               val = arrows[i];
            }
            else
            {
               barStart = RIGHT_OFFSET_IN_BARS + cnt - i - 1;
               price1 = arrows[i];
               price2 = val;

               return;
            }
         }
      }
      
      ArrayFree(arrows);
      cnt = CopyBuffer(handle, 1, RIGHT_OFFSET_IN_BARS, 40, arrows);
      if (cnt >= 0)
      {
         double val = 0.0;
         for (int i = cnt-1; i >= 0; i--)
         {
            if (arrows[i] == EMPTY_VALUE)
               continue;
            
            if (val == 0.0 || val >= arrows[i])
            {
               barEnd = RIGHT_OFFSET_IN_BARS + cnt - i - 1;
               val = arrows[i];
            }
            else
            {
               barStart = RIGHT_OFFSET_IN_BARS + cnt - i - 1;
               price1 = arrows[i];
               price2 = val;

               return;
            }
         }
      }
   }

   // Custom coordinates
   barStart = 35;
   barEnd = RIGHT_OFFSET_IN_BARS;
   price1 = NormalizeDouble(iHigh(_Symbol, PERIOD_CURRENT, barStart), _Digits);
   price2 = NormalizeDouble(price1 + (300 * _Point), _Digits);
}

//+------------------------------------------------------------------+
//| Create TrendLine object                                          |
//+------------------------------------------------------------------+
void CreateTrendLine(datetime time1, double price1, datetime time2, double price2)
{
   string objName = "TrendLineExample";
   if (! ObjectCreate(0, objName, OBJ_TREND, 0, time1, price1, time2, price2))
      return;
   
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, objName, OBJPROP_SELECTED, true);
   ObjectSetInteger(0, objName, OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(0, objName, OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN, false);
}

//+------------------------------------------------------------------+
//| Create Arrow-Point object                                        |
//+------------------------------------------------------------------+
void CreateArrowPoint(datetime time, double price)
{
   string objName = "ArrowExample_" + TimeToString(time);
   if (! ObjectCreate(0, objName, OBJ_ARROW, 0, time, price))
      return;
   
   ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, 108);
   ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrYellow);
   ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, objName, OBJPROP_SELECTED, true);
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN, false);
}

//+------------------------------------------------------------------+
