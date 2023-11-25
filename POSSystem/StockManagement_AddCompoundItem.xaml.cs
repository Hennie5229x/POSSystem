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
    /// Interaction logic for StockManagement_AddCompoundItem.xaml
    /// </summary>
    public partial class StockManagement_AddCompoundItem : Window
    {
        public StockManagement_AddCompoundItem(int Id)
        {
            InitializeComponent();
            HeaderId = Id;
        }

        private int HeaderId;
        private string GetItemName(int ItemId)
        {
            string ItemName = null;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcItemName", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ItemId", ItemId);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        ItemName = reader["ItemName"].ToString();
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return ItemName;
        }

        private void AddItem()
        {

            try
            {       

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpItemMasterCompounds_Insert", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@HeaderId", HeaderId);
                    cmd.Parameters.AddWithValue("@ItemMasterItemId", PublicVariables.StockM_Cmp_ItemId);
                    cmd.Parameters.AddWithValue("@Quantity", Decimal.Parse(tbx_Quantity.Text));                   

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

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void BtnAddCompoundItem_Click(object sender, RoutedEventArgs e)
        {
            //Add Compound Item
            AddItem();
        }

        private void TextBlock_MouseEnter(object sender, MouseEventArgs e)
        {
            //Mouse Enter            
            //tblk_Arrow.Background = Brushes.LightBlue;
            //tblk_Arrow.Foreground = Brushes.LightBlue;
        }

        private void Tblk_Arrow_MouseLeave(object sender, MouseEventArgs e)
        {
            //Mouse Leave
            //tblk_Arrow.Background = Brushes.White;
           
        }

        private void Tblk_Arrow_PreviewMouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            //Mouse Click
            LookUp_ItemMaster_Items lookUp_ItemMaster_Items = new LookUp_ItemMaster_Items();
            lookUp_ItemMaster_Items.ShowDialog();
            tbx_Item.Text = GetItemName(PublicVariables.StockM_Cmp_ItemId);
        }

        private void BtnSearch_Click(object sender, RoutedEventArgs e)
        {
            //Mouse Click
            LookUp_ItemMaster_Items lookUp_ItemMaster_Items = new LookUp_ItemMaster_Items();
            lookUp_ItemMaster_Items.ShowDialog();
            tbx_Item.Text = GetItemName(PublicVariables.StockM_Cmp_ItemId);
        }
    }
}
