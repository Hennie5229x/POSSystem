using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Forms;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using System.Drawing;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;

namespace POSSystem
{
    /// <summary>
    /// Interaction logic for CompanyInfo.xaml
    /// </summary>
    public partial class CompanyInfo : Window
    {
        public CompanyInfo()
        {
            InitializeComponent();

            CompanyInfoGetValues();
        }

        FileStream fs;
        Boolean SelectedNewImage = false;
        Boolean ClearImage = false;    
        string ImageName = "";

        private void CompanyInfoGetValues()
        {

            string CompanyName = "";
            string BranchName = "";
            string BillToAddress = "";
            string ShipToAddress = "";
            string ContactPersonName = "";
            string Telephone = "";
            string CellPhone = "";
            string Email = "";
            string VATNumber = "";
            string CurrencySign = "";
            byte[] CompanyLogo = null;
            Boolean LogoIsNull = true;

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpCompanyInformation_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;                    

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        CompanyName = reader["CompanyName"].ToString();
                        BranchName = reader["BranchName"].ToString();
                        BillToAddress = reader["BillToAddress"].ToString();
                        ShipToAddress = reader["ShipToAddress"].ToString();
                        ContactPersonName = reader["ContactPersonName"].ToString();
                        Telephone = reader["Telephone"].ToString();
                        CellPhone = reader["CellPhone"].ToString();
                        Email = reader["Email"].ToString();
                        VATNumber = reader["VATNumber"].ToString();
                        CurrencySign = reader["CurrencySign"].ToString();

                        if (reader["Logo"].ToString() != null && reader["Logo"].ToString() != string.Empty)
                        {                            
                            LogoIsNull = false;
                            CompanyLogo = Convert.FromBase64String(reader["Logo"].ToString());
                            ImageName = reader["LogoImageName"].ToString();                           
                        }
                        
                    }

                    con.Close();                    

                    //Assign Values

                    tbx_CompanyName.Text = CompanyName;
                    tbx_BranchName.Text = BranchName;
                    tbx_BillToAddress.Text = BillToAddress;
                    tbx_ShipToAddress.Text = ShipToAddress;
                    tbx_ContactPerson.Text = ContactPersonName;
                    tbx_Tell.Text = Telephone;
                    tbx_Cell.Text = CellPhone;
                    tbx_Email.Text = Email;
                    tbx_VATNumber.Text = VATNumber;
                    tbx_CurrencySign.Text = CurrencySign;

                    if(!LogoIsNull)
                    {                        
                        image.Source = ByteImageConverter.ByteToImage(CompanyLogo);
                        txtblck_image.Text = ImageName;
                    }

                }
            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
        }
        
        private void CompanyInfoUpdate()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpCompanyInformation_Update", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@CompanyName", tbx_CompanyName.Text);
                    cmd.Parameters.AddWithValue("@BranchName", tbx_BranchName.Text);
                    cmd.Parameters.AddWithValue("@BillToAddress", tbx_BillToAddress.Text);
                    cmd.Parameters.AddWithValue("@ShipToAddress", tbx_ShipToAddress.Text);
                    cmd.Parameters.AddWithValue("@ContactPersonName", tbx_ContactPerson.Text);
                    cmd.Parameters.AddWithValue("@Telephone", tbx_Tell.Text);
                    cmd.Parameters.AddWithValue("@CellPhone", tbx_Cell.Text);
                    cmd.Parameters.AddWithValue("@Email", tbx_Email.Text);
                    cmd.Parameters.AddWithValue("@CurrencySign", tbx_CurrencySign.Text);
                    cmd.Parameters.AddWithValue("@VATNumber", tbx_VATNumber.Text);

                    if(ClearImage)
                    {
                        cmd.Parameters.AddWithValue("@ClearImage", true);
                        cmd.Parameters.AddWithValue("@NewImage", false);
                        cmd.Parameters.AddWithValue("@CompanyLogo", "").Value = DBNull.Value;
                        cmd.Parameters.AddWithValue("@LogoImageName", "").Value = DBNull.Value;                      
                    }
                    else if (!SelectedNewImage)
                    {
                        cmd.Parameters.AddWithValue("@ClearImage", false);
                        cmd.Parameters.AddWithValue("@NewImage", false);
                        cmd.Parameters.AddWithValue("@CompanyLogo", "").Value = DBNull.Value;
                        cmd.Parameters.AddWithValue("@LogoImageName", "").Value = DBNull.Value;
                       
                    }
                    else //if (SelectedNewImage)
                    {
                        cmd.Parameters.AddWithValue("@ClearImage", false);
                        cmd.Parameters.AddWithValue("@NewImage", true);
                        cmd.Parameters.AddWithValue("@CompanyLogo", ByteImageConverter.ImageToByte(fs));
                        cmd.Parameters.AddWithValue("@LogoImageName", txtblck_image.Text);
                        
                    }
                   

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
        

        private void Btn_Image_Click(object sender, RoutedEventArgs e)
        {
            //Select Image
            try
            {

                OpenFileDialog openFileDialog = new OpenFileDialog();
                openFileDialog.Multiselect = false;
                openFileDialog.Filter = "Images (.jpg, .png, .gif, .bmp)|*.jpg;*.png;*.gif;*.bmp"; //"All files (*.*)|*.*"; //
                openFileDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);

                openFileDialog.ShowDialog();

                string filePath = "";

                foreach (string filename in openFileDialog.FileNames)
                {
                    fs = new FileStream(filename, FileMode.Open, FileAccess.Read);
                    image.Source = new BitmapImage(new Uri(filename));
                    filePath = filename;
                    SelectedNewImage = true;
                    ClearImage = false;
                }

                string ImageName = filePath.Substring(filePath.LastIndexOf("\\")+1);
                txtblck_image.Text = ImageName;              

            }
            catch(Exception ex)
            {
                System.Windows.MessageBox.Show(ex.Message, "Error");
            }
            
        }

        private void Btn_ImageClear_Click(object sender, RoutedEventArgs e)
        {
            //Clear Image
            image.Source = null;
            ClearImage = true;
            ImageName = null;
            txtblck_image.Text = null;
        }

        private void Btn_Back_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void BtnUpdateCompanyInfo_Click(object sender, RoutedEventArgs e)
        {
            CompanyInfoUpdate();
        }
    }
}
