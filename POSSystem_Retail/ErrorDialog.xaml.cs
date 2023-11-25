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
using System.Threading;

namespace POSSystem_Retail
{
    /// <summary>
    /// Interaction logic for ErrorDialog.xaml
    /// </summary>
    public partial class ErrorDialog : Window
    {
        public ErrorDialog(string Title, string ErrorMessage)
        {
            InitializeComponent();

            this.Title = Title;
            tbx_ErrorMessage.Text = ErrorMessage;

        }

        private void Btn_OK_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void Window_KeyUp(object sender, KeyEventArgs e)
        {
            //Thread.Sleep(5000);
            //if (e.Key == System.Windows.Input.Key.Enter)
            //{
                
            //    this.Close();
            //}
        }
    }
}
