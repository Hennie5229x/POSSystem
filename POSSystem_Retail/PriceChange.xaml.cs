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
    /// Interaction logic for PriceChange.xaml
    /// </summary>
    public partial class PriceChange : Window
    {
        public PriceChange(int _DocId, int _LineId, int _ItemId, string _Action)
        {
            InitializeComponent();

            DocId = _DocId;
            LineId = _LineId;
            ItemId = _ItemId;
            Action = _Action;

            GetLineValues();
            tbx_Barcode.SelectAll();

            FirstTime = true;

        }

        /*  Class Varaibles */
        int DocId = 0;
        int LineId = 0;
        int ItemId = 0;
        string Action = string.Empty;
        string ItemName = "";
        string Price = "";
        Boolean FirstTime;
        /*------------------*/

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

                    SqlCommand cmd = new SqlCommand("calcChangePrice_Values", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocId", DocId);
                    cmd.Parameters.AddWithValue("@LineId", LineId);
                    cmd.Parameters.AddWithValue("@ItemId", ItemId);
                    cmd.Parameters.AddWithValue("@Action", Action);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        ItemName = reader["ItemName"].ToString();
                        Price = reader["Price"].ToString();
                    }                   

                    con.Close();

                    tbl_ItemNameQty.Text = ItemName + "; Price: " + Price;
                    tbx_Barcode.Text = Price;
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
                //ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                //errorDialog.ShowDialog();
            }

        }

        private void ChangePrice()
        {

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_Doc_PriceChange", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocId", DocId);
                    cmd.Parameters.AddWithValue("@LineId", LineId);
                    cmd.Parameters.AddWithValue("@Price", Double.Parse(tbx_Barcode.Text));

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

        private void Btn_Ok_Click(object sender, RoutedEventArgs e)
        {
            //Ok 
            if(Action == "SearchChange")
            {               
                Decimal Price = 0;
                bool Parsed = Decimal.TryParse(tbx_Barcode.Text, out Price);
                if (Parsed)
                {
                    GlobalVaraibles._ItemSearch_Price = Price;
                    this.Close();
                }
            }
            else if(Action == "PriceChange")
            {
                ChangePrice();
            }
        }

        private void Btn_Cancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void Btn_One_Click(object sender, RoutedEventArgs e)
        {
            AddChar("1");
        }

        private void Btn_Two_Click(object sender, RoutedEventArgs e)
        {
            AddChar("2");
        }

        private void Btn_Three_Click(object sender, RoutedEventArgs e)
        {
            AddChar("3");
        }

        private void Btn_Four_Click(object sender, RoutedEventArgs e)
        {
            AddChar("4");
        }

        private void Btn_Five_Click(object sender, RoutedEventArgs e)
        {
            AddChar("5");
        }

        private void Btn_Six_Click(object sender, RoutedEventArgs e)
        {
            AddChar("6");
        }

        private void Btn_Seven_Click(object sender, RoutedEventArgs e)
        {
            AddChar("7");
        }

        private void Btn_Eight_Click(object sender, RoutedEventArgs e)
        {
            AddChar("8");
        }

        private void Btn_Nine_Click(object sender, RoutedEventArgs e)
        {
            AddChar("9");
        }

        private void Btn_Zero_Click(object sender, RoutedEventArgs e)
        {
            AddChar("0");
        }

        private void Btn_Clear_Click(object sender, RoutedEventArgs e)
        {
            Pin = "";
            tbx_Barcode.Text = "";
        }

        private void Btn_Decimal_Click(object sender, RoutedEventArgs e)
        {
            AddChar(".");
        }
    }
}
