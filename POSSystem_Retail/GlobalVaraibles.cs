using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace POSSystem_Retail
{
    class GlobalVaraibles
    {
        public static int _TerminalId = 0;
        public static int _ItemId = 0;
        public static Decimal _ItemSearch_Price = 0;
        public static bool ItemButons_Canceled = true;
        public static bool VoidLine_Canceled = true;
        public static bool MessageDecision = false;
    }
}
