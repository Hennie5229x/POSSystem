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
    /// Interaction logic for StockReceive_AddStock.xaml
    /// </summary>
    public partial class StockReceive_AddStock : Window
    {
        public StockReceive_AddStock()
        {
            InitializeComponent();

            GetInvHeaders();
            GetInvTotals();
            FillDataGrid();
            LookupFillSupplier();
        }

        string Exists = null;

        private string GetItemName(int ItemId)
        {
            string ItemName = null;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcItemName", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ItemId", ItemId);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        ItemName = reader["ItemName"].ToString();
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return ItemName;
        }
        private void LookupFillSupplier()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("lkpSuppliers", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    //SqlDataReader reader = cmd.ExecuteReader();

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("Suppliers");
                    sda.Fill(dt);
                    cmbx_Supplier.ItemsSource = dt.DefaultView;

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }
        private void GetInvTotals()
        {
            string InvTotalIncl = null;
            string InvTotalExcl = null;
            string InvTotalVAT = null;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpStockReceive_Temp_Totals", con);
                    cmd.CommandType = CommandType.StoredProcedure;                    

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        InvTotalIncl = reader["PricePurchaseIncl"].ToString();
                        InvTotalExcl = reader["PricePurchaseExcl"].ToString();
                        InvTotalVAT = reader["VAT"].ToString();
                    }

                    con.Close();

                    tbx_InvTotalExcl.Text = InvTotalExcl;
                    tbx_InvTotalIncl.Text = InvTotalIncl;
                    tbx_InvVat.Text = InvTotalVAT;
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }           
        }
        private void GetInvHeaders()
        {
            string Supplier = null;
            string InvoiceNum = null;
            string ReceiveDate = null;
            
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpStockReceive_Temp_Header", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Supplier = reader["SupplierId"].ToString();
                        InvoiceNum = reader["InvoiceNum"].ToString();
                        ReceiveDate = reader["ReceiveDate"].ToString();
                        Exists = reader["Exists"].ToString();
                    }

                    con.Close();

                    int SupplierId;
                    if (Int32.TryParse(Supplier, out SupplierId))
                    {
                        cmbx_Supplier.SelectedValue = SupplierId;
                    }                    
                    tbx_Invoice.Text = InvoiceNum;
                    tbx_Date.Text = ReceiveDate;

                    if (Exists == "1")
                    {
                        cmbx_Supplier.IsEnabled = false;
                        tbx_Invoice.Background = System.Windows.Media.Brushes.LightGray;
                        tbx_Invoice.IsReadOnly = true;                        
                    }

                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }
        private void GetItemDetails()
        {
            string UoM = null;
            string PriceSell = null;
            
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpStockReceive_Temp_ItemDetail", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ItemId", PublicVariables.StockM_Cmp_ItemId);
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        UoM = reader["UoM"].ToString();
                        PriceSell = reader["PriceSellIncl"].ToString();                      
                    }

                    con.Close();

                    tbx_UoM.Text = UoM;
                    tbx_PriceSellIncl.Text = PriceSell;
                   
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        public void FillDataGrid()
        {
            try
            {

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpStockReceive_Temp_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;                    

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable("StockReceiveTmp");
                    sda.Fill(dt);
                    grdStockReceiveTmp.ItemsSource = dt.DefaultView;
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void AddStock()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpStockReceive_Temp_Insert", con);

                    cmd.CommandType = CommandType.StoredProcedure;                    

                    if(cmbx_Supplier.SelectedValue == null)
                    {
                        cmd.Parameters.AddWithValue("@SupplierId", cmbx_Supplier.SelectedValue).Value = DBNull.Value;
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@SupplierId", cmbx_Supplier.SelectedValue);
                    }
                    if(tbx_Invoice.Text == null || tbx_Invoice.Text == string.Empty)
                    {
                        cmd.Parameters.AddWithValue("@InvoiceNum", tbx_Invoice.Text).Value = DBNull.Value;
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@InvoiceNum", tbx_Invoice.Text);
                    }

                    cmd.Parameters.AddWithValue("@ItemId", PublicVariables.StockM_Cmp_ItemId);
                    cmd.Parameters.AddWithValue("@QuantityReceived", tbx_QuantityReceiving.Text);
                    cmd.Parameters.AddWithValue("@PricePurchaseExcl", tbx_PricePurchaseExcl.Text);
                    cmd.Parameters.AddWithValue("@PricePurchaseIncl", tbx_PricePurchaseIncl.Text);                    
                    cmd.Parameters.AddWithValue("@ReceivedByUserId", UserId.User_Id);
                    cmd.Parameters.AddWithValue("@ReceiveDate", tbx_Date.Text);

                    cmd.ExecuteNonQuery();

                    con.Close();                    
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void RemoveStockTmpItem(int Id)
        {
            try
            {               
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpStockReceive_Tmp_Delete", con);

                    cmd.CommandType = CommandType.StoredProcedure;
                    
                    cmd.Parameters.AddWithValue("@Id", Id);

                    cmd.ExecuteNonQuery();

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void SaveStockTmp()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpStockReceive_Tmp_Save", con);

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
        private void CancelStockTmp()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpStockReceive_Tmp_Cancel", con);

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
        private decimal TaxCodeVATValue()
        {
            decimal Vat = 0;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcItemMaster_Tax", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ItemId", PublicVariables.StockM_Cmp_ItemId);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Vat = Decimal.Parse(reader["VAT"].ToString());
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return Vat;
        }

        private void PricePurchaseIncl()
        {
            if (tbx_PricePurchaseIncl.Text != string.Empty && tbx_Item.Text != string.Empty && tbx_Item.Text != null)
            {
                decimal PricePurchaseIncl;
                decimal Vat = TaxCodeVATValue();
                decimal PricePurchaseExcl;

                if ((Decimal.TryParse(tbx_PricePurchaseIncl.Text, out PricePurchaseIncl)))
                {
                    PricePurchaseExcl = PricePurchaseIncl - Math.Round((Vat / 100 * PricePurchaseIncl), 2);
                    tbx_PricePurchaseExcl.Text = PricePurchaseExcl.ToString();
                }
                else
                {
                    tbx_PricePurchaseExcl.Text = string.Empty;
                }
            }
        }
        private void PricePurchaseExcl()
        {
            if (tbx_PricePurchaseExcl.Text != string.Empty && tbx_Item.Text != string.Empty && tbx_Item.Text != null)
            {
                decimal PricePurchaseExcl;
                decimal Vat = TaxCodeVATValue();
                decimal PricePurchaseIncl;

                if ((Decimal.TryParse(tbx_PricePurchaseExcl.Text, out PricePurchaseExcl)))
                {
                    PricePurchaseIncl = PricePurchaseExcl + Math.Round((Vat / 100 * PricePurchaseExcl), 2);
                    tbx_PricePurchaseIncl.Text = PricePurchaseIncl.ToString();
                }
                else
                {
                    tbx_PricePurchaseIncl.Text = string.Empty;
                }
            }
        }
        

        //ItemCode Lookup
        private void Tbx_LoginName_PreviewMouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            LookUp_ItemMaster_Items lookUp_ItemMaster_Items = new LookUp_ItemMaster_Items();
            lookUp_ItemMaster_Items.ShowDialog();
            tbx_Item.Text=  GetItemName(PublicVariables.StockM_Cmp_ItemId);
            GetItemDetails();
        }

        private void Cmbx_Supplier_DropDownClosed(object sender, EventArgs e)
        {

        }

        private void Tbx_QuantityReceiving_KeyUp(object sender, KeyEventArgs e)
        {

        }

        private void Tbx_PricePurchaseExcl_KeyUp(object sender, KeyEventArgs e)
        {
            PricePurchaseExcl();
        }

        private void Tbx_PricePurchaseIncl_KeyUp(object sender, KeyEventArgs e)
        {
            PricePurchaseIncl();
        }

        private void BtnAddStock_Click(object sender, RoutedEventArgs e)
        {
            if(tbx_Item.Text == null || tbx_Item.Text == string.Empty)
            {
                MessageBox.Show("Item field required", "Error");
            }
            else if(tbx_QuantityReceiving.Text == null || tbx_QuantityReceiving.Text == string.Empty)
            {
                MessageBox.Show("Quantity Receiving field required", "Error");
            }
            else if(tbx_PricePurchaseExcl.Text == null || tbx_PricePurchaseExcl.Text == string.Empty)
            {
                MessageBox.Show("Price Purchase Excl field required", "Error");
            }
            else if (tbx_PricePurchaseIncl.Text == null || tbx_PricePurchaseIncl.Text == string.Empty)
            {
                MessageBox.Show("Price Purchase Incl field required", "Error");
            }
            else
            {
                AddStock();

                GetInvTotals();

                tbx_Item.Text = null;
                tbx_UoM.Text = null;
                tbx_QuantityReceiving.Text = null;
                tbx_PricePurchaseExcl.Text = null;
                tbx_PricePurchaseIncl.Text = null;
                tbx_PriceSellIncl.Text = null;

                FillDataGrid();

                cmbx_Supplier.IsEnabled = false;
                tbx_Invoice.Background = System.Windows.Media.Brushes.LightGray;
                tbx_Invoice.IsReadOnly = true;

            }
            
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            //Update
            DataRowView dataRow = (DataRowView)grdStockReceiveTmp.SelectedItem;

            if (dataRow != null)
            {
                int cellValue = Int32.Parse(dataRow.Row.ItemArray[0].ToString());

                StockReceive_AddStock_UpdateItem stockReceive_AddStock_UpdateItem = new StockReceive_AddStock_UpdateItem(cellValue);
                stockReceive_AddStock_UpdateItem.ShowDialog();
                FillDataGrid();
                GetInvTotals();
            }
            
        }

        private void MenuItem_Click_1(object sender, RoutedEventArgs e)
        {
            //Delete
            DataRowView dataRow = (DataRowView)grdStockReceiveTmp.SelectedItem;

            if (dataRow != null)
            {
                int cellValue = Int32.Parse(dataRow.Row.ItemArray[0].ToString());
               
                MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to remove selected Item?", "Delete Confirmation", System.Windows.MessageBoxButton.YesNo);

                if (messageBoxResult == MessageBoxResult.Yes)
                {
                    RemoveStockTmpItem(cellValue);
                    FillDataGrid();
                    GetInvTotals();
                }

            }
        }

        private void BtnSaveStock_Click(object sender, RoutedEventArgs e)
        {
            //Save Stock
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to save ?", "Save Confirmation", System.Windows.MessageBoxButton.YesNo);

            if (messageBoxResult == MessageBoxResult.Yes)
            {
                SaveStockTmp();
            }

        }

        private void BtnCancelStock_Click(object sender, RoutedEventArgs e)
        {
            //Cancel Stock
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to cancel ?", "Cancel Confirmation", System.Windows.MessageBoxButton.YesNo);

            if (messageBoxResult == MessageBoxResult.Yes)
            {
                CancelStockTmp();
            }
        }
    }
}
