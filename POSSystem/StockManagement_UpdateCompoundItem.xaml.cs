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
    /// Interaction logic for StockManagement_UpdateCompoundItem.xaml
    /// </summary>
    public partial class StockManagement_UpdateCompoundItem : Window
    {
        public StockManagement_UpdateCompoundItem(int Item_Id)
        {
            InitializeComponent();           
            ItemId = Item_Id;

            GetItemName();
        }
       
        int ItemId;
       
         private void GetItemName()
        {
            string ItemName = null;
            string Qty = null;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;               
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcItemName_Value", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", ItemId);

                    SqlDataReader reader = cmd.ExecuteReader();                    

                    while (reader.Read())
                    {
                        ItemName = reader["ItemName"].ToString();
                        Qty = reader["Quantity"].ToString();
                    }

                    con.Close();

                    tbx_Item.Text = ItemName;
                    tbx_Quantity.Text = Qty;
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }            
        }

        private void UpdateItem()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpItemMasterCompounds_Update", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                                        
                    cmd.Parameters.AddWithValue("@Id", ItemId);
                    cmd.Parameters.AddWithValue("@Quantity", tbx_Quantity.Text);                    

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


        private void BtnAddCompoundItem_Click(object sender, RoutedEventArgs e)
        {
            UpdateItem();
        }
        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }
    }
}
