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
    /// Interaction logic for Pay.xaml
    /// </summary>
    public partial class Pay : Window
    {
        public Pay(int doc_id)
        {
            InitializeComponent();

            DocId = doc_id;

            DocumentPAY_Values();

            FirstTime = true;

        }


        int DocId = 0;
        string TenderType = null;
        Boolean FirstTime;
        decimal DocumentTotal;
        /*-----------------*/

        private void DocumentPAY_Values()
        {
            string SalesTotal = null;
            string AmountDue = null;
            string CashTendered = null;
            string CardTendered = null;
            string Change = null;            

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_PAY_Values", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocId", DocId);                   

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        SalesTotal = reader["SalesTotal"].ToString();
                        AmountDue = reader["AmountDue"].ToString();
                        CashTendered = reader["CashTendered"].ToString();
                        CardTendered = reader["CardTendered"].ToString();
                        Change = reader["Change"].ToString();
                        DocumentTotal = Decimal.Parse(reader["DocumentTotal"].ToString());
                    }

                    con.Close();

                    tblSalesTotal_Value.Text = SalesTotal;
                    tblAmountDue_Value.Text = AmountDue;
                    tblCashTendered_Value.Text = CashTendered;
                    tblCardTendered_Value.Text = CardTendered;
                    tblChangeDue_Value.Text = Change;

                    if(tblAmountDue_Value.Text != "R0.00")
                    {
                        tblTotalDue.Background = Brushes.Red;
                        tblAmountDue_Value.Background = Brushes.Red;
                    }
                    else
                    {
                        tblTotalDue.Background = Brushes.White;
                        tblAmountDue_Value.Background = Brushes.White;
                    }

                    if (TenderType != null)
                    {
                        tblTenderType.Background = Brushes.Yellow;
                        tblTenderType_Value.Background = Brushes.Yellow;
                    }
                    else
                    {
                        tblTenderType.Background = Brushes.White;
                        tblTenderType_Value.Background = Brushes.White;
                    }


                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

        }

        private void Document_Pay_TenderType()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_PAY_TenderTypes", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocId", DocId);
                    cmd.Parameters.AddWithValue("@TenderType", TenderType);
                    cmd.Parameters.AddWithValue("@TenderedTotal", Convert.ToDecimal(tbx_Barcode.Text));

                    cmd.ExecuteNonQuery();

                    con.Close();

                    //this.Close();

                }
            }
            catch (Exception e)
            {
                //MessageBox.Show(e.Message, "Error");
                ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                errorDialog.ShowDialog();
            }

        }

        private void Document_Pay_Finalize()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;               
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_PAY_Finalize", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocId", DocId);                   

                    cmd.ExecuteNonQuery();

                    con.Close();

                    this.Close();

                }
            }
            catch (Exception e)
            {
                //MessageBox.Show(e.Message, "Error");
                ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                errorDialog.ShowDialog();
            }

        }

        private void PrintSlip()
        {
            try
            {
                //Add Print logic             
            }
            catch (Exception e)
            {
                //MessageBox.Show(e.Message, "Error");
                ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                errorDialog.ShowDialog();
            }

        }

        /*
            Key Start
        */
        private string Pin = "";

        private void AddChar(string Value)
        {
            if (FirstTime)
            {
                Pin = "";
                tbx_Barcode.Text = Pin;

                FirstTime = false;
            }

            Pin = tbx_Barcode.Text;
            Pin += Value;
            tbx_Barcode.Text = Pin;

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
            tbx_Barcode.Text = "";
        }

        private void Btn_Clear_Click_1(object sender, RoutedEventArgs e)
        {
            Pin = "";
            tbx_Barcode.Text = "";
        }

        private void Btn_Zero_Click(object sender, RoutedEventArgs e)
        {
            //Zero
            AddChar("0");
        }

        private void Btn_Decimal_Click(object sender, RoutedEventArgs e)
        {
            //Decimal
            AddChar(".");
        }

        private void Btn_Ok_Click(object sender, RoutedEventArgs e)
        {
            //OK
            if (TenderType == null)
            {
                ErrorDialog errorDialog = new ErrorDialog("Error", "First select a tender type.");
                errorDialog.ShowDialog();
            }
            else
            {
                Document_Pay_TenderType();
                DocumentPAY_Values();
                Pin = "";
                tbx_Barcode.Text = "";
            }
        }

        private void Btn_Pay_Click(object sender, RoutedEventArgs e)
        {
            //PAY
            if (tblAmountDue_Value.Text == "R0.00")
            {
                Document_Pay_Finalize();

            }
           
        }

        private void Btn_Cancel_Click(object sender, RoutedEventArgs e)
        {
            //Close
            this.Close();
        }

        private void BtnCash_Click(object sender, RoutedEventArgs e)
        {
            //Cash
            btnCash.Background = Brushes.Yellow;
            btnCard.Background = Brushes.LightGray;
            ////////////////////////////////////

            TenderType = "Cash";
            tblTenderType_Value.Text = TenderType.ToUpper();
            tbx_Barcode.Text = string.Empty;

            if (TenderType != null)
            {
                tblTenderType.Background = Brushes.Yellow;
                tblTenderType_Value.Background = Brushes.Yellow;
            }
            else
            {
                tblTenderType.Background = Brushes.White;
                tblTenderType_Value.Background = Brushes.White;
            }
        }

        private void BtnCard_Click(object sender, RoutedEventArgs e)
        {
            //Card
            btnCard.Background = Brushes.Yellow;
            btnCash.Background = Brushes.LightGray;
            ////////////////////////////////////

            TenderType = "Card";
            tblTenderType_Value.Text = TenderType.ToUpper();
            tbx_Barcode.Text = DocumentTotal.ToString();

            if (TenderType != null)
            {
                tblTenderType.Background = Brushes.Yellow;
                tblTenderType_Value.Background = Brushes.Yellow;
            }
            else
            {
                tblTenderType.Background = Brushes.White;
                tblTenderType_Value.Background = Brushes.White;
            }
        }

        private void Tbx_Barcode_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                if(TenderType == null)
                {
                    ErrorDialog errorDialog = new ErrorDialog("Error", "First select a tender type.");
                    errorDialog.ShowDialog();
                }
                else
                {
                    Document_Pay_TenderType();
                    DocumentPAY_Values();
                }
             
            }
        }

        private void Btn_Reset_Click(object sender, RoutedEventArgs e)
        {
            Pay_Reset pay_Reset = new Pay_Reset(DocId);
            pay_Reset.ShowDialog();
            DocumentPAY_Values();

            Pin = "";
            tbx_Barcode.Text = "";
        }
    }
}
