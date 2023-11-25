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

namespace POSSystem_Retail
{
    /// <summary>
    /// Interaction logic for Returns.xaml
    /// </summary>
    public partial class Returns : Window
    {
        public Returns()
        {
            InitializeComponent();

            tbx_Barcode.Focus();

            //Button and Textbox colors
            btn_Linked.Background = Brushes.ForestGreen;
            btn_UnLinked.Background = Brushes.LightGray;
            tbx_LinkedDocNum.IsEnabled = true;
            tbx_LinkedDocNum.Background = Brushes.White;
            ReturnType = "LINKED"; //Default is Linked Returns
            tblDocType.Text = "TYPE: " + ReturnType;
            tbx_LinkedDocNum.Focus();
            btn_AddAllItems.IsEnabled = false;
            btn_AddAllItems.Background = Brushes.LightGray;
            

            //-------------//

            GetHeaderData();
            FillGrid_ItemOverVew_HeaderAndLines();

            SelectedRow = ItemOverView_SelectedValues_MinId(); //1;
            grdItems.SelectedValue = SelectedRow;

        }
        //------------------------------//        
        bool ReturnAllLines = false;
        int SelectedRow;
        int MaxDocId = 0;

        // Header Info //
        int Id = 0;
        string ReturnType;
        string OriginalDocNum;
        int OriginalDocId = 0;
        int UnlinkedHeaderId = 0;

        //-----------------------------//

        private void CancelReturn(string ReturnType, int OringalDocId, int UnlinkedRetrunId)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;

                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpReturns_Cancel", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ReturnType", ReturnType);                    
                    cmd.Parameters.AddWithValue("@OrignalDocId", OringalDocId);
                    cmd.Parameters.AddWithValue("@UnlinkedHeaderId", UnlinkedRetrunId);

                    cmd.ExecuteNonQuery();

