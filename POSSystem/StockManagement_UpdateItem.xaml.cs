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
using System.Windows.Forms;

namespace POSSystem
{
    /// <summary>
    /// Interaction logic for StockManagement_UpdateItem.xaml
    /// </summary>
    public partial class StockManagement_UpdateItem : Window
    {
        public StockManagement_UpdateItem(int Id)
        {
            InitializeComponent();
            HeaderId = Id;

            FillCompoundItemGrid();

            LookupFillUoM();
            LookupFillSupplier();
            LookupFillTaxCode();
            LookupFillItemGroups();

            LookupFillButtonFonts();
            ItemButtons_Load_Defaults();

            ItemMasterValues();

            //Validations
            Validation_Empty_ComboBox(cmbx_ItemGroup, Border_ItemGroupCmbx);
            Validation_Empty_ComboBox(cmbx_Supplier, Border_SupplierCmbx);
            Validation_Empty_ComboBox(Cmbx_TaxCode, Border_TaxCodeCmbx);
            Validation_Empty_ComboBox(cmbx_UoM, Border_UoMCmbx);

            Validation_Numeric(tbx_DiscountPercentage);
            Validation_Numeric(tbx_PriceSellExclVat);
            Validation_Numeric(tbx_PriceSellInclVat);
        }

        private int HeaderId;
        private bool FirstTime_Open = true;

