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
    /// Interaction logic for QuantityChange.xaml
    /// </summary>
    public partial class QuantityChange : Window
    {
        public QuantityChange(int line_Id, int doc_id)
        {
            InitializeComponent();

            DocId = doc_id;
            LineId = line_Id;

            FirstTime = true;

            GetLineValues();

            tbx_Barcode.SelectAll();

        }

        /*  Class Varaibles */
        int DocId = 0;
        int LineId = 0;
        string ItemName = "";
        string Qty = "";
        Boolean FirstTime;
        /*------------------*/

        private void GetLineValues()
        {
            //string UserName = null;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcPOSDocLines_Values", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocId", DocId);
                    cmd.Parameters.AddWithValue("@LineId", LineId);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        ItemName = reader["ItemName"].ToString();
                        Qty = reader["Quantity"].ToString();
                    }

                    con.Close();

                    tbl_ItemNameQty.Text = ItemName + "; Qty: " + Qty;
                    tbx_Barcode.Text = Qty;
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
                //ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                //errorDialog.ShowDialog();
            }
            
        }

        private void ChangeQuatity()
        {
            
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_Doc_QtyChange", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocId", DocId);
                    cmd.Parameters.AddWithValue("@LineId", LineId);
                    cmd.Parameters.AddWithValue("@Quantity", Double.Parse(tbx_Barcode.Text));

                    cmd.ExecuteNonQuery();                    

                    con.Close();

                    this.Close();
                }
            }
            catch (Exception e)
            {
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
            if(FirstTime)
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

        private void Btn_Enter_Click(object sender, RoutedEventArgs e)
        {

        }        

        private void Btn_Back_Click_1(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void Btn_Ok_Click(object sender, RoutedEventArgs e)
        {
            ChangeQuatity();
        }

        private void Btn_Cancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

       
    }
}
