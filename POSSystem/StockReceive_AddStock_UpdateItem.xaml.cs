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

namespace POSSystem
{
    /// <summary>
    /// Interaction logic for StockReceive_AddStock_UpdateItem.xaml
    /// </summary>
    public partial class StockReceive_AddStock_UpdateItem : Window
    {
        public StockReceive_AddStock_UpdateItem(int _Id)
        {
            InitializeComponent();
            Id = _Id;

            GetStockReveiceValues();
        }

        int Id;

        private void GetStockReveiceValues()
        {
            string ItemName = null;
            string Qty = null;
            string PriceIncl = null;
            string PriceExcl = null;
                

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpStockReceive_Tmp_ItemDetail", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", Id);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        ItemName = reader["ItemName"].ToString();
                        Qty = reader["QuantityReceived"].ToString();
                        PriceIncl = reader["PricePurchaseIncl"].ToString();
                        PriceExcl = reader["PricePurchaseExcl"].ToString();
                    }

                    con.Close();

                    tbx_ItemName.Text = ItemName;
                    tbx_Quantity.Text = Qty;
                    tbx_PricePurchaseExcl.Text = PriceExcl;
                    tbx_PricePurchaseIncl.Text = PriceIncl;

                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }            
        }

        private decimal TaxCodeVATValue()
        {
            decimal Vat = 0;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcStockReceiveUpdate_ItemTax", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", Id);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Vat = Decimal.Parse(reader["VAT"].ToString());
                    }
                    
                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return Vat;
        }
        private void PricePurchaseIncl()
        {
            
            if (tbx_PricePurchaseIncl.Text != string.Empty)
            {
                decimal PricePurchaseIncl;
                decimal Vat = TaxCodeVATValue();
                decimal PricePurchaseExcl;

                if ((Decimal.TryParse(tbx_PricePurchaseIncl.Text, out PricePurchaseIncl)))
                {
                    PricePurchaseExcl = PricePurchaseIncl - Math.Round((Vat / 100 * PricePurchaseIncl), 2);
                    tbx_PricePurchaseExcl.Text = PricePurchaseExcl.ToString();
                }
                else
                {
                    tbx_PricePurchaseExcl.Text = string.Empty;
                }
            }
        }
        private void PricePurchaseExcl()
        {
            if (tbx_PricePurchaseExcl.Text != string.Empty)
            {
                decimal PricePurchaseExcl;
                decimal Vat = TaxCodeVATValue();
                decimal PricePurchaseIncl;

                if ((Decimal.TryParse(tbx_PricePurchaseExcl.Text, out PricePurchaseExcl)))
                {
                    PricePurchaseIncl = PricePurchaseExcl + Math.Round((Vat / 100 * PricePurchaseExcl), 2);
                    tbx_PricePurchaseIncl.Text = PricePurchaseIncl.ToString();
                }
                else
                {
                    tbx_PricePurchaseIncl.Text = string.Empty;
                }
            }
        }

        private void StockReceive()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpStockReceive_Tmp_Update", con);

                    cmd.CommandType = CommandType.StoredProcedure;                                      

                    cmd.Parameters.AddWithValue("@Id", Id);
                    cmd.Parameters.AddWithValue("@Quantity", tbx_Quantity.Text);
                    cmd.Parameters.AddWithValue("@PriceExcl", tbx_PricePurchaseExcl.Text);
                    cmd.Parameters.AddWithValue("@PriceIncl", tbx_PricePurchaseIncl.Text);                    

                    cmd.ExecuteNonQuery();

                    con.Close();

                    this.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        //////////////////////////////////
        private void Tbx_Quantity_KeyUp(object sender, KeyEventArgs e)
        {

        }

        private void Tbx_PricePurchaseIncl_KeyUp(object sender, KeyEventArgs e)
        {
            PricePurchaseIncl();
        }

        private void Tbx_PricePurchaseExcl_KeyUp(object sender, KeyEventArgs e)
        {
            PricePurchaseExcl();
        }

        private void BtnUpdateStockReceive_Click(object sender, RoutedEventArgs e)
        {
            if(tbx_Quantity.Text == string.Empty || tbx_Quantity.Text == null || 
                tbx_PricePurchaseExcl.Text == string.Empty || tbx_PricePurchaseExcl.Text == null ||
                tbx_PricePurchaseIncl.Text == string.Empty || tbx_PricePurchaseIncl.Text == null)
            {
                MessageBox.Show("Fields cannot be empty", "Error");
            }
            else
            {
                StockReceive();
            }
        }

        private void Btn_Back_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }
    }
}
