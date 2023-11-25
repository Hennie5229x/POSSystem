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
    /// Interaction logic for ItemSearchLookup.xaml
    /// </summary>
    public partial class ItemSearchLookup_Returns : Window
    {
        public ItemSearchLookup_Returns(string _DocNum)
        {
            InitializeComponent();

            DocNum = _DocNum;
            LookUpItemsFill(DocNum);
        }

        string DocNum = "";


        private void LookUpItemsFill(string OringinalDocNum)
        {
            try
            {

                //MessageBox.Show(OringinalDocNum);

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(ConString))
                {
                    conn.Open();

                    SqlCommand cmd = new SqlCommand("lkpItems_Returns", conn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocNum", OringinalDocNum);
                   

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

        /*
        private void Tbx_ItemCode_KeyUp(object sender, KeyEventArgs e)
        {
            LookUpItemsFill();
        }

        private void Tbx_ItemName_KeyUp(object sender, KeyEventArgs e)
        {
            LookUpItemsFill();
        }

        private void Tbx_ItemBarcode_KeyUp(object sender, KeyEventArgs e)
        {
            LookUpItemsFill();
        }
        */

        private void GrdLookUpItems_PreviewMouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            //Grid Click
            try
            {
                DataRowView dataRow = (DataRowView)grdLookUpItems.SelectedItem;

                if (dataRow != null)
                {
                    string cellValue = dataRow.Row.ItemArray[0].ToString();

                    GlobalVaraibles._ItemId = Int32.Parse(cellValue);

                    this.Close();
                }
            }
            catch (Exception ex)
            {
                ErrorDialog errorDialog = new ErrorDialog("Error", ex.Message);
                errorDialog.ShowDialog();

                //MessageBox.Show(ex.Message, "Error");
            }

            
        }

        //private void Tbx_ItemCode_Loaded(object sender, RoutedEventArgs e)
        //{
        //    tb_ItemCode = (sender as TextBox);
        //}
        //private void Tbx_ItemName_Loaded(object sender, RoutedEventArgs e)
        //{
        //    tb_ItemName = (sender as TextBox);
        //}

        //private void Tbx_ItemBarcode_Loaded(object sender, RoutedEventArgs e)
        //{
        //    tb_Barcode = (sender as TextBox);
        //}

        //private void tbTest_TextChanged(object sender, TextChangedEventArgs e)
        //{
        //    LookUpItemsFill(tb_ItemCode.Text, tb_ItemName.Text, tb_Barcode.Text);
        //}
    }
}
