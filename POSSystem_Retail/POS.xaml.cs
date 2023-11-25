using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Threading;
using System.Net;
using System.Net.Sockets;


namespace POSSystem_Retail
{
    /// <summary>
    /// Interaction logic for POS.xaml
    /// </summary>
    public partial class POS : Window
    {
        public POS(string _userid)
        {
            InitializeComponent();           

            UserId = _userid;

            GetTerminalInfo();
            DateTimer();            
            FillCompanyLogo();
            
            FillGrid_ItemOverVew_HeaderAndLines();                     

            tblCashier.Text = GetUserName(UserId);

            SelectedRow = ItemOverView_SelectedValues_MinId(); //1;
            grdItems.SelectedValue = SelectedRow;

            if(ResumeSuspendSale_Type().ToUpper() == "RESUME SALE")
            {
                tblSuspendResume.Text = "👈   RESUME"; //Old: 🔄
            }
            else
            {
                tblSuspendResume.Text = "✋ SUSPEND";
            }

            GetLastSaleChange();

        }

        /*  Class Variables */

        string UserId;
        int SelectedRow;
        Boolean BarcodeFocused = false;
        int TerminalId = 0;
        int MaxDocId = 0;        

        /*  Class Variables END */

        private int DocumentSelection_GetDocId()
        {
            int DocId = 0;
            
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;                
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_DocId_Selection", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UserId", UserId);
                    cmd.Parameters.AddWithValue("@TerminalId", TerminalId);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        DocId = Int32.Parse(reader["Id"].ToString());                       
                    }

