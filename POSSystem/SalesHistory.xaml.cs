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


namespace POSSystem_Manager
{
    /// <summary>
    /// Interaction logic for Shifts.xaml
    /// </summary>
    public partial class SalesHistory : Window
    {
        public SalesHistory(int _shiftId = -1)
        {
            InitializeComponent();

            if(_shiftId > 0)
            {
                tbx_ShiftId.Text = _shiftId.ToString();
            }

            FillDataGrid();
        }
               
        
        public void FillDataGrid()
        {   
            string ShiftId = null;
            int number;
           
            if (int.TryParse(tbx_ShiftId.Text, out number))
            {
                ShiftId = number.ToString();
            }

            string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(ConString))
            {
                SqlCommand cmd = new SqlCommand("stpSalesHistory_Select", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ShiftId", ShiftId);
                cmd.Parameters.AddWithValue("@DocNum", tbx_DocNum.Text);
                cmd.Parameters.AddWithValue("@Date", DateStart.SelectedDate);
                cmd.Parameters.AddWithValue("@User", tbx_UserName.Text);
                cmd.Parameters.AddWithValue("@Terminal", tbx_Terminal.Text);

                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable("SalesHistory");
                sda.Fill(dt);
                grdSalesHistory.ItemsSource = dt.DefaultView;
            }
        }

        

        private void tbx_UserName_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void DateStart_SelectedDateChanged(object sender, SelectionChangedEventArgs e)
        {
            FillDataGrid();
        }

        private void tbx_DocNum_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void tbx_Terminal_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void tbx_ShiftId_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            //Items
            DataRowView dataRow = (DataRowView)grdSalesHistory.SelectedItem;
            int Id = 0;

            if (dataRow != null)
            {                
                Id = Int32.Parse(dataRow.Row.ItemArray[0].ToString());
            }

            SalesHistoryLines salesHistoryLines = new SalesHistoryLines(Id);
            salesHistoryLines.ShowDialog();
            FillDataGrid();            
        }
    }
}
