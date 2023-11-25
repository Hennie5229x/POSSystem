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
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Net.Sockets;
using System.IO;
using System.Diagnostics;
using POSSystem_Retail;


namespace POSSystem_Retail
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();


            //Test
            Pin = tbx_Pin.Password;

            tbl_IP.Text = "IP Address: " + GetLocalIPAddress();

            SetConnectionString();
        }

        private string Pin = "";

        private void SetConnectionString()
        {
            string CurrentConnString = "";

            string startupPath = System.IO.Path.Combine(Directory.GetParent(System.IO.Directory.GetCurrentDirectory()).Parent.Parent.Parent.FullName);
            startupPath = startupPath + @"\POSSystem\POSSystem\bin\Debug\POSSystem_Manager.exe.Config";

            System.IO.StreamReader file = new System.IO.StreamReader(startupPath);

            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.Load(file);

            System.Xml.XmlNodeList elemList = doc.GetElementsByTagName("connectionStrings");
            for (int i = 0; i < elemList.Count; i++)
            {
                CurrentConnString = elemList[i].InnerXml;
            }

            file.Close();

            string Index1 = "Data Source",
                   Index2 = "providerName";

            string conn = CurrentConnString.Substring(CurrentConnString.IndexOf(Index1));
            conn = conn.Substring(0, conn.IndexOf(Index2) - 2);

            var csb = new SqlConnectionStringBuilder(conn);

            string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;

            //MessageBox.Show(csb.ConnectionString);

            if (ConString != csb.ConnectionString)
            {
                //Save new ConnectionString
                Configuration config = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
                config.ConnectionStrings.ConnectionStrings["ConString"].ConnectionString = csb.ConnectionString;
                config.ConnectionStrings.ConnectionStrings["ConString"].ProviderName = "System.Data.SqlClient";
                config.Save(ConfigurationSaveMode.Modified);

                //Test the New Connection String
                using (SqlConnection connection = new SqlConnection(csb.ConnectionString))
                {
                    try
                    {
                        connection.Open();

                        MessageBox.Show("The Connection String has been changed, the application will be restarted.", "Database Connection");

                        string path = System.IO.Path.Combine(Directory.GetParent(System.IO.Directory.GetCurrentDirectory()).Parent.Parent.Parent.FullName);
                        path = path + @"\POSSystem\POSSystem_Retail\bin\Debug\POSSystem_Retail.exe";

                        Process.Start(path);

                        this.Close();
                    }
                    catch (SqlException)
                    {
                        MessageBox.Show("A connection to the database cannot be established, please open the Manager and test the connection under 'Database Connection'. The application will be closed.", "Cannot Connect to Database");

                        this.Close();
                    }

                }

                //Test the Current Connection String
                using (SqlConnection connection = new SqlConnection(csb.ConnectionString))
                {
                    try
                    {
                        connection.Open();
                    }
                    catch (SqlException)
                    {
                        MessageBox.Show("A connection to the database cannot be established, please open the Manager and test the connection under 'Database Connection'. The application will be closed.", "Cannot Connect to Database");

                        this.Close();
                    }

                }

            }
        }

        private void AddChar(string Value)
        {
            Pin = tbx_Pin.Password;
            if(Pin.Length < 4)
            {
                Pin += Value;
                tbx_Pin.Password = Pin;
            }           
        }

        private void RemoveChar()
        {
            Pin = tbx_Pin.Password;
            if (Pin.Length < 1)
            {
                Pin = "";
            }
            else
            {
                int Len = Pin.Length - 1;
                Pin = Pin.Substring(0, Len);
            }
            
            tbx_Pin.Password = Pin;

            
        }

        private void Login()
        {
            try
            {

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpUsers_Login_Pin", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Pin", tbx_Pin.Password);                   

                    SqlDataReader reader = cmd.ExecuteReader();

                    string Result = null;
                    string Id = null;

                    while (reader.Read())
                    {
                        Result = reader["Result"].ToString();
                        Id = reader["Id"].ToString();
                    }

                    //string LoggedIn = null;

                    if (Result == "1")
                    {

                        UserId.User_Id = Id;                    

                        POS pos = new POS(Id);
                        pos.Show();
                        this.Close();
                    }
                    else
                    {
                        ErrorDialog errorDialog = new ErrorDialog("Login Failed", "Login failed, incorect Pin");
                        errorDialog.ShowDialog();

                        //MessageBox.Show("Login failed, incorect Pin", "Login Failed");
                    }



                    con.Close();

                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        public static string GetLocalIPAddress()
        {
            var host = Dns.GetHostEntry(Dns.GetHostName());
            foreach (var ip in host.AddressList)
            {
                if (ip.AddressFamily == AddressFamily.InterNetwork)
                {
                    return ip.ToString();
                }
            }
            throw new Exception("No network adapters with an IPv4 address in the system!");
        }

        private void GetTerminalInfo_AndLogin()
        {
            int TerminalId = 0;
            string TerminalName = null;
            string TerminalIP = null;
            int PrinterId = 0;

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcGetTerminal", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@TerminalIP", GetLocalIPAddress());

                    SqlDataReader reader = cmd.ExecuteReader();


                    while (reader.Read())
                    {
                        TerminalId = Int32.Parse(reader["Id"].ToString());
                        TerminalName = reader["TerminalName"].ToString();
                        TerminalIP = reader["Terminal_IP"].ToString();
                        PrinterId = Int32.Parse(reader["PrinterId"].ToString());
                    }

                    con.Close();

                    Login();

                }
            }
            catch (Exception e)
            {

                string ErrorMessage = e.Message + " for " + GetLocalIPAddress();

                ErrorDialog errorDialog = new ErrorDialog("Error", ErrorMessage);
                errorDialog.ShowDialog();
                //MessageBox.Show(e.Message, "Error");

            }


        }


        ///---------------------------------

        private void Btn_One_Click(object sender, RoutedEventArgs e)
        {
            //One
            AddChar("1");
        }

        private void Btn_Two_Click(object sender, RoutedEventArgs e)
        {
            //Two
            AddChar("2");
        }

        private void Btn_Three_Click(object sender, RoutedEventArgs e)
        {
            //Three
            AddChar("3");
        }

        private void Btn_Four_Click(object sender, RoutedEventArgs e)
        {
            //Four
            AddChar("4");
        }

        private void Btn_Five_Click(object sender, RoutedEventArgs e)
        {
            //Five
            AddChar("5");
        }

        private void Btn_Six_Click(object sender, RoutedEventArgs e)
        {
            //Six
            AddChar("6");
        }

        private void Btn_Seven_Click(object sender, RoutedEventArgs e)
        {
            //Seven
            AddChar("7");
        }

        private void Btn_Eight_Click(object sender, RoutedEventArgs e)
        {
            //Eight
            AddChar("8");
        }

        private void Btn_Nine_Click(object sender, RoutedEventArgs e)
        {
            //Nine
            AddChar("9");
        }

        private void Btn_Clear_Click(object sender, RoutedEventArgs e)
        {
            Pin = "";
            tbx_Pin.Password = Pin;

            
        }

        private void Btn_Zero_Click(object sender, RoutedEventArgs e)
        {
            //Zero
            AddChar("0");
        }

        private void Btn_Back_Click(object sender, RoutedEventArgs e)
        {
            //Remove Last Char
            RemoveChar();
        }

        private void Btn_Login_Click(object sender, RoutedEventArgs e)
        {
            GetTerminalInfo_AndLogin();

            //Login();
        }

        private void Tbx_Pin_KeyUp(object sender, KeyEventArgs e)
        {
            
        }

        private void tbx_Pin_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == System.Windows.Input.Key.Enter)
            {
                GetTerminalInfo_AndLogin();
            }
        }
    }
}