                    con.Close();                   
                }
            }
            catch (Exception e)
            {
                ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                errorDialog.ShowDialog();
            }
        }

        private void FillGrid_ItemOverVew_HeaderAndLines()
           {           

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

                    SqlCommand cmd = new SqlCommand("stpReturns_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ReturnType", ReturnType);
                    cmd.Parameters.AddWithValue("@DocId", OriginalDocId);
                    cmd.Parameters.AddWithValue("@UnlinkedHeaderId", UnlinkedHeaderId);

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable("Items");
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

        private void GetHeaderData()
        {
          
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcReturns_IdSelection", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                   //cmd.Parameters.AddWithValue("@DocNum", DocNum);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Id = Int32.Parse(reader["Id"].ToString());
                        ReturnType = reader["ReturnType"].ToString();
                        OriginalDocNum = reader["OriginalDocNum"].ToString();
                        OriginalDocId = Int32.Parse(reader["OriginalDocId"].ToString());
                        UnlinkedHeaderId = Int32.Parse(reader["UnlinkedHeaderId"].ToString());
                    }
                                      

                    con.Close();

                    //----- Apply Header Data -----//
                    tblDocType.Text = "TYPE: "+ReturnType;

                    if (Id > 0) //Id Found
                    {                        
                        btn_Linked.IsEnabled = false;
                        btn_Linked.Background = Brushes.LightGray;
                        btn_UnLinked.IsEnabled = false;
                        btn_UnLinked.Background = Brushes.LightGray;
                        btn_AddAllItems.IsEnabled = false;
                        btn_AddAllItems.Background = Brushes.LightGray;
                        btn_LinkedItems.IsEnabled = true;
                        btn_LinkedItems.Background = Brushes.ForestGreen;
                        tbx_LinkedDocNum.Text = OriginalDocNum;
                        tbx_LinkedDocNum.IsEnabled = false;
                        tbx_LinkedDocNum.Background = Brushes.LightGray;
                        btn_ItemButtons.IsEnabled = true;
                        btn_ItemButtons.Background = Brushes.CornflowerBlue;
                        btn_Search.IsEnabled = true;
                        btn_Search.Background = Brushes.CornflowerBlue;

                        if(ReturnType == "LINKED")
                        {
                            btn_PriceChange.IsEnabled = false;
                            btn_PriceChange.Background = Brushes.LightGray;
                        }
                        else
                        {
                            btn_PriceChange.IsEnabled = true;
                            btn_PriceChange.Background = Brushes.CornflowerBlue;

                        }
                       


                    }
                    else // Id Not Found
                    {
                        if (IsValidDocNum(tbx_LinkedDocNum.Text)) //First Time Valid DocNum
                        {                           
                            btn_AddAllItems.IsEnabled = true;
                            btn_AddAllItems.Background = Brushes.ForestGreen;
                            btn_LinkedItems.IsEnabled = true;
                            btn_LinkedItems.Background = Brushes.ForestGreen;
                            btn_Linked.IsEnabled = false;
                            btn_Linked.Background = Brushes.LightGray;
                            btn_UnLinked.IsEnabled = false;
                            btn_UnLinked.Background = Brushes.LightGray;                           
                            tbx_LinkedDocNum.IsEnabled = false;
                            tbx_LinkedDocNum.Background = Brushes.LightGray;
                            btn_ItemButtons.IsEnabled = false;
                            btn_ItemButtons.Background = Brushes.LightGray;
                            btn_Search.IsEnabled = false;
                            btn_Search.Background = Brushes.LightGray;
                            btn_PriceChange.IsEnabled = false;
                            btn_PriceChange.Background = Brushes.LightGray;
                        }
                        else //No valid doc num
                        {
                            btn_AddAllItems.IsEnabled = false;
                            btn_AddAllItems.Background = Brushes.LightGray;
                            btn_LinkedItems.IsEnabled = false;
                            btn_LinkedItems.Background = Brushes.LightGray;
                            btn_Linked.IsEnabled = true;
                            btn_Linked.Background = Brushes.ForestGreen;
                            btn_UnLinked.IsEnabled = true;
                            btn_UnLinked.Background = Brushes.White;                           
                            tbx_LinkedDocNum.IsEnabled = true;
                            tbx_LinkedDocNum.Background = Brushes.White;
                            btn_ItemButtons.IsEnabled = false;
                            btn_ItemButtons.Background = Brushes.LightGray;
                            btn_Search.IsEnabled = false;
                            btn_Search.Background = Brushes.LightGray;
                            btn_PriceChange.IsEnabled = true;
                            btn_PriceChange.Background = Brushes.CornflowerBlue;

                        }
                    }       
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void AddItem(string ReturnType, string DocNum, bool ReturnAllLines, string Barcode, int ItemId = 0)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpReturns_AddItem", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ReturnType", ReturnType);
                    cmd.Parameters.AddWithValue("@ReturnAllLines", ReturnAllLines);
                    cmd.Parameters.AddWithValue("@DocNum", DocNum);
                    cmd.Parameters.AddWithValue("@Barcode", Barcode);
                    cmd.Parameters.AddWithValue("@UnlinkedHeaderId", UnlinkedHeaderId); 
                    cmd.Parameters.AddWithValue("@ItemId", ItemId);

                    cmd.ExecuteNonQuery();

                    con.Close();

                    btn_AddAllItems.IsEnabled = false;
                    btn_AddAllItems.Background = Brushes.LightGray;

                    tbx_Barcode.Text = "";

                    GetHeaderData();
                    FillGrid_ItemOverVew_HeaderAndLines();
                }
            }
            catch (Exception e)
            {
                ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                errorDialog.ShowDialog();
            }
        }

        private int GetItemCount(string DocNum)
        {
            int Count = 0;

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcReturns_ItemCount", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocNum", DocNum);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Count = Int32.Parse(reader["Count"].ToString());
                    }

                    con.Close();
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return Count;

        }

        private bool IsValidDocNum(string DocNum)
        {
            bool isValid = false;

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcReturns_ValidDocNum", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocNum", DocNum);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        isValid = Boolean.Parse(reader["ValidDocNum"].ToString());
                    }

                    con.Close();
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return isValid;

        }

        private void btn_Linked_Click(object sender, RoutedEventArgs e)
        {
            //Linked Return
            btn_Linked.Background = Brushes.ForestGreen;
            btn_UnLinked.Background = Brushes.LightGray;
            tbx_LinkedDocNum.IsEnabled = true;
            tbx_LinkedDocNum.Background = Brushes.White;
            ReturnType = "LINKED";
            tblDocType.Text = "TYPE: " + ReturnType;
            tbx_LinkedDocNum.Focus();

            GetHeaderData();


        }

        private void btn_UnLinked_Click(object sender, RoutedEventArgs e)
        {
            //Unlinked Return
            btn_Linked.Background = Brushes.LightGray;
            btn_UnLinked.Background = Brushes.ForestGreen;
            tbx_LinkedDocNum.IsEnabled = false;
            tbx_LinkedDocNum.Background = Brushes.LightGray;
            ReturnType = "UNLINKED";
            tblDocType.Text = "TYPE: " + ReturnType;
            tbx_LinkedDocNum.Text = "";
            btn_AddAllItems.IsEnabled = false;
            btn_AddAllItems.Background = Brushes.LightGray;
            btn_ItemButtons.IsEnabled = true;
            btn_ItemButtons.Background = Brushes.CornflowerBlue;        
            btn_Search.IsEnabled = true;
            btn_Search.Background = Brushes.CornflowerBlue;

            tbx_Barcode.Focus();
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
                for (int i = 0; i <= ArrayLenght - 1; i++)
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

                    SqlCommand cmd = new SqlCommand("calcReturnsItemOverView_SelectedValues", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocId", OriginalDocId);
                    cmd.Parameters.AddWithValue("@UnlinkedHeaderId", UnlinkedHeaderId);

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
            if (e.Key == Key.Escape)
            {
                Pin = "";
                tbx_Barcode.Text = Pin;
            }

            /*
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
            */

        }

        private void Tbx_Barcode_GotFocus(object sender, RoutedEventArgs e)
        {
            
        }

        private void Tbx_Barcode_LostFocus(object sender, RoutedEventArgs e)
        {
            
        }

        private void Tbx_Barcode_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                AddItem(ReturnType, tbx_LinkedDocNum.Text, ReturnAllLines, tbx_Barcode.Text);

                ItemOverView_SelectedValues_MinId(); 
                SelectedRow = MaxDocId;
                grdItems.SelectedValue = SelectedRow;

                if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
                {
                    grdItems.ScrollIntoView(grdItems.SelectedItem);
                }

            }
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

        

        private void Btn_Enter_Click(object sender, RoutedEventArgs e)
        {
            AddItem(ReturnType, tbx_LinkedDocNum.Text, ReturnAllLines, tbx_Barcode.Text);

            ItemOverView_SelectedValues_MinId();
            SelectedRow = MaxDocId;
            grdItems.SelectedValue = SelectedRow;

            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            {
                grdItems.ScrollIntoView(grdItems.SelectedItem);
            }
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

        private void Btn_Qty_Click(object sender, RoutedEventArgs e)
        {

        }

        private void Btn_Remove_Click(object sender, RoutedEventArgs e)
        {

        }

        private void Btn_PriceChange_Click(object sender, RoutedEventArgs e)
        {

        }

        private void btn_Restock_Click(object sender, RoutedEventArgs e)
        {

        }

        private void Btn_Search_Click(object sender, RoutedEventArgs e)
        {
            //Search
            ItemSearch itemSearch = new ItemSearch("RETURN", ReturnType, ReturnAllLines, tbx_LinkedDocNum.Text, UnlinkedHeaderId);
            itemSearch.ShowDialog();

            GetHeaderData();
            FillGrid_ItemOverVew_HeaderAndLines();

            ItemOverView_SelectedValues_MinId();
            SelectedRow = MaxDocId;
            grdItems.SelectedValue = SelectedRow;

            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            {
                grdItems.ScrollIntoView(grdItems.SelectedItem);
            }

            tbx_Barcode.Focus();
        }

        private void Btn_ItemButtons_Click(object sender, RoutedEventArgs e)
        {
            ItemButtons itemButtons = new ItemButtons("RETURN", ReturnType, ReturnAllLines, tbx_LinkedDocNum.Text, UnlinkedHeaderId);
            itemButtons.ShowDialog();
           
            GetHeaderData();
            FillGrid_ItemOverVew_HeaderAndLines();
           
            ItemOverView_SelectedValues_MinId();
            SelectedRow = MaxDocId;
            grdItems.SelectedValue = SelectedRow;

            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            {
                grdItems.ScrollIntoView(grdItems.SelectedItem);
            }

            tbx_Barcode.Focus();
        }

        private void btn_AddAllItems_Click(object sender, RoutedEventArgs e)
        {
            //Add All Items
            if(GetItemCount(tbx_LinkedDocNum.Text) == 0)
            {
                if (IsValidDocNum(tbx_LinkedDocNum.Text))
                {
                    ReturnAllLines = true;                    
                    AddItem(ReturnType, tbx_LinkedDocNum.Text, ReturnAllLines, tbx_Barcode.Text);
                }
            }
        }

        private void tbx_LinkedDocNum_KeyDown(object sender, KeyEventArgs e)
        {
            if ((e.Key == Key.Enter || e.Key == Key.Tab) && IsValidDocNum(tbx_LinkedDocNum.Text))
            {
                tbx_LinkedDocNum.Text = tbx_LinkedDocNum.Text.ToUpper();
                btn_AddAllItems.IsEnabled = true;
                btn_AddAllItems.Background = Brushes.ForestGreen;
                btn_LinkedItems.IsEnabled = true;
                btn_LinkedItems.Background = Brushes.ForestGreen;
                tbx_LinkedDocNum.IsEnabled = false;
                tbx_LinkedDocNum.Background = Brushes.LightGray;
                btn_Linked.IsEnabled = false;
                btn_UnLinked.IsEnabled = false;
                btn_ItemButtons.IsEnabled = true;
                btn_ItemButtons.Background = Brushes.CornflowerBlue;
            }
        }

        private void btn_Back_Click(object sender, RoutedEventArgs e)
        {
            //Cancel
            MessageDialog messageDialog = new MessageDialog("Confirmation", "Are you sure you want to cancel this Return? All progress will be lost.");
            messageDialog.ShowDialog();

            if(GlobalVaraibles.MessageDecision)
            {
                //Yes
                if (OriginalDocId > 0 || UnlinkedHeaderId > 0)
                {
                    CancelReturn(ReturnType, OriginalDocId, UnlinkedHeaderId);
                }                

                this.Close();
            }
            
        }

        private void btn_LinkedItems_Click(object sender, RoutedEventArgs e)
        {
            ItemSearchLookup_Returns itemSearchLookup_Returns = new ItemSearchLookup_Returns(tbx_LinkedDocNum.Text);//OriginalDocNum
            itemSearchLookup_Returns.ShowDialog();

            if (GlobalVaraibles._ItemId > 0)
            {
                AddItem(ReturnType, tbx_LinkedDocNum.Text, false, "", GlobalVaraibles._ItemId);
            }

            GetHeaderData();
            FillGrid_ItemOverVew_HeaderAndLines();

            ItemOverView_SelectedValues_MinId();
            SelectedRow = MaxDocId;
            grdItems.SelectedValue = SelectedRow;

            if (MaxDocId != 0 && ItemOverView_SelectedValues_MinId() != 0)
            {
                grdItems.ScrollIntoView(grdItems.SelectedItem);
            }

            tbx_Barcode.Focus();

        }
    }
}
