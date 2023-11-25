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
using System.Data.SqlClient;
using System.Data;
using System.Diagnostics;
using System.IO;
using Microsoft.Win32;
using System.Data.Sql;


namespace POSSystem_Manager
{
    /// <summary>
    /// Interaction logic for DatabaseConnection.xaml
    /// </summary>
    public partial class DatabaseConnection : Window
    {
        public DatabaseConnection()
        {
            InitializeComponent();

            ConnectionStringInfo();

            Started = true;
            ReadOnlyFields(cbx_IntegratedSecurity.IsChecked.Value);
        }

        bool Started = false;

        private void ReadOnlyFields(bool condition)
        {
            if(condition)
            {
                tbx_UserName.Text = null;
                tbx_Password.Password = null;

                tbx_UserName.IsReadOnly = true;
                tbx_Password.IsEnabled = false;

                tbx_UserName.Background = Brushes.LightGray;
                tbx_Password.Background = Brushes.LightGray;
            }
            else
            {
                tbx_UserName.IsReadOnly = false;
                tbx_Password.IsEnabled = true;

                tbx_UserName.Background = Brushes.White;
                tbx_Password.Background = Brushes.White;
            }
        }

        private void ConnectionStringInfo()
        {
            //Database Connection
            string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
            var csb = new SqlConnectionStringBuilder(ConString);

            string ServerName = csb.DataSource; 
            string DatabaseName = csb.InitialCatalog;
            bool IntegratedSecurity = csb.IntegratedSecurity;
            string UserName = csb.UserID;
            string Password = csb.Password;

            tbx_ServerName.Text = ServerName;
            tbx_DatabaseName.Text = DatabaseName;
            cbx_IntegratedSecurity.IsChecked = IntegratedSecurity;
            tbx_UserName.Text = UserName;
            tbx_Password.Password = Password;           

        }

        private void btnUpdate_Click(object sender, RoutedEventArgs e)
        {
            //Database Connection
            string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
            var csb = new SqlConnectionStringBuilder(ConString);  
            
            csb.DataSource = tbx_ServerName.Text;
            csb.InitialCatalog = tbx_DatabaseName.Text;
            csb.IntegratedSecurity = cbx_IntegratedSecurity.IsChecked.Value;
            

            if(!cbx_IntegratedSecurity.IsChecked.Value)//False
            {
                MessageBox.Show("TEST");
                csb.UserID = tbx_UserName.Text;
                csb.Password = tbx_Password.Password;
            }

            //MessageBox.Show(csb.ConnectionString);

            Configuration config = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            config.ConnectionStrings.ConnectionStrings["ConString"].ConnectionString = csb.ConnectionString;
            config.ConnectionStrings.ConnectionStrings["ConString"].ProviderName = "System.Data.SqlClient";
            config.Save(ConfigurationSaveMode.Modified);

            MessageBox.Show("The Application will be restarted for the new Connection String to save properly.", "Attention!");

            string path = System.IO.Path.Combine(Directory.GetParent(System.IO.Directory.GetCurrentDirectory()).Parent.Parent.Parent.FullName);
            path = path + @"\POSSystem\POSSystem\bin\Debug\POSSystem_Manager.exe";

            Process.Start(path);

            System.Environment.Exit(0);

        }

        private void btn_Back_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void btnTestCon_Click(object sender, RoutedEventArgs e)
        {
            //Database Connection
            string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
            var csb = new SqlConnectionStringBuilder(ConString);

            csb.DataSource = tbx_ServerName.Text;
            csb.InitialCatalog = tbx_DatabaseName.Text;
            csb.IntegratedSecurity = cbx_IntegratedSecurity.IsChecked.Value;

            if (!cbx_IntegratedSecurity.IsChecked.Value)//False
            {
                csb.UserID = tbx_UserName.Text;
                csb.Password = tbx_Password.Password;
            }

            using (SqlConnection connection = new SqlConnection(csb.ConnectionString))
            {
                try
                {
                    connection.Open();
                    MessageBox.Show("The connection was Successful!", "SQL Connection Test");
                }
                catch (SqlException)
                {
                    MessageBox.Show("The connection Failed!", "SQL Connection Test");
                }

            }

            }

        private void cbx_IntegratedSecurity_Checked(object sender, RoutedEventArgs e)
        {
            if(Started)
            {
                ReadOnlyFields(cbx_IntegratedSecurity.IsChecked.Value);
            }
            
        }
        private void cbx_IntegratedSecurity_Unchecked(object sender, RoutedEventArgs e)
        {
            if (Started)
            {
                ReadOnlyFields(cbx_IntegratedSecurity.IsChecked.Value);
            }
        }

        private void btnFindServer_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                string FullInstanceName = "";
                string InstanceName = "";

                string ServerName = Environment.MachineName;
                RegistryView registryView = Environment.Is64BitOperatingSystem ? RegistryView.Registry64 : RegistryView.Registry32;
                using (RegistryKey hklm = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, registryView))
                {
                    RegistryKey instanceKey = hklm.OpenSubKey(@"SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL", false);
                    if (instanceKey != null)
                    {
                        foreach (var instanceName in instanceKey.GetValueNames())
                        {
                            FullInstanceName = ServerName + "\\" + instanceName;
                            InstanceName = instanceName;
                        }
                    }
                }

                if (InstanceName == "")
                {
                    MessageBox.Show("No Local SQL Server Instance could be found.", "Error");
                }
                else
                {
                    MessageBox.Show("Local SQL Server Instance found (" + FullInstanceName + ").\nPlease Test the connection before updating.", "SQL Instance Found");
                    tbx_ServerName.Text = FullInstanceName;
                }

            }
            catch (Exception exc)
            {
                MessageBox.Show(exc.Message, "Error");
            }
            
        }
    }
}
