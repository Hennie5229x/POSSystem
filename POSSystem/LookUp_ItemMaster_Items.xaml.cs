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
    /// Interaction logic for LookUp_ItemMaster_Items.xaml
    /// </summary>
    public partial class LookUp_ItemMaster_Items : Window
    {
        public LookUp_ItemMaster_Items()
        {
            InitializeComponent();
            LookUpItemsFill("", "", "");
        }

        TextBox tb_ItemCode;
        TextBox tb_ItemName;
        TextBox tb_Barcode;

        private void LookUpItemsFill(string ItemCode, string ItemName, string Barcode)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(ConString))
                {
                    conn.Open();

                    SqlCommand cmd = new SqlCommand("lkpItems", conn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ItemCode", ItemCode);
                    cmd.Parameters.AddWithValue("@ItemName", ItemName);
                    cmd.Parameters.AddWithValue("@BarCode", Barcode);

                    SqlDataAdapter sda1 = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("Items");
                    sda1.Fill(dt);
                    grdLookUpItems.ItemsSource = dt.DefaultView;

                    conn.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }
        private void GrdLookUpItems_PreviewMouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {

            try
            {

                DataRowView dataRow = (DataRowView)grdLookUpItems.SelectedItem;

                if (dataRow != null)
                {
                    string cellValue = dataRow.Row.ItemArray[0].ToString();

                    PublicVariables.StockM_Cmp_ItemId = Int32.Parse(cellValue);

                    this.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error");
            }
        }

        private void Tbx_ItemCode_Loaded(object sender, RoutedEventArgs e)
        {
            tb_ItemCode = (sender as TextBox);
        }

        private void Tbx_ItemName_Loaded(object sender, RoutedEventArgs e)
        {
            tb_ItemName = (sender as TextBox);
        }

        private void Tbx_ItemBarcode_Loaded(object sender, RoutedEventArgs e)
        {
            tb_Barcode = (sender as TextBox);
        }

        private void tbTest_TextChanged(object sender, TextChangedEventArgs e)
        {
            LookUpItemsFill(tb_ItemCode.Text, tb_ItemName.Text, tb_Barcode.Text);
        }



        //private void Tbx_ItemCode_KeyUp(object sender, KeyEventArgs e)
        //{
        //    LookUpItemsFill();
        //}

        //private void Tbx_ItemName_KeyUp(object sender, KeyEventArgs e)
        //{
        //    LookUpItemsFill();
        //}

        //private void Tbx_ItemBarcode_KeyUp(object sender, KeyEventArgs e)
        //{
        //    LookUpItemsFill();
        //}


    }
}
