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
using System.Collections;

namespace POSSystem
{
    /// <summary>
    /// Interaction logic for StockTake_CountStock.xaml
    /// </summary>
    public partial class StockTake_CountStock : Window
    {
        public StockTake_CountStock()
        {
            InitializeComponent();

            StockTakeTempCreatHeader();
            FillDataGrid_StockTakeTempHeader();

        }

        int HeaderId;

        private void StockTakeTempCreatHeader()
        {

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpStockTake_Temp_CreateHeader", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@UserId", UserId.User_Id);

                    cmd.ExecuteNonQuery();

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void StockTakeLinesTemp_Update(int Id, string Quantity)
        {
            decimal Qty = 0;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpStockTakeLines_Temp_Update", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", Id);

                    if(Quantity == null || Quantity == string.Empty)
                    {                       
                        cmd.Parameters.AddWithValue("@Quantity", Qty).Value = DBNull.Value;
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Quantity", Decimal.Parse(Quantity));
                    }
                    

                    cmd.ExecuteNonQuery();

                    con.Close();
                   
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void StockTakeTempCancel()
        {

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpStockTakeLines_Temp_Cancel", con);
                    cmd.CommandType = CommandType.StoredProcedure;                    

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

        private void StockTakeTempSave()
        {

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpStockTakeLines_Temp_Save", con);
                    cmd.CommandType = CommandType.StoredProcedure;

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

        private void FillDataGrid_StockTakeTempHeader()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpStockTake_Temp_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable("StockTakeTempHeader");
                    sda.Fill(dt);
                    grdStockTakeTempHeader.ItemsSource = dt.DefaultView;
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void FillDataGrid_StockTakeLinesTempHeader(int Id)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpStockTakeLines_Temp_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Id", Id);

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable("StockTakeTempLines");
                    sda.Fill(dt);
                    grdStockTakeTempLines.ItemsSource = dt.DefaultView;
                }

                //MessageBox.Show(HeaderId.ToString());
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void GrdStockTakeTempHeader_PreviewMouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            if (grdStockTakeTempLines.ItemsSource != null)
            {
                foreach (System.Data.DataRowView dr in grdStockTakeTempLines.ItemsSource)
                {
                    StockTakeLinesTemp_Update(Int32.Parse(dr.Row.ItemArray[0].ToString()), dr.Row.ItemArray[3].ToString());
                }
            }

            DataRowView dataRow = (DataRowView)grdStockTakeTempHeader.SelectedItem;

            if (dataRow != null)
            {
                string cellValue = dataRow.Row.ItemArray[0].ToString();                
                FillDataGrid_StockTakeLinesTempHeader(Int32.Parse(cellValue));
                HeaderId = Int32.Parse(cellValue);
            }
          
            FillDataGrid_StockTakeTempHeader();

        }

        private void Btn_Cancel_Click(object sender, RoutedEventArgs e)
        {
            //Cancel
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to cancel ?", "Cancel Confirmation", System.Windows.MessageBoxButton.YesNo);

            if (messageBoxResult == MessageBoxResult.Yes)
            {
                StockTakeTempCancel();
            }
           
        }

        private void Btn_Sacve_Click(object sender, RoutedEventArgs e)
        {
            //Save
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to save ?", "Save Confirmation", System.Windows.MessageBoxButton.YesNo);

            if (messageBoxResult == MessageBoxResult.Yes)
            {
                StockTakeTempSave();
            }
        }

       

        private void GrdStockTakeTempLines_SelectedCellsChanged(object sender, SelectedCellsChangedEventArgs e)
        {
            
            foreach (System.Data.DataRowView dr in grdStockTakeTempLines.ItemsSource)
            {               
                StockTakeLinesTemp_Update(Int32.Parse(dr.Row.ItemArray[0].ToString()), dr.Row.ItemArray[3].ToString());
            }
          

            grdStockTakeTempLines.BeginEdit();
            FillDataGrid_StockTakeTempHeader();

            //MessageBox.Show(HeaderId.ToString());
            //FillDataGrid_StockTakeLinesTempHeader(HeaderId);

        }

        private void GrdStockTakeTempLines_KeyUp(object sender, KeyEventArgs e)
        {
            //MessageBox.Show("Key");

            //FillDataGrid_StockTakeTempHeader();


            
        }

        private void GrdStockTakeTempLines_KeyUp_1(object sender, KeyEventArgs e)
        {

        }

        private void Btn_Refresh_Click(object sender, RoutedEventArgs e)
        {
            if (grdStockTakeTempLines.Items.Count != 0)
            {
                foreach (System.Data.DataRowView dr in grdStockTakeTempLines.ItemsSource)
                {
                    StockTakeLinesTemp_Update(Int32.Parse(dr.Row.ItemArray[0].ToString()), dr.Row.ItemArray[3].ToString());
                }

                FillDataGrid_StockTakeLinesTempHeader(HeaderId);
            }
        }
    }
}
