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
    /// Interaction logic for StockReceive.xaml
    /// </summary>
    public partial class StockReceive : Window
    {
        public StockReceive()
        {
            InitializeComponent();

            FillDataGrid();
        }

        public void FillDataGrid()
        {
            try
            {               

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpStockReceive_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ItemCode", tbx_ItemCode.Text);
                    cmd.Parameters.AddWithValue("@ItemName", tbx_ItemName.Text);
                    cmd.Parameters.AddWithValue("@ReceiveDate", datepicker.Text);
                    cmd.Parameters.AddWithValue("@SupplierName", tbx_Supplier.Text);
                    cmd.Parameters.AddWithValue("@ReceivedByUser", tbx_ReceivedBy.Text);
                    cmd.Parameters.AddWithValue("@InvoiceNum", tbx_Invoice.Text);

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable("StockReceive");
                    sda.Fill(dt);
                    grdStockReceive.ItemsSource = dt.DefaultView;
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }       

        private void Datepicker_CalendarClosed(object sender, RoutedEventArgs e)
        {
            FillDataGrid();
        }

        private void Tbx_Name_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Tbx_ToValue_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Tbx_Supplier_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Tbx_ReceivedBy_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Datepicker_KeyUp(object sender, KeyEventArgs e)
        {

        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void Btn_ReceiveStock_Click(object sender, RoutedEventArgs e)
        {
            //Receive Stock
            StockReceive_AddStock stockReceive_AddStock = new StockReceive_AddStock();
            stockReceive_AddStock.ShowDialog();
            FillDataGrid();
        }

        private void Tbx_Invoice_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }
    }
}