        private void LookupFillUoM()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("lkpUoM", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    //SqlDataReader reader = cmd.ExecuteReader();

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("UoM");
                    sda.Fill(dt);
                    cmbx_UoM.ItemsSource = dt.DefaultView;

                    con.Close();
                }
            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
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
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
        }
        private void LookupFillTaxCode()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("lkpTaxCodes", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    //SqlDataReader reader = cmd.ExecuteReader();

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("TaxCodes");
                    sda.Fill(dt);
                    Cmbx_TaxCode.ItemsSource = dt.DefaultView;
                    con.Close();
                }
            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
        }
        private void LookupFillItemGroups()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("lkpItemGroups", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    //SqlDataReader reader = cmd.ExecuteReader();

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("ItemCodes");
                    sda.Fill(dt);
                    cmbx_ItemGroup.ItemsSource = dt.DefaultView;
                    con.Close();
                }
            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
        }

        private void LookupFillButtonFonts()
        {
            foreach (FontFamily fontFamily in Fonts.SystemFontFamilies)
            {
                cmb_ButtonFont.Items.Add(fontFamily.Source);
                //System.Windows.MessageBox.Show(fontFamily.Source);
            }

            //System.Windows.MessageBox.Show(btnItemButtonPreview.FontFamily.ToString());

            cmb_ButtonFont.SelectedValue = tbl_buttonText.FontFamily.ToString();
        }
        private void ItemButtons_Load_Defaults()
        {
            string ButtonText = string.Empty;
            string Font = string.Empty;
            int FontSize = 1;
            string Hexa = string.Empty;

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcItemButtonValues", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ItemId", HeaderId);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        ButtonText = reader["ButtonText"].ToString();
                        Font = reader["Font"].ToString();
                        FontSize = Int32.Parse(reader["FontSize"].ToString());
                        Hexa = reader["Hex"].ToString();
                    }

                    con.Close();

                    tbx_ItemButtonText.Text = ButtonText;
                    tbl_buttonText.Text = ButtonText;
                    
                    cmb_ButtonFont.SelectedValue = Font;
                    tbl_buttonText.FontFamily = new FontFamily(Font);

                    sld_FontSize.Value = FontSize;
                    tbx_ButtonFontSize.Text = FontSize.ToString();
                    tbl_buttonText.FontSize = FontSize;

                    tbx_Hexa.Text = Hexa;
                    Color RGB = (Color)ColorConverter.ConvertFromString(Hexa);
                    btnItemButtonPreview.Background = new SolidColorBrush(Color.FromRgb(RGB.R, RGB.G, RGB.B));

                    FirstTime_Open = false;

                }
            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }



            /*
            //-- Item Buttons --//
            LookupFillButtonFonts();
            tbl_buttonText.FontSize = Int32.Parse(tbx_ButtonFontSize.Text);
            tbx_ItemButtonText.Text = tbx_ItemName.Text;
            tbl_buttonText.Text = tbx_ItemButtonText.Text;

            SolidColorBrush brush = btnItemButtonPreview.Background as SolidColorBrush;

            string hex;
            if (brush != null)
            {
                Color color = brush.Color;
                hex = "#" + color.R.ToString("X2") + color.G.ToString("X2") + color.B.ToString("X2");
                tbx_Hexa.Text = hex;
                //Color RGB = (Color)ColorConverter.ConvertFromString("#"+hex); 
                //System.Windows.MessageBox.Show(color.R + ", " + color.G + ", " + color.B);
            }

            //Color myColor = Color.FromRgb(255, 181, 178);
            //string hex = myColor.R.ToString("X2") + myColor.G.ToString("X2") + myColor.B.ToString("X2");
            //------------------///
            */
        }

        private bool Validation_Empty_ComboBox(System.Windows.Controls.ComboBox cmbx, Border border)
        {
            if (cmbx.SelectedValue == null)
            {
                border.BorderBrush = System.Windows.Media.Brushes.Red;
                cmbx.ToolTip = "Drop down must have a value selected.";

                return false;
            }
            else
            {
                border.BorderBrush = System.Windows.Media.Brushes.LightSlateGray;
                cmbx.ToolTip = "";

                return true;
            }
        }
        private bool Validation_Numeric(System.Windows.Controls.TextBox textBox)
        {
            decimal num;

            if (!Decimal.TryParse(textBox.Text, out num))
            {
                textBox.BorderBrush = System.Windows.Media.Brushes.Red;

                textBox.ToolTip = "Field value needs to be numeric.";

                return false;
            }
            else
            {
                textBox.BorderBrush = System.Windows.Media.Brushes.LightSlateGray;
                textBox.ToolTip = "";

                return true;
            }
        }        

        private decimal TaxCodeVATValue(string Id)
        {
            decimal Vat = 0;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcVatValue", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@TaxCodeId", Id);

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
                System.Windows.MessageBox.Show(e.Message, "Error");
            }

            return Vat;
        }

        private void FillCompoundItemGrid()
        {
            try
            {

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpItemMasterCompounds_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", HeaderId);

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable("ItemMaster");
                    sda.Fill(dt);
                    grdCompoundItems.ItemsSource = dt.DefaultView;
                }

            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
        }

        private void ItemMasterValues()
        {
            //Variables
            string  ItemCode = "",
                    ItemName = "",
                    ItemGroupId = null,
                    UoMId = null,
                    TaxCode = null,
                    Active = "",
                    SupplierId = null,
                    Barcode = "",
                    PriceSellExclVat = "",
                    PriceSellInclVat = "",
                    DiscountPercentage = "",
                    FinalPrice = "",
                    QuantityRequestMin = "",
                    QuantityRequestMax = "";
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcItemMaster_Values", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Id", HeaderId);
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        ItemCode = reader["ItemCode"].ToString();
                        ItemName = reader["ItemName"].ToString();
                        ItemGroupId = reader["ItemGroupId"].ToString();
                        UoMId = reader["UoMId"].ToString();
                        TaxCode = reader["TaxCode"].ToString();
                        Active = reader["Active"].ToString();
                        SupplierId = reader["SupplierId"].ToString();
                        Barcode = reader["Barcode"].ToString();
                        PriceSellExclVat = reader["PriceSellExclVat"].ToString();
                        PriceSellInclVat = reader["PriceSellInclVat"].ToString();
                        DiscountPercentage = reader["DiscountPercentage"].ToString();
                        FinalPrice = reader["FinalPrice"].ToString();
                        QuantityRequestMin = reader["QuantityRequestMin"].ToString();
                        QuantityRequestMax = reader["QuantityRequestMax"].ToString();
                    }

                    
                    tbx_ItemCode.Text = ItemCode;
                    tbx_ItemName.Text = ItemName;                    
                    tbx_Barcode.Text = Barcode;
                    tbx_PriceSellExclVat.Text = PriceSellExclVat;
                    tbx_PriceSellInclVat.Text = PriceSellInclVat;
                    tbx_DiscountPercentage.Text = DiscountPercentage;
                    tbx_DiscountedPriceIncl.Text = FinalPrice;
                    tbx_QtyRequestMin.Text = QuantityRequestMin;
                    tbx_QtyRequestMax.Text = QuantityRequestMax;

                    if (Active == "True")
                    {
                        cbx_Active.IsChecked = true;
                    } else
                    {
                        cbx_Active.IsChecked = false;
                    }
                    if(ItemGroupId != null)
                    {
                        cmbx_ItemGroup.SelectedValue = Int32.Parse(ItemGroupId);
                    }
                    if(UoMId != null)
                    {
                        cmbx_UoM.SelectedValue = Int32.Parse(UoMId);
                    }
                    if(TaxCode != null)
                    {
                        Cmbx_TaxCode.SelectedValue = Int32.Parse(TaxCode);
                    }
                    if(SupplierId != null)
                    {
                        cmbx_Supplier.SelectedValue = Int32.Parse(SupplierId);
                    }

                    con.Close();

                }
            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
        }

        private void UpdateItem()
        {

            try
            {
                string qtyMin = null;
                string qtyMax = null;
               
                if (tbx_QtyRequestMin.Text != string.Empty)
                {
                    qtyMin = tbx_QtyRequestMin.Text;
                }
                if (tbx_QtyRequestMax.Text != string.Empty)
                {
                    qtyMax = tbx_QtyRequestMax.Text;
                }

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpItemMaster_Update", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", HeaderId);
                    cmd.Parameters.AddWithValue("@ItemCode", tbx_ItemCode.Text);
                    cmd.Parameters.AddWithValue("@ItemName", tbx_ItemName.Text);
                    cmd.Parameters.AddWithValue("@QuantityRequestMin", qtyMin);  //.Value = DBNull.Value;
                    cmd.Parameters.AddWithValue("@QuantityRequestMax", qtyMax);  //.Value = DBNull.Value;
                    cmd.Parameters.AddWithValue("@PriceSellExclVat", Decimal.Parse(tbx_PriceSellExclVat.Text));                    
                    cmd.Parameters.AddWithValue("@DiscountPercentage", Decimal.Parse(tbx_DiscountPercentage.Text));
                    cmd.Parameters.AddWithValue("@DiscountedPriceIncl", Decimal.Parse(tbx_DiscountedPriceIncl.Text));                   
                    cmd.Parameters.AddWithValue("@Active", cbx_Active.IsChecked.Value);
                    cmd.Parameters.AddWithValue("@Barcode", tbx_Barcode.Text);
                    cmd.Parameters.AddWithValue("@SupplierId", cmbx_Supplier.SelectedValue);
                    cmd.Parameters.AddWithValue("@TaxCode", Cmbx_TaxCode.SelectedValue);
                    cmd.Parameters.AddWithValue("@LoggedInUserId", UserId.User_Id);
                    cmd.Parameters.AddWithValue("@UoM", cmbx_UoM.SelectedValue);
                    cmd.Parameters.AddWithValue("@ItemGroupId", cmbx_ItemGroup.SelectedValue);

                    cmd.ExecuteNonQuery();

                    con.Close();
                    
                    this.Close();

                }
            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
        }

        private void UpdateItemButton()
        {

            try
            {                
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpItemButton_Update", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ItemId", HeaderId);
                    cmd.Parameters.AddWithValue("@ButtonText", tbx_ItemButtonText.Text);
                    cmd.Parameters.AddWithValue("@Font", cmb_ButtonFont.SelectedValue);
                    cmd.Parameters.AddWithValue("@FontSize", Int32.Parse(tbx_ButtonFontSize.Text));
                    cmd.Parameters.AddWithValue("@Hex", tbx_Hexa.Text);

                    cmd.ExecuteNonQuery();

                    con.Close();

                    this.Close();
                }
            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
        }

        private void RemoveItemCompound(int ItemId)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpItemMasterCompounds_Delete", con);

                    cmd.CommandType = CommandType.StoredProcedure;
                    
                    cmd.Parameters.AddWithValue("@Id", ItemId);

                    cmd.ExecuteNonQuery();

                    con.Close();
                }

            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
        }

        private void PriceSell_Incl()
        {
            if (tbx_PriceSellExclVat.Text != string.Empty && Cmbx_TaxCode.SelectedValue != null)
            {
                decimal PriceSellExcl;
                decimal PriceSellIncl;
                decimal DiscoundPercentage;
                decimal FinalPrice;
                decimal Vat = TaxCodeVATValue(Cmbx_TaxCode.SelectedValue.ToString());

                if ((Decimal.TryParse(tbx_PriceSellExclVat.Text, out PriceSellExcl)) && Decimal.TryParse(tbx_DiscountPercentage.Text, out DiscoundPercentage))
                {
                    PriceSellIncl = PriceSellExcl + Math.Round((Vat / 100 * PriceSellExcl), 2);
                    FinalPrice = PriceSellIncl - Math.Round((DiscoundPercentage / 100 * PriceSellIncl), 2);

                    tbx_PriceSellInclVat.Text = PriceSellIncl.ToString();
                    //Final Sell Price
                    tbx_DiscountedPriceIncl.Text = FinalPrice.ToString();
                }
                else
                {
                    tbx_PriceSellInclVat.Text = string.Empty;
                    tbx_DiscountedPriceIncl.Text = string.Empty;
                }
            }
        }
        private void PriceSell_Excl()
        {
            if (tbx_PriceSellInclVat.Text != string.Empty && Cmbx_TaxCode.SelectedValue != null)
            {
                decimal PriceSellExcl;
                decimal PriceSellIncl;
                decimal DiscoundPercentage;
                decimal FinalPrice;
                decimal Vat = TaxCodeVATValue(Cmbx_TaxCode.SelectedValue.ToString());

                if ((Decimal.TryParse(tbx_PriceSellInclVat.Text, out PriceSellIncl)) && Decimal.TryParse(tbx_DiscountPercentage.Text, out DiscoundPercentage))
                {
                    PriceSellExcl = PriceSellIncl - Math.Round((Vat / 100 * PriceSellIncl), 2);
                    FinalPrice = PriceSellIncl - Math.Round((DiscoundPercentage / 100 * PriceSellIncl), 2);

                    tbx_PriceSellExclVat.Text = PriceSellExcl.ToString();
                    //Final Sell Price
                    tbx_DiscountedPriceIncl.Text = FinalPrice.ToString();
                }
                else
                {
                    tbx_PriceSellExclVat.Text = string.Empty;
                    tbx_DiscountedPriceIncl.Text = string.Empty;
                }
            }
        }
        private void DiscountFinalPrice()
        {
            if (tbx_PriceSellInclVat.Text != string.Empty && tbx_DiscountPercentage.Text != string.Empty)
            {
                decimal DiscoundPercentage;
                decimal PriceSellIncl;
                decimal FinalPrice;

                if ((Decimal.TryParse(tbx_PriceSellInclVat.Text, out PriceSellIncl)) && (Decimal.TryParse(tbx_DiscountPercentage.Text, out DiscoundPercentage)))
                {
                    FinalPrice = PriceSellIncl - Math.Round((DiscoundPercentage / 100 * PriceSellIncl), 2);

                    tbx_DiscountedPriceIncl.Text = FinalPrice.ToString();
                }

            }
        }

        private void Cmbx_ItemGroup_DropDownClosed(object sender, EventArgs e)
        {
            Validation_Empty_ComboBox(cmbx_ItemGroup, Border_ItemGroupCmbx);
        }

        private void Cmbx_UoM_DropDownClosed(object sender, EventArgs e)
        {
            Validation_Empty_ComboBox(Cmbx_TaxCode, Border_TaxCodeCmbx);
        }

        private void Cmbx_TaxCode_DropDownClosed(object sender, EventArgs e)
        {
            Validation_Empty_ComboBox(Cmbx_TaxCode, Border_TaxCodeCmbx);
        }

        private void Cmbx_Supplier_DropDownClosed(object sender, EventArgs e)
        {
            Validation_Empty_ComboBox(cmbx_Supplier, Border_SupplierCmbx);
        }

        private void Tbx_Barcode_KeyUp(object sender, System.Windows.Input.KeyEventArgs e)
        {

        }

        private void Tbx_PriceSellExclVat_KeyUp(object sender, System.Windows.Input.KeyEventArgs e)
        {
            Validation_Numeric(tbx_PriceSellExclVat);           
            PriceSell_Incl();           
        }

        private void Tbx_PriceSellInclVat_KeyUp(object sender, System.Windows.Input.KeyEventArgs e)
        {
            Validation_Numeric(tbx_PriceSellInclVat);           
            PriceSell_Excl();
        }

        private void Tbx_DiscountPercentage_KeyUp(object sender, System.Windows.Input.KeyEventArgs e)
        {
            Validation_Numeric(tbx_DiscountPercentage);
            DiscountFinalPrice();
        }

        private void BtnAddCompoundItem_Click(object sender, RoutedEventArgs e)
        {
            //Add Compount Item
            StockManagement_AddCompoundItem stockManagement_AddCompoundItem = new StockManagement_AddCompoundItem(HeaderId);
            stockManagement_AddCompoundItem.ShowDialog();
            FillCompoundItemGrid();
        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            //Update Compound Item            
            DataRowView dataRow = (DataRowView)grdCompoundItems.SelectedItem;

            if (dataRow != null)
            {
                string cellValue = dataRow.Row.ItemArray[0].ToString();

                StockManagement_UpdateCompoundItem stockManagement_UpdateCompoundItem = new StockManagement_UpdateCompoundItem(Int32.Parse(cellValue));
                stockManagement_UpdateCompoundItem.ShowDialog();
                FillCompoundItemGrid();
            }
        }

        private void BtnAddItem_Click(object sender, RoutedEventArgs e)
        {
            if (!Validation_Empty_ComboBox(cmbx_ItemGroup, Border_ItemGroupCmbx) || !Validation_Empty_ComboBox(cmbx_Supplier, Border_SupplierCmbx) || !Validation_Empty_ComboBox(Cmbx_TaxCode, Border_TaxCodeCmbx)
               || !Validation_Empty_ComboBox(cmbx_UoM, Border_UoMCmbx) || !Validation_Numeric(tbx_DiscountPercentage) || !Validation_Numeric(tbx_PriceSellExclVat) || !Validation_Numeric(tbx_PriceSellInclVat)
               )
            {
                System.Windows.MessageBox.Show("Fill in all required fields.", "Error");
            }
            else
            {
                UpdateItem();
                UpdateItemButton();
            }
                  
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void MenuItem_Click_1(object sender, RoutedEventArgs e)
        {
            //Remove Item Compound
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to remove selected item?", "Delete Confirmation", System.Windows.MessageBoxButton.YesNo);
            if (messageBoxResult == MessageBoxResult.Yes)
            {
                DataRowView dataRow = (DataRowView)grdCompoundItems.SelectedItem;

                if (dataRow != null)
                {
                    string cellValue = dataRow.Row.ItemArray[0].ToString();
                    RemoveItemCompound(Int32.Parse(cellValue));
                    FillCompoundItemGrid();
                }
            }
        }

        private void BtnChooseColor_Click(object sender, RoutedEventArgs e)
        {
            ColorDialog dlg = new ColorDialog();
            SolidColorBrush brush; //= btnItemButtonPreview.Background as SolidColorBrush;

            if (dlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                brush = new SolidColorBrush(Color.FromRgb(dlg.Color.R, dlg.Color.G, dlg.Color.B));
                btnItemButtonPreview.Background = brush;

                string hex;
                if (brush != null)
                {
                    Color color = brush.Color;
                    hex = "#" + color.R.ToString("X2") + color.G.ToString("X2") + color.B.ToString("X2");
                    tbx_Hexa.Text = hex;
                }
            }
        }

        private void Cmb_ButtonFont_DropDownClosed(object sender, EventArgs e)
        {
            tbl_buttonText.FontFamily = new FontFamily(cmb_ButtonFont.SelectedItem.ToString());
        }

        private void Tbx_ItemButtonText_KeyUp(object sender, System.Windows.Input.KeyEventArgs e)
        {
            tbl_buttonText.Text = tbx_ItemButtonText.Text;
        }

        private void Tbx_ButtonFontSize_KeyUp(object sender, System.Windows.Input.KeyEventArgs e)
        {
            //int Number;
            //bool success = Int32.TryParse(tbx_ButtonFontSize.Text, out Number);
            //if (success)
            //{
            //    if (Number > 1)
            //    {
            //        tbl_buttonText.FontSize = Int32.Parse(tbx_ButtonFontSize.Text);
            //    }
            //}


        }

        private void BtnResetToDefault_Click(object sender, RoutedEventArgs e)
        {
            tbx_ItemButtonText.Text = tbx_ItemName.Text;
            tbl_buttonText.Text = tbx_ItemName.Text;

            cmb_ButtonFont.SelectedValue = "Segoe UI";
            tbl_buttonText.FontFamily = new FontFamily("Segoe UI");

            tbx_ButtonFontSize.Text = "20";
            tbl_buttonText.FontSize = 20;

            //btnItemButtonPreview.Background = new SolidColorBrush(Color.FromRgb(221, 221, 221));

            SolidColorBrush brush = new SolidColorBrush(Color.FromRgb(221, 221, 221));
            btnItemButtonPreview.Background = brush;
            string hex;
            if (brush != null)
            {
                Color color = brush.Color;
                hex = "#" + color.R.ToString("X2") + color.G.ToString("X2") + color.B.ToString("X2");
                tbx_Hexa.Text = hex;
            }

        }

        private void Tbx_Hexa_KeyUp(object sender, System.Windows.Input.KeyEventArgs e)
        {
            try 
            {
                Color RGB = (Color)ColorConverter.ConvertFromString(tbx_Hexa.Text);
                btnItemButtonPreview.Background = new SolidColorBrush(Color.FromRgb(RGB.R, RGB.G, RGB.B));
            }
            catch(Exception ex)
            {
                System.Windows.MessageBox.Show(ex.Message, "Error");
            }
           
        }
               

        private void Sld_FontSize_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {

            //Console.WriteLine(Math.Floor(sld_FontSize.Value).ToString());
            
            if(!FirstTime_Open)
            {
                tbx_ButtonFontSize.Text = Math.Floor(sld_FontSize.Value).ToString();
                tbl_buttonText.FontSize = Math.Floor(sld_FontSize.Value);
            }


            //Math.Floor(sld_FontSize.Value).ToString();

            //System.Windows.MessageBox.Show(sld_FontSize.Value.ToString());
            //if (sld_FontSize.Value != null)
            //{
            //    tbx_ButtonFontSize.Text = sld_FontSize.Value.ToString();
            //}
        }

        private void Cbx_Discount_Click(object sender, RoutedEventArgs e)
        {
            
            if (cbx_Discount.IsChecked.Value)
            {
                System.Windows.MessageBox.Show("This Discount Percentage will apply accross the system!", "Warning");
                tbx_DiscountPercentage.IsReadOnly = false;
                tbx_DiscountPercentage.Background = Brushes.White;
            }
            else
            {
                tbx_DiscountPercentage.IsReadOnly = true;
                tbx_DiscountPercentage.Background = Brushes.LightGray;
            }
        }
    }
}
