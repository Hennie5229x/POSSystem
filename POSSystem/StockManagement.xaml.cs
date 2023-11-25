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
using Microsoft.Win32;
using ClosedXML.Excel;

namespace POSSystem
{
    /// <summary>
    /// Interaction logic for StockManagement.xaml
    /// </summary>
    public partial class StockManagement : Window
    {
        public StockManagement()
        {
            InitializeComponent();

            SupplierLookupFill();
            VatLookupFill();
            ItemGroupLookupFill();

            FillDataGrid();
            
        }

        public void FillDataGrid()
        {
            try
            {
                string Supplier;
                string Vat;
                string ItemGroup;

                if (cbx_Supplier.SelectedItem.ToString().Equals("All"))
                {
                    Supplier = "";
                }
                else
                {
                    Supplier = cbx_Supplier.SelectedItem.ToString();
                }
                if(cbx_Vat.SelectedItem.ToString().Equals("All"))
                {
                    Vat = "";
                }
                else
                {
                    Vat = cbx_Vat.SelectedItem.ToString();
                }
                if (cbx_ItmGroup.SelectedItem.ToString().Equals("All"))
                {
                    ItemGroup = "";
                }
                else
                {
                    ItemGroup = cbx_ItmGroup.SelectedItem.ToString();
                }

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpItemMaster_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ItemCode", tbx_ItemCode.Text);
                    cmd.Parameters.AddWithValue("@ItemName", tbx_ItemName.Text);
                    cmd.Parameters.AddWithValue("@Barcode", tbx_Barcode.Text);
                    cmd.Parameters.AddWithValue("@Supplier", Supplier);
                    cmd.Parameters.AddWithValue("@Vat", Vat);
                    cmd.Parameters.AddWithValue("@ItemGroup", ItemGroup);

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable("ItemMaster");
                    sda.Fill(dt);
                    grdItems.ItemsSource = dt.DefaultView;
                }

        }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
}

        private void SupplierLookupFill()
        {

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("lkpItemMaster_Suppliers", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        cbx_Supplier.Items.Add(reader["Supplier"].ToString());
                    }

                    con.Close();

                    cbx_Supplier.SelectedItem = "All";
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }
        private void VatLookupFill()
        {

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("lkpItemMaster_Vat", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        cbx_Vat.Items.Add(reader["Vat"].ToString());
                    }

                    con.Close();

                    cbx_Vat.SelectedItem = "All";

                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }
        private void ItemGroupLookupFill()
        {

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("lkpItemMaster_ItemGroups", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        cbx_ItmGroup.Items.Add(reader["GroupName"].ToString());
                    }

                    con.Close();

                    cbx_ItmGroup.SelectedItem = "All";
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void Tbx_ItemCode_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Tbx_ItemName_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Tbx_Barcode_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Cbx_Supplier_DropDownClosed(object sender, EventArgs e)
        {
            FillDataGrid();
        }

        private void Cbx_Vat_DropDownClosed(object sender, EventArgs e)
        {
            FillDataGrid();
        }

        private void Btn_AddItem_Click(object sender, RoutedEventArgs e)
        {
            StockManagement_AddItem stockManagement_AddItem = new StockManagement_AddItem();
            stockManagement_AddItem.ShowDialog();
            FillDataGrid();
        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            //Update
            DataRowView dataRow = (DataRowView)grdItems.SelectedItem;

            if (dataRow != null)
            {                
                int cellValue = Int32.Parse(dataRow.Row.ItemArray[0].ToString());

                StockManagement_UpdateItem stockManagement_UpdateItem = new StockManagement_UpdateItem(cellValue);
                stockManagement_UpdateItem.ShowDialog();
                FillDataGrid();
            }
        }

        private void Cbx_ItmGroup_DropDownClosed(object sender, EventArgs e)
        {
            FillDataGrid();
        }

        private static void ExportDataSet(DataSet ds, string destination)
        {
            var workbook = new ClosedXML.Excel.XLWorkbook();
            foreach (DataTable dt in ds.Tables)
            {
                var worksheet = workbook.Worksheets.Add(dt.TableName);
                worksheet.Cell(1, 1).InsertTable(dt);
                worksheet.Columns().AdjustToContents();
                worksheet.Tables.FirstOrDefault().Theme = XLTableTheme.None;
                worksheet.Tables.FirstOrDefault().ShowAutoFilter = false;
            }

            workbook.SaveAs(destination);
            workbook.Dispose();
        }


        private void MenuItem_Click_1(object sender, RoutedEventArgs e)
        {
            //Export
            try
            {
                string Supplier;
                string Vat;
                string ItemGroup;

                if (cbx_Supplier.SelectedItem.ToString().Equals("All"))
                {
                    Supplier = "";
                }
                else
                {
                    Supplier = cbx_Supplier.SelectedItem.ToString();
                }
                if (cbx_Vat.SelectedItem.ToString().Equals("All"))
                {
                    Vat = "";
                }
                else
                {
                    Vat = cbx_Vat.SelectedItem.ToString();
                }
                if (cbx_ItmGroup.SelectedItem.ToString().Equals("All"))
                {
                    ItemGroup = "";
                }
                else
                {
                    ItemGroup = cbx_ItmGroup.SelectedItem.ToString();
                }

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpItemMaster_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ItemCode", tbx_ItemCode.Text);
                    cmd.Parameters.AddWithValue("@ItemName", tbx_ItemName.Text);
                    cmd.Parameters.AddWithValue("@Barcode", tbx_Barcode.Text);
                    cmd.Parameters.AddWithValue("@Supplier", Supplier);
                    cmd.Parameters.AddWithValue("@Vat", Vat);
                    cmd.Parameters.AddWithValue("@ItemGroup", ItemGroup);

                    DataSet ds1 = new DataSet("ItemMaster_DataSet");

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable("ItemMaster");
                    sda.Fill(dt);
                    ds1.Tables.Add(dt);

                    string filename = "ItemMaster " + DateTime.Now.ToString("MM-dd-yyyy");
                    SaveFileDialog saveFileDialog = new SaveFileDialog();
                    saveFileDialog.Filter = "Excel Workbook (*.xlsx)|*.xlsx";
                    saveFileDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
                    saveFileDialog.FileName = filename;
                                                           

                    Nullable<bool> result = saveFileDialog.ShowDialog();
                    if (result == true)
                    {
                        string directory = saveFileDialog.InitialDirectory.ToString() + "/" + saveFileDialog.SafeFileName + "";
                        if (!directory.Equals(string.Empty) || directory != null)
                        {
                            ExportDataSet(ds1, directory);
                        }
                    }

                }

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error");
            }

        }
    }
}
