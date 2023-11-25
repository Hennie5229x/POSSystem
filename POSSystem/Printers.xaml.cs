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
using POSSystem;

namespace POSSystem_Manager
{
    /// <summary>
    /// Interaction logic for Printers.xaml
    /// </summary>
    public partial class Printers : Window
    {
        public Printers()
        {
            InitializeComponent();

            FillDataGrid();

        }

        private void FillDataGrid()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpPrinters_Select", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("Printers");
                    sda.Fill(dt);
                    grdPrinters.ItemsSource = dt.DefaultView;
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void RemoveItemGroups(int Id)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPrinters_Delete", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", Id);
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

        private void Btn_AddPrinter_Click(object sender, RoutedEventArgs e)
        {
            //Add
            Printers_Add printers_Add = new Printers_Add();
            printers_Add.ShowDialog();
            this.FillDataGrid();
        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            //Update
            DataRowView dataRow = (DataRowView)grdPrinters.SelectedItem;

            if (dataRow != null)
            {
                string cellValue = dataRow.Row.ItemArray[0].ToString();

                Printers_Update printers_Update = new Printers_Update(Int32.Parse(cellValue));
                printers_Update.ShowDialog();
                this.FillDataGrid();
            }

           
        }

        private void MenuItem_Click_1(object sender, RoutedEventArgs e)
        {
            //Delete
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to remove selected Printer?", "Delete Confirmation", System.Windows.MessageBoxButton.YesNo);
            if (messageBoxResult == MessageBoxResult.Yes)
            {
                DataRowView dataRow = (DataRowView)grdPrinters.SelectedItem;

                if (dataRow != null)
                {
                    string cellValue = dataRow.Row.ItemArray[0].ToString();

                    RemoveItemGroups(Int32.Parse(cellValue));
                    FillDataGrid();
                }


            }
        }
    }
}