                    con.Close();                  

                }
                
            }
            catch (Exception e)
            {

                ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                errorDialog.ShowDialog();
                //MessageBox.Show(e.Message, "Error");
            }

            return DocId;

        }

        private string GetUserName(string UserId)
        {
            string UserName = null;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcUserName", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UserId", UserId);

                    SqlDataReader reader = cmd.ExecuteReader();



                    while (reader.Read())
                    {
                        UserName = reader["UserName"].ToString();
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return UserName;
        }

        public static string GetLocalIPAddress()
        {
            var host = Dns.GetHostEntry(Dns.GetHostName());
            foreach (var ip in host.AddressList)
            {
                if (ip.AddressFamily == AddressFamily.InterNetwork)
                {
                    return ip.ToString();
                }
            }
            throw new Exception("No network adapters with an IPv4 address in the system!");
        }

        private void GetTerminalInfo()
        {
            
            string TerminalName = null;
            string TerminalIP = null;
            int PrinterId = 0;

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcGetTerminal", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@TerminalIP", GetLocalIPAddress());

                    SqlDataReader reader = cmd.ExecuteReader();


                    while (reader.Read())
                    {
                        TerminalId = Int32.Parse(reader["Id"].ToString());
                        TerminalName = reader["TerminalName"].ToString();
                        TerminalIP = reader["Terminal_IP"].ToString();
                        PrinterId = Int32.Parse(reader["PrinterId"].ToString());
                    }

                    con.Close();

                    tblTerminal.Text = TerminalName + " ("+ TerminalIP + ")";
                    GlobalVaraibles._TerminalId = TerminalId;

                }
            }
            catch (Exception e)
            {

                ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                errorDialog.ShowDialog();
                //MessageBox.Show(e.Message, "Error");

            }


        }

        private void GetLastSaleChange()
        {

            string Change = null;           

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcDoc_GetLastSaleChange", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UserId", UserId);
                    cmd.Parameters.AddWithValue("@TerminalId", TerminalId);

                    SqlDataReader reader = cmd.ExecuteReader();


                    while (reader.Read())
                    {
                        Change = reader["Change"].ToString();                        
                    }

                    con.Close();

                    if(Change != string.Empty)
                    {
                        tbl_Change.Text = "Last Sale Change: " + Change;
                    }
                    
                    

                }
            }
            catch (Exception e)
            {

                ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                errorDialog.ShowDialog();
                //MessageBox.Show(e.Message, "Error");

            }


        }

        private void FillCompanyLogo()
        {
            byte[] CompanyLogo = null;
            Boolean LogoIsNull = true;

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpCompanyInformation_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        if (reader["Logo"].ToString() != null && reader["Logo"].ToString() != string.Empty)
                        {
                            LogoIsNull = false;
                            CompanyLogo = Convert.FromBase64String(reader["Logo"].ToString());                           
                        }
                    }

                    con.Close();

                    //Assign Values                    

                    if (!LogoIsNull)
                    {
                        Image_CompanyLogo.Source = ByteImageConverter.ByteToImage(CompanyLogo);                        
                    }

                }
            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
        }

        private void FillGrid_ItemOverVew_HeaderAndLines()
        {
            
            int DocumentId = DocumentSelection_GetDocId();

            /*
            ===================================    
                        Header
            =================================== 
             */

            string DocDate = null;
            string DocNum = null;
            string DocTotal = null;            

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_Doc_TransactionHeader", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", DocumentId);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        DocDate = reader["Date"].ToString();
                        DocNum = reader["DocumentNumber"].ToString();
                        DocTotal = reader["DocumentTotal_Formatted"].ToString();
                    }

                    con.Close();

                    tblDocDate.Text = DocDate;
                    tblDocNumber.Text = DocNum;
                    tblDocumentTotal.Text = "TOTAL: " + DocTotal;
                    //tblDocTotal.Text = "TOTAL: " + DocTotal;
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            GetLastSaleChange();

            /*
            ===================================    
                        Lines
            =================================== 
             */
            try
            {               
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_Doc_TransactionLines", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", DocumentId);

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable("ItemOverView");
                    sda.Fill(dt);
                    grdItems.ItemsSource = dt.DefaultView;

                    con.Close();
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            tbx_Barcode.Focus();
        }

        private int ItemOverView_SelectedValues_MinId()
        {

            int Min_Id = 0;
            int Max_Id = 0;           

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcItemOverView_SelectedValues", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocId", DocumentSelection_GetDocId());

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Min_Id = Int32.Parse(reader["Id_Min"].ToString());
                        Max_Id = Int32.Parse(reader["Id_Max"].ToString());
                    }

                    con.Close();

                    MaxDocId = Max_Id;

                }

            }                

            
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return Min_Id;
        }

        private void POS_Document_AddLine()
        {

            Boolean ValidItem = false;

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_Doc_AddItem", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@BarCodeEntry", tbx_Barcode.Text);
                    cmd.Parameters.AddWithValue("@UserId", UserId);
                    cmd.Parameters.AddWithValue("@TerminalId", TerminalId);

                    //cmd.ExecuteNonQuery();

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        ValidItem = Boolean.Parse(reader["ValidItem"].ToString());                       
                    }


                    con.Close();


                    /*==============================*/


                    if (ValidItem)
                    {
                        tbx_Barcode.Text = string.Empty;

                        FillGrid_ItemOverVew_HeaderAndLines();

                        /*---------------------*/

                        ItemOverView_SelectedValues_MinId();
                        SelectedRow = MaxDocId;

                        grdItems.SelectedValue = SelectedRow;

                        grdItems.UpdateLayout();

                        if(MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
                        {
                            grdItems.ScrollIntoView(grdItems.SelectedItem);
                        }                        

                    }
                   

                }

            }
            catch (Exception e)
            {
                ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                errorDialog.Show();
                //MessageBox.Show(e.Message, "Error");
            }
           
        }

        private void DateTimer()
        {
            //Date Timer
            tblDate.Text = DateTime.Now.ToString();
            DispatcherTimer dispatcherTimer = new DispatcherTimer();
            dispatcherTimer.Tick += dispatcherTimer_Tick;
            dispatcherTimer.Interval = new TimeSpan(0, 0, 1);
            dispatcherTimer.Start();
        }

        private int SelectRow(string Type)
        {
            int NewSelectRow = SelectedRow;

            List<int> IdList = new List<int>();
            int[] RowIds;
            int ArrayLenght;
            int ArraySelectedIndex = 0;

            if (grdItems.SelectedValue == null)
            {
                SelectedRow = 0;
            }

            foreach (System.Data.DataRowView dr in grdItems.ItemsSource)
            {
                IdList.Add((int)dr[0]);
            }
            //List to array
            RowIds = IdList.ToArray();
            ArrayLenght = RowIds.Length;

            if (SelectedRow != 0)
            {
                for (int i = 0; i <= ArrayLenght-1; i++)
                {
                    if (RowIds[i] == SelectedRow)
                    {
                        ArraySelectedIndex = i;
                    }
                }
            }

            if (Type == "Up")
            {

                if (RowIds.Length > 0)
                {
                    if (SelectedRow != 0 && SelectedRow != RowIds[0] && ArraySelectedIndex != 0)
                    {
                        NewSelectRow = RowIds[ArraySelectedIndex - 1];
                    }
                }
            
            }
            else // Down
            {
                //MessageBox.Show(RowIds[ArrayLenght - 1].ToString());

                if (RowIds.Length > 0)
                {
                    if (SelectedRow != 0 && SelectedRow != RowIds[ArrayLenght - 1])
                    {
                        NewSelectRow = RowIds[ArraySelectedIndex + 1];
                    }
                }
            }

            //tbx_Barcode.Text = NewSelectRow.ToString();
            //MessageBox.Show(ArraySelectedIndex.ToString());

            SelectedRow = NewSelectRow;           

            return NewSelectRow;
        }

        /*
            Key Barcode Start
        */
        private string Pin = "";

        private void AddChar(string Value)
        {
            Pin = tbx_Barcode.Text;
            //if (Pin.Length < 4)
            //{
                Pin += Value;
                tbx_Barcode.Text = Pin;
            //}


            tbx_Barcode.SelectionStart = tbx_Barcode.Text.Length;
            tbx_Barcode.Focus();

            //tbx_Barcode.Select(tbx_Barcode.Text.Length, 0);

            //tbx_Barcode.CaretIndex = tbx_Barcode.Text.Length;
            //tbx_Barcode.Focus();
        }

        private void RemoveChar()
        {
            Pin = tbx_Barcode.Text;
            if (Pin.Length < 1)
            {
                Pin = "";
            }
            else
            {
                int Len = Pin.Length - 1;
                Pin = Pin.Substring(0, Len);
            }

            tbx_Barcode.Text = Pin;
            tbx_Barcode.Focus();
        }

        private void Btn_One_Click(object sender, RoutedEventArgs e)
        {
            //One
            AddChar("1");
        }

        private void Btn_Two_Click(object sender, RoutedEventArgs e)
        {
            //Two
            AddChar("2");
        }

        private void Btn_Three_Click(object sender, RoutedEventArgs e)
        {
            //Three
            AddChar("3");
        }

        private void Btn_Four_Click(object sender, RoutedEventArgs e)
        {
            //Four
            AddChar("4");
        }

        private void Btn_Five_Click(object sender, RoutedEventArgs e)
        {
            //Five
            AddChar("5");
        }

        private void Btn_Six_Click(object sender, RoutedEventArgs e)
        {
            //Six
            AddChar("6");
        }

        private void Btn_Seven_Click(object sender, RoutedEventArgs e)
        {
            //Seven
            AddChar("7");
        }

        private void Btn_Eight_Click(object sender, RoutedEventArgs e)
        {
            //Eight
            AddChar("8");
        }

        private void Btn_Nine_Click(object sender, RoutedEventArgs e)
        {
            //Nine
            AddChar("9");
        }

        private void Btn_Clear_Click(object sender, RoutedEventArgs e)
        {
            Pin = "";
            tbx_Barcode.Text = Pin;
            tbx_Barcode.Focus();

        }

        private void Btn_Zero_Click(object sender, RoutedEventArgs e)
        {
            //Zero
            AddChar("0");
        }

        /*
            Key Barcode End
        */

        private void dispatcherTimer_Tick(object sender, EventArgs e)
        {
            tblDate.Text = DateTime.Now.ToString();
        }

        private void Btn_Up_Click(object sender, RoutedEventArgs e)
        {
            grdItems.SelectedValue = SelectRow("Up");
            grdItems.UpdateLayout();

            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            {
                grdItems.ScrollIntoView(grdItems.SelectedItem);
            }
           
            tbx_Barcode.Focus();
        }

        private void Btn_Down_Click(object sender, RoutedEventArgs e)
        {
            grdItems.SelectedValue = SelectRow("Down");
            grdItems.UpdateLayout();            

            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            {
                grdItems.ScrollIntoView(grdItems.SelectedItem);
            }

            tbx_Barcode.Focus();            
        }

        private void GrdItems_KeyDown(object sender, KeyEventArgs e)
        {           

            if (e.Key == Key.Down)
            {
                grdItems.SelectedValue = SelectRow("Down");
                grdItems.UpdateLayout();

                if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
                {
                    grdItems.ScrollIntoView(grdItems.SelectedItem);
                }
                //grdItems.ScrollIntoView(grdItems.SelectedItem);
            }
            if (e.Key == Key.Up)
            {
                grdItems.SelectedValue = SelectRow("Up");
                grdItems.UpdateLayout();

                if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
                {
                    grdItems.ScrollIntoView(grdItems.SelectedItem);
                }
                //grdItems.ScrollIntoView(grdItems.SelectedItem);
            }
            if (e.Key == Key.Back)
            {
                RemoveChar();
            }
            if(e.Key == Key.Escape)
            {
                Pin = "";
                tbx_Barcode.Text = Pin;
            }

            if (!BarcodeFocused)
            {
                if (e.Key == Key.NumPad0 || e.Key == Key.D0) { AddChar("0"); }
                if (e.Key == Key.NumPad1 || e.Key == Key.D1) { AddChar("1"); }
                if (e.Key == Key.NumPad2 || e.Key == Key.D2) { AddChar("2"); }
                if (e.Key == Key.NumPad3 || e.Key == Key.D3) { AddChar("3"); }
                if (e.Key == Key.NumPad4 || e.Key == Key.D4) { AddChar("4"); }
                if (e.Key == Key.NumPad5 || e.Key == Key.D5) { AddChar("5"); }
                if (e.Key == Key.NumPad6 || e.Key == Key.D6) { AddChar("6"); }
                if (e.Key == Key.NumPad7 || e.Key == Key.D7) { AddChar("7"); }
                if (e.Key == Key.NumPad8 || e.Key == Key.D8) { AddChar("8"); }
                if (e.Key == Key.NumPad9 || e.Key == Key.D9) { AddChar("9"); }
            }

        }

        private void Tbx_Barcode_GotFocus(object sender, RoutedEventArgs e)
        {
            BarcodeFocused = true;
        }

        private void Tbx_Barcode_LostFocus(object sender, RoutedEventArgs e)
        {
            BarcodeFocused = false;
        }

        private void Tbx_Barcode_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                POS_Document_AddLine();
            }            
        }

        private void Btn_Qty_Click(object sender, RoutedEventArgs e)
        {
            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            {
                QuantityChange quantityChange = new QuantityChange(SelectedRow, DocumentSelection_GetDocId());
                quantityChange.ShowDialog();
            }
            //QuantityChange quantityChange = new QuantityChange(SelectedRow, DocumentSelection_GetDocId());
            //quantityChange.ShowDialog();

            FillGrid_ItemOverVew_HeaderAndLines();

            //*---------------------*/

            grdItems.SelectedValue = SelectedRow;

            grdItems.UpdateLayout();

            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            {
                grdItems.ScrollIntoView(grdItems.SelectedItem);
            }
            //grdItems.ScrollIntoView(grdItems.SelectedItem);

        }

        private void Btn_Remove_Click(object sender, RoutedEventArgs e) // Void Line
        {
            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            {
                VoidLine voidLine = new VoidLine(DocumentSelection_GetDocId(), SelectedRow);
                voidLine.ShowDialog();
            }
          
            FillGrid_ItemOverVew_HeaderAndLines();

            //if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            //{
            //    MessageBox.Show(SelectedRow.ToString());
            //}
           

            if(!GlobalVaraibles.VoidLine_Canceled) //Canceled
            {
                SelectedRow = ItemOverView_SelectedValues_MinId();
                grdItems.SelectedValue = SelectedRow;

                /*-------------------*/
                grdItems.SelectedValue = SelectedRow;
                grdItems.UpdateLayout();

                if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
                {
                    grdItems.ScrollIntoView(grdItems.SelectedItem);
                }
                /*-------------------*/
            }
            else //Did not cancel
            {
                /*-------------------*/
                //SelectedRow = ItemOverView_SelectedValues_MinId();               
                grdItems.SelectedValue = SelectedRow;
                grdItems.UpdateLayout();

                if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
                {
                    grdItems.ScrollIntoView(grdItems.SelectedItem);
                }
                /*-------------------*/
            }



        }

        private void Btn_LogOut_Click(object sender, RoutedEventArgs e)
        {
            //LogOut
            UserId = null;            
            MainWindow mainWindow = new MainWindow();
            mainWindow.Show();
            this.Close();

        }

        private void Btn_Onde1_Click(object sender, RoutedEventArgs e)
        {
            //Void Document

            VoidDocument voidDocument = new VoidDocument(DocumentSelection_GetDocId());
            voidDocument.ShowDialog();

            FillGrid_ItemOverVew_HeaderAndLines();

            //SelectedRow = ItemOverView_SelectedValues_MinId(); //1;
            //grdItems.SelectedValue = SelectedRow;

            /*-------------------*/
            grdItems.SelectedValue = SelectedRow;

            grdItems.UpdateLayout();

            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            {
                grdItems.ScrollIntoView(grdItems.SelectedItem);
            }
            /*-------------------*/

        }

        private void Btn_Enter_Click(object sender, RoutedEventArgs e)
        {
            POS_Document_AddLine();
            tbx_Barcode.Focus();
        }

        private void Btn_SuspendSale_Click(object sender, RoutedEventArgs e)
        {
            
            if(ResumeSuspendSale_Type() == "Suspend Sale")
            {
                //Suspend Sale
                SuspendSale suspendSale = new SuspendSale(DocumentSelection_GetDocId(), UserId, TerminalId);
                suspendSale.ShowDialog();

                FillGrid_ItemOverVew_HeaderAndLines();

                //SelectedRow = ItemOverView_SelectedValues_MinId(); //1;
                //grdItems.SelectedValue = SelectedRow;

                /*-------------------*/
                grdItems.SelectedValue = SelectedRow;

                grdItems.UpdateLayout();

                if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
                {
                    grdItems.ScrollIntoView(grdItems.SelectedItem);
                }
                /*-------------------*/


                //Change button text
                //tblSuspendResume.Text = ResumeSuspendSale_Type().ToUpper();
                if (ResumeSuspendSale_Type().ToUpper() == "RESUME SALE")
                {
                    tblSuspendResume.Text = "👈   RESUME";
                }
                else
                {
                    tblSuspendResume.Text = "✋ SUSPEND";
                }

            }
            else if(ResumeSuspendSale_Type() == "Resume Sale")
            {
                //Resume Sale
                ResumeSale resumeSale = new ResumeSale(UserId, TerminalId);
                resumeSale.ShowDialog();

                FillGrid_ItemOverVew_HeaderAndLines();

                SelectedRow = ItemOverView_SelectedValues_MinId(); //1;
                grdItems.SelectedValue = SelectedRow;

                //Change button text
                //tblSuspendResume.Text = ResumeSuspendSale_Type().ToUpper();
                if (ResumeSuspendSale_Type().ToUpper() == "RESUME SALE")
                {
                    tblSuspendResume.Text = "👈   RESUME"; //"🔄 RESUME";
                }
                else
                {
                    tblSuspendResume.Text = "✋ SUSPEND";
                }
            }

            tbx_Barcode.Focus();

        }

        private void Btn_ResumeSale_Click(object sender, RoutedEventArgs e)
        {

            tbx_Barcode.Focus();

        }

        private string ResumeSuspendSale_Type()
        {
            string Type = null;            

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcDoc_ResumeSuspendSale", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UserId", UserId);
                    cmd.Parameters.AddWithValue("@TerminalId", TerminalId);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Type = reader["Type"].ToString();                       
                    }

                    con.Close();
                }
            }

            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return Type;
        }

        private int GetItemId()
        {
            int LineId = 0;

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcDoc_GetItemId", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@LineId", SelectedRow);                   

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        LineId = Int32.Parse(reader["ItemId"].ToString());
                    }

                    con.Close();
                }
            }

            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return LineId;
        }

        private void Btn_Pay_Click(object sender, RoutedEventArgs e)
        {
            //Pay

            Pay pay = new Pay(DocumentSelection_GetDocId());
            pay.ShowDialog();

            FillGrid_ItemOverVew_HeaderAndLines();
            //GetLastSaleChange();
            /*-------------------*/
            grdItems.SelectedValue = SelectedRow;
            grdItems.UpdateLayout();

            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            {
                grdItems.ScrollIntoView(grdItems.SelectedItem);
            }
            /*-------------------*/

        }

        private void Btn_PriceChange_Click(object sender, RoutedEventArgs e)
        {
            //Change Price                      

            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            {
                PriceChange priceChange = new PriceChange(DocumentSelection_GetDocId(), SelectedRow, GetItemId(), "PriceChange");
                priceChange.ShowDialog();
            }            

            FillGrid_ItemOverVew_HeaderAndLines();

            //*---------------------*/

            grdItems.SelectedValue = SelectedRow;

            grdItems.UpdateLayout();

            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            {
                grdItems.ScrollIntoView(grdItems.SelectedItem);
            }
                       
        }

        private void Btn_Search_Click(object sender, RoutedEventArgs e)
        {
            ItemSearch itemSearch = new ItemSearch();
            itemSearch.ShowDialog();

            /*==============================*/
                       
                tbx_Barcode.Text = string.Empty;

                FillGrid_ItemOverVew_HeaderAndLines();

            /*-------------------*/
            ItemOverView_SelectedValues_MinId();
            SelectedRow = MaxDocId;
            grdItems.SelectedValue = SelectedRow;
            //grdItems.SelectedValue = SelectedRow;
            //grdItems.UpdateLayout();

            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
                 {
                     grdItems.ScrollIntoView(grdItems.SelectedItem);
                 }
                 /*-------------------*/

        }

        private void Btn_ItemButtons_Click(object sender, RoutedEventArgs e)
        {
            ItemButtons itemButtons = new ItemButtons();
            itemButtons.ShowDialog();           

            tbx_Barcode.Text = string.Empty;
            FillGrid_ItemOverVew_HeaderAndLines();

                                  

            if (GlobalVaraibles.ItemButons_Canceled == false)
            {
                ItemOverView_SelectedValues_MinId();
                SelectedRow = MaxDocId;
                grdItems.SelectedValue = SelectedRow;

                if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
                {
                    grdItems.ScrollIntoView(grdItems.SelectedItem);
                }
            }
            else
            {
                grdItems.SelectedValue = SelectedRow;
                grdItems.UpdateLayout();

                if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
                {
                    grdItems.ScrollIntoView(grdItems.SelectedItem);
                }
            }

        }

        private void btn_PrintLastSlip_Click(object sender, RoutedEventArgs e)
        {
            tbx_Barcode.Focus();
        }

        private void btn_Return_Click(object sender, RoutedEventArgs e)
        {
            //Returns
            if(DocumentSelection_GetDocId() == 0) //0 is no active sale
            {
                Returns returns = new Returns();
                returns.ShowDialog();
            }
            else
            {
                ErrorDialog errorDialog = new ErrorDialog("Complete Sale", "Please complete the current sale before continuing to Returns.");
                errorDialog.ShowDialog();
            }
           
            tbx_Barcode.Focus();

        }

        
    }
}
