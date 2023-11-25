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
    /// Interaction logic for Suppliers.xaml
    /// </summary>
    public partial class Suppliers : Window
    {
        public Suppliers()
        {
            InitializeComponent();

            FillDataGrid();

        }

        private void FillDataGrid()
        {
            string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(ConString))
            {
                SqlCommand cmd = new SqlCommand("stpSuppliers_Select", con);

                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@SupplierName", tbx_SupplierName.Text);
                cmd.Parameters.AddWithValue("@CompanyName", tbx_CompanyName.Text);

                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable("Suppliers");
                sda.Fill(dt);
                grdSuppliers.ItemsSource = dt.DefaultView;
            }
        }

        private void DeleteSupplier(int SupId)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpSuppliers_Delete", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", SupId); 
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

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            //Update
            DataRowView dataRow = (DataRowView)grdSuppliers.SelectedItem;

            if (dataRow != null)
            {
                int index = grdSuppliers.CurrentCell.Column.DisplayIndex;
                string cellValue = dataRow.Row.ItemArray[0].ToString();

               Suppliers_Update suppliersUpdate = new Suppliers_Update(Int32.Parse(cellValue));
               suppliersUpdate.ShowDialog();
               FillDataGrid();
            }
        }

        private void MenuItem_Click_1(object sender, RoutedEventArgs e)
        {
            // Delete
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to remove selected Supplier?", "Delete Confirmation", System.Windows.MessageBoxButton.YesNo);
            if (messageBoxResult == MessageBoxResult.Yes)
            {
                DataRowView dataRow = (DataRowView)grdSuppliers.SelectedItem;

                if (dataRow != null)
                {
                    string cellValue = dataRow.Row.ItemArray[0].ToString();
                    DeleteSupplier(Int32.Parse(cellValue));
                    FillDataGrid();
                }


            }
        }

        private void Btn_AddSupplier_Click(object sender, RoutedEventArgs e)
        {
            //Add
            Suppliers_Add suppliers_Add = new Suppliers_Add();
            suppliers_Add.ShowDialog();
            FillDataGrid();
        }

        private void Tbx_SupplierName_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Tbx_CompanyName_KeyUp(object sender, KeyEventArgs e)
        {            
            FillDataGrid();
        }
    }
}
