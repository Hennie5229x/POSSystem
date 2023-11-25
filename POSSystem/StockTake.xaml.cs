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
    /// Interaction logic for StockTake.xaml
    /// </summary>
    public partial class StockTake : Window
    {
        public StockTake()
        {
            InitializeComponent();

            FillDataGrid_StockTakeHeader();

        }

        private void FillDataGrid_StockTakeHeader()
        {          
            
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpStockTake_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    if (datepicker_dateFrom.Text == string.Empty || datepicker_dateTo.Text == string.Empty)
                    {
                        cmd.Parameters.AddWithValue("@DateFrom", datepicker_dateFrom.Text).Value = DBNull.Value;
                        cmd.Parameters.AddWithValue("@DateTo", datepicker_dateTo.Text).Value = DBNull.Value;
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@DateFrom", datepicker_dateFrom.Text);
                        cmd.Parameters.AddWithValue("@DateTo", datepicker_dateTo.Text);
                    }

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable("StockTakeHeader");
                    sda.Fill(dt);
                    grdStockTakeHeader.ItemsSource = dt.DefaultView;
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void FillDataGrid_StockTakeLines(int HeaderId)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpStockTakeLines_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@HeaderId", HeaderId);                    

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable("StockTakeLines");
                    sda.Fill(dt);
                    grdStockTakeLines.ItemsSource = dt.DefaultView;
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void Btn_CountStock_Click(object sender, RoutedEventArgs e)
        {
            StockTake_CountStock stockTake_Count = new StockTake_CountStock();
            stockTake_Count.ShowDialog();
            FillDataGrid_StockTakeHeader();
            FillDataGrid_StockTakeLines(0);
        }

        private void Datepicker_dateFrom_KeyUp(object sender, KeyEventArgs e)
        {

        }

        private void Datepicker_dateTo_KeyUp(object sender, KeyEventArgs e)
        {

        }

        private void Datepicker_dateFrom_CalendarClosed(object sender, RoutedEventArgs e)
        {
            FillDataGrid_StockTakeHeader();
            FillDataGrid_StockTakeLines(0);
        }

        private void Datepicker_dateTo_CalendarClosed(object sender, RoutedEventArgs e)
        {
            FillDataGrid_StockTakeHeader();
            FillDataGrid_StockTakeLines(0);
        }

        private void GrdStockTakeHeader_PreviewMouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            DataRowView dataRow = (DataRowView)grdStockTakeHeader.SelectedItem;

            if (dataRow != null)
            {                
                string cellValue = dataRow.Row.ItemArray[0].ToString();

                FillDataGrid_StockTakeLines(Int32.Parse(cellValue));
            }
            
        }

        private void Btn_PrintStockTakeSheet_Click(object sender, RoutedEventArgs e)
        {

        }
    }
}
