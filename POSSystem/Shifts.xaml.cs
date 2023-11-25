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
    public partial class Shifts : Window
    {
        public Shifts()
        {
            InitializeComponent();
            FillDataGrid();
        }

        private string GetUserName(string UserId)
        {
            string UserName = null;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcUserName", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UserId", UserId);

                    SqlDataReader reader = cmd.ExecuteReader();



                    while (reader.Read())
                    {
                        UserName = reader["UserName"].ToString();
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return UserName;
        }
        public void FillDataGrid()
        {
            string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(ConString))
            {
                SqlCommand cmd = new SqlCommand("stpShifts_Select", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserName", tbx_UserName.Text);
                cmd.Parameters.AddWithValue("@StartDate", DateStart.SelectedDate);
                cmd.Parameters.AddWithValue("@EndDate", DateEnd.SelectedDate);

                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable("Shifts");
                sda.Fill(dt);
                grdShifts.ItemsSource = dt.DefaultView;
            }
        }

        private void btn_NewShift_Click(object sender, RoutedEventArgs e)
        {
            //New Shift
            Shifts_New shifts_New = new Shifts_New();
            shifts_New.ShowDialog();
            FillDataGrid();
        }

        private void EndShift(int Id)
        {
            try
                {
                    string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                    using (SqlConnection con = new SqlConnection(ConString))
                    {
                        con.Open();

                        SqlCommand cmd = new SqlCommand("stpShifts_End", con);

                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.AddWithValue("Id", Id);                        

                        cmd.ExecuteNonQuery();

                        con.Close();

                        
                    }

                }
                catch (Exception e)
                {
                    MessageBox.Show(e.Message, "Error");
                }

        }
        

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            string UserName = ""; 
            int Id = 0;

            DataRowView dataRow = (DataRowView)grdShifts.SelectedItem;

            if (dataRow != null)
            {
                UserName = dataRow.Row.ItemArray[1].ToString();  
                Id = Int32.Parse(dataRow.Row.ItemArray[0].ToString());
            }

            //End Shift
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to end this shift for "+ UserName + "?", "Cancel Confirmation", System.Windows.MessageBoxButton.YesNo);

            if (messageBoxResult == MessageBoxResult.Yes)
            {
                EndShift(Id);
                FillDataGrid();
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

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            //Sales
            DataRowView dataRow = (DataRowView)grdShifts.SelectedItem;
            int Id = 0;

            if (dataRow != null)
            {
                Id = Int32.Parse(dataRow.Row.ItemArray[0].ToString());
            }

            if(Id > 0)
            {
                SalesHistory salesHistory = new SalesHistory(Id);
                salesHistory.ShowDialog();
            }

        }
    }
}
